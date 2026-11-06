import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/particle.dart';
import '../models/smoke_item.dart';
import '../services/inhale_detector.dart';
import '../widgets/burning_item_painter.dart';

class SmokeScreen extends StatefulWidget {
  const SmokeScreen({super.key, required this.item});

  final SmokeItem item;

  @override
  State<SmokeScreen> createState() => _SmokeScreenState();
}

class _SmokeScreenState extends State<SmokeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final InhaleDetector _detector = InhaleDetector();
  StreamSubscription<InhaleEvent>? _inhaleSub;

  final List<SmokeParticle> _smoke = [];
  final List<AshParticle> _ashFlecks = [];
  final math.Random _rng = math.Random();

  double _progress = 0;
  double _ember = 0.3;
  double _puffEnergy = 0;
  double _elapsed = 0;
  int _puffs = 0;
  bool _finished = false;
  bool _micGranted = false;
  DateTime? _lastTick;
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(hours: 1))
      ..addListener(_tick)
      ..repeat();
    _initMic();
  }

  Future<void> _initMic() async {
    final PermissionStatus status = await Permission.microphone.request();
    _micGranted = status.isGranted;
    if (_micGranted) {
      _detector.start();
      _inhaleSub = _detector.events.listen(_onInhale);
    }
    if (mounted) setState(() {});
  }

  void _onInhale(InhaleEvent event) {
    if (_finished) return;
    _puffs++;
    _puffEnergy = 1;
    setState(() {});
  }

  void _manualPuff() {
    if (_finished) return;
    _puffs++;
    _puffEnergy = 1;
    setState(() {});
  }

  void _reset() {
    setState(() {
      _progress = 0;
      _ember = 0.3;
      _puffEnergy = 0;
      _puffs = 0;
      _finished = false;
      _lastTick = null;
      _smoke.clear();
      _ashFlecks.clear();
    });
  }

  void _tick() {
    if (!mounted || _finished) return;
    final DateTime now = DateTime.now();
    final double dt = _lastTick == null
        ? 1 / 60
        : (now.difference(_lastTick!).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = now;
    _elapsed += dt;

    final double baseRate = 1 / widget.item.duration.inSeconds;
    final double active = _detector.inhaling ? 1.0 : 0.0;
    final double rate = baseRate * (1 + 3.5 * _puffEnergy + 2.5 * active);
    _progress = (_progress + rate * dt).clamp(0.0, 1.0);
    _puffEnergy = math.max(0.0, _puffEnergy - dt / 2.2);

    final double emberTarget = (0.3 + 0.7 * _puffEnergy + 0.25 * active).clamp(0.0, 1.0);
    _ember += (emberTarget - _ember) * math.min(1.0, dt * 4);

    _spawnParticles(dt);

    if (_progress >= 1) {
      _finished = true;
    }
    setState(() {});
  }

  void _spawnParticles(double dt) {
    final Size? size = _canvasSize;
    if (size == null) return;
    final double y = size.height * BurningItemPainter.yFactor;
    final double left = size.width * BurningItemPainter.leftFactor;
    final double right = size.width * BurningItemPainter.rightFactor;
    final double burnX = ui.lerpDouble(left, right, _progress)!;
    final double h = size.height * widget.item.thickness;

    if (_ember > 0.15 && _rng.nextDouble() < _ember * dt * 26) {
      _smoke.add(SmokeParticle(
        x: burnX + (_rng.nextDouble() - 0.5) * h,
        y: y - h * 0.4,
        vx: (_rng.nextDouble() - 0.5) * 14,
        vy: -(26 + _rng.nextDouble() * 30) * (0.6 + _ember),
        life: 2.2 + _rng.nextDouble() * 1.8,
        radius: 3 + _rng.nextDouble() * 3,
      ));
    }
    if (_ember > 0.5 && _rng.nextDouble() < _ember * dt * 1.5) {
      _ashFlecks.add(AshParticle(
        x: burnX + (_rng.nextDouble() - 0.5) * h,
        y: y + (_rng.nextDouble() - 0.5) * h,
        vx: (_rng.nextDouble() - 0.5) * 24,
        vy: -10 - _rng.nextDouble() * 12,
        life: 0.7 + _rng.nextDouble() * 0.7,
      ));
    }
    for (final SmokeParticle p in _smoke) {
      p.update(dt);
    }
    for (final AshParticle p in _ashFlecks) {
      p.update(dt);
    }
    _smoke.removeWhere((SmokeParticle p) => p.dead || p.y < -60);
    _ashFlecks.removeWhere((AshParticle p) => p.dead || p.y > size.height + 60);
    if (_smoke.length > 240) {
      _smoke.removeRange(0, _smoke.length - 240);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _inhaleSub?.cancel();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.label),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Züge: $_puffs'),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _canvasSize = constraints.biggest;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: BurningItemPainter(
                    item: widget.item,
                    progress: _progress,
                    ember: _ember,
                    smoke: _smoke,
                    ash: _ashFlecks,
                    time: _elapsed,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _micGranted ? Icons.mic : Icons.mic_off,
                              size: 18,
                              color: _detector.inhaling ? Colors.deepOrangeAccent : Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _detector.normalizedLevel,
                                  minHeight: 8,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _detector.inhaling ? Colors.deepOrange : Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_detector.levelDb.toStringAsFixed(0)} dB',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _finished
                                ? 'Aufgeraucht!'
                                : _micGranted
                                    ? 'Mach ein Sauggeräusch …'
                                    : 'Mikrofon nicht erlaubt - tippe unten für einen Zug.',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _finished ? null : _manualPuff,
                                icon: const Icon(Icons.touch_app),
                                label: const Text('Zug simulieren'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Noch ${((1 - _progress) * 100).round()} %',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_finished)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🚭', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 8),
                              Text(
                                'Aus! Die ${widget.item.label} ist aufgeraucht.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text('$_puffs Züge', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Zurück'),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton(
                                    onPressed: _reset,
                                    child: const Text('Nochmal'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
