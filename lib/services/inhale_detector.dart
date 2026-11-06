import 'dart:async';

import 'package:noise_meter/noise_meter.dart';

class InhaleEvent {
  const InhaleEvent({required this.levelDb, required this.at});

  final double levelDb;
  final DateTime at;
}

class InhaleDetector {
  InhaleDetector({
    this.thresholdOffsetDb = 12,
    this.refractory = const Duration(milliseconds: 700),
    this.calibrationSamples = 30,
  });

  final double thresholdOffsetDb;
  final Duration refractory;
  final int calibrationSamples;

  final NoiseMeter _meter = NoiseMeter();
  final StreamController<InhaleEvent> _events = StreamController<InhaleEvent>.broadcast();
  StreamSubscription<NoiseReading>? _subscription;

  Stream<InhaleEvent> get events => _events.stream;

  double levelDb = 0;
  double baselineDb = 0;
  bool calibrated = false;
  bool inhaling = false;
  bool running = false;

  int _calibCount = 0;
  double _calibSum = 0;
  DateTime _lastInhale = DateTime.fromMillisecondsSinceEpoch(0);

  double get thresholdDb => baselineDb + thresholdOffsetDb;

  double get normalizedLevel {
    final double base = calibrated ? baselineDb : 40;
    return ((levelDb - (base - 5)) / 40).clamp(0.0, 1.0);
  }

  void start() {
    if (running) return;
    running = true;
    _subscription = _meter.noise.listen(_onReading, onError: (_) {});
  }

  void _onReading(NoiseReading reading) {
    double db = reading.meanDecibel;
    if (!db.isFinite) db = 0;
    levelDb = db;
    if (!calibrated) {
      _calibSum += db;
      _calibCount++;
      if (_calibCount >= calibrationSamples) {
        baselineDb = _calibSum / _calibCount;
        calibrated = true;
      }
    }
    final double threshold = calibrated ? thresholdDb : double.infinity;
    final bool above = db > threshold;
    inhaling = above;
    final DateTime now = DateTime.now();
    if (above && now.difference(_lastInhale) >= refractory) {
      _lastInhale = now;
      _events.add(InhaleEvent(levelDb: db, at: now));
    }
  }

  Future<void> stop() async {
    running = false;
    inhaling = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _events.close();
  }
}
