import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/particle.dart';
import '../models/smoke_item.dart';

class BurningItemPainter extends CustomPainter {
  BurningItemPainter({
    required this.item,
    required this.progress,
    required this.ember,
    required this.smoke,
    required this.ash,
    required this.time,
  });

  static const double yFactor = 0.42;
  static const double leftFactor = 0.07;
  static const double rightFactor = 0.93;

  final SmokeItem item;
  final double progress;
  final double ember;
  final List<SmokeParticle> smoke;
  final List<AshParticle> ash;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height * yFactor;
    final double left = size.width * leftFactor;
    final double right = size.width * rightFactor;
    final double fullLen = right - left;
    final double burnX = ui.lerpDouble(left, right, progress)!;
    final double h = size.height * item.thickness;

    if (progress < 1 && ember > 0.03) {
      final Offset c = Offset(burnX, y);
      final double r = size.shortestSide * 0.6;
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(
            c,
            r,
            [
              const Color(0xFFFF8C1A).withValues(alpha: 0.12 * ember),
              const Color(0xFFFF8C1A).withValues(alpha: 0),
            ],
          ),
      );
    }

    _drawShadow(canvas, y, h, left, right);
    if (progress < 1) {
      _drawAsh(canvas, left, burnX, y, h, fullLen);
      _drawBody(canvas, burnX, right, y, h, fullLen);
      _drawEmber(canvas, burnX, y, h);
    }
    _drawSmoke(canvas);
    _drawAshFlecks(canvas);
  }

  void _drawShadow(Canvas canvas, double y, double h, double left, double right) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset((left + right) / 2, y + h * 1.5),
        width: (right - left) * 0.92,
        height: h * 1.2,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  Path _bodyPath(double fromX, double right, double y, double h) {
    final double endHalf = item.isCone ? h * 0.32 : h / 2;
    return Path()
      ..moveTo(fromX, y - h / 2)
      ..lineTo(right, y - endHalf)
      ..lineTo(right, y + endHalf)
      ..lineTo(fromX, y + h / 2)
      ..close();
  }

  void _drawBody(Canvas canvas, double burnX, double right, double y, double h, double fullLen) {
    final Path body = _bodyPath(burnX, right, y, h);
    canvas.drawPath(body, Paint()..color = item.bodyColor);

    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromCenter(center: Offset((burnX + right) / 2, y), width: right - burnX + 2, height: h * 2),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, y - h),
          Offset(0, y + h),
          [
            Colors.white.withValues(alpha: 0.16),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.22),
          ],
          [0.0, 0.45, 1.0],
        ),
    );
    canvas.restore();

    final double endLen = fullLen * (item.type == SmokeItemType.cigarette ? 0.17 : 0.13);
    final double endX = right - endLen;
    if (endX > burnX) {
      canvas.drawPath(_bodyPath(endX, right, y, h), Paint()..color = item.endColor);
      canvas.drawLine(
        Offset(endX, y - h / 2),
        Offset(endX, y + h / 2),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..strokeWidth = 1.4,
      );
      if (item.type == SmokeItemType.joint) {
        final Paint twist = Paint()
          ..color = Colors.black.withValues(alpha: 0.14)
          ..strokeWidth = 1.2;
        for (int i = 1; i < 4; i++) {
          final double x = endX + endLen * i / 4;
          canvas.drawLine(Offset(x, y - h * 0.3), Offset(x, y + h * 0.3), twist);
        }
      }
    }

    if (item.type == SmokeItemType.cigar) {
      canvas.drawPath(
        Path()
          ..moveTo(burnX + 2, y - h * 0.16)
          ..quadraticBezierTo(
            (burnX + right) / 2,
            y - h * 0.34,
            math.max(right - endLen, burnX + 2),
            y - h * 0.16,
          ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    if (item.type == SmokeItemType.cigarette) {
      final Paint lines = Paint()
        ..color = Colors.black.withValues(alpha: 0.07)
        ..strokeWidth = 1;
      final double lineEnd = math.max(right - endLen, burnX + 4);
      for (int i = 1; i < 3; i++) {
        final double yy = y - h / 2 + h * i / 3;
        canvas.drawLine(Offset(burnX + 4, yy), Offset(lineEnd, yy), lines);
      }
    }
  }

  void _drawAsh(Canvas canvas, double left, double burnX, double y, double h, double fullLen) {
    final double ashLen = (fullLen * (0.05 + 0.15 * progress)).clamp(0.0, fullLen * 0.2);
    final double ashStart = math.max(left, burnX - ashLen);
    canvas.drawRect(
      Rect.fromCenter(center: Offset((ashStart + burnX) / 2, y), width: burnX - ashStart, height: h * 0.92),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(ashStart, 0),
          Offset(burnX, 0),
          [const Color(0xFF8E8E93), const Color(0xFFB9B9BE)],
        ),
    );
    final math.Random rng = math.Random(7);
    final Path jag = Path()..moveTo(ashStart, y - h * 0.46);
    for (int i = 0; i <= 6; i++) {
      final double yy = y - h * 0.46 + (h * 0.92) * i / 6;
      final double xx = ashStart - rng.nextDouble() * h * 0.35;
      jag.lineTo(xx, yy);
    }
    jag.close();
    canvas.drawPath(jag, Paint()..color = const Color(0xFF8E8E93));
    final Paint speck = Paint()..color = const Color(0xFF5A5A5F).withValues(alpha: 0.5);
    for (int i = 0; i < 10; i++) {
      final double xx = ashStart + rng.nextDouble() * math.max(burnX - ashStart, 1);
      final double yy = y + (rng.nextDouble() - 0.5) * h * 0.7;
      canvas.drawCircle(Offset(xx, yy), 1.1, speck);
    }
  }

  void _drawEmber(Canvas canvas, double burnX, double y, double h) {
    final double flicker = 0.8 + 0.2 * math.sin(time * 11.0) * math.sin(time * 23.0 + 1.7);
    final double intensity = (ember * flicker).clamp(0.0, 1.0);
    final double glowR = h * (2.0 + 3.0 * intensity);
    canvas.drawCircle(
      Offset(burnX, y),
      glowR,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(burnX, y),
          glowR,
          [
            const Color(0xFFFFB347).withValues(alpha: 0.85 * intensity),
            const Color(0xFFFF6A00).withValues(alpha: 0.45 * intensity),
            const Color(0xFFFF6A00).withValues(alpha: 0),
          ],
          [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawCircle(
      Offset(burnX, y),
      h * 0.62 * (0.75 + 0.35 * intensity),
      Paint()..color = const Color(0xFFFF7B24),
    );
    canvas.drawCircle(
      Offset(burnX, y),
      h * 0.4 * (0.75 + 0.35 * intensity),
      Paint()..color = const Color(0xFFFFD27A),
    );
    canvas.drawCircle(
      Offset(burnX - h * 0.08, y - h * 0.08),
      h * 0.16 * (0.7 + 0.5 * intensity),
      Paint()..color = const Color(0xFFFFF3D6),
    );
  }

  void _drawSmoke(Canvas canvas) {
    for (final SmokeParticle p in smoke) {
      final double a = (1 - p.t) * 0.22;
      if (a <= 0) continue;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, Paint()..color = const Color(0xFFD9DCE1).withValues(alpha: a));
      final double a2 = math.min(0.32, a * 1.6);
      canvas.drawCircle(Offset(p.x, p.y), p.radius * 0.55, Paint()..color = const Color(0xFFEDEFF2).withValues(alpha: a2));
    }
  }

  void _drawAshFlecks(Canvas canvas) {
    for (final AshParticle p in ash) {
      final double a = (1 - p.t) * 0.85;
      canvas.drawCircle(Offset(p.x, p.y), 1.6 + p.t * 1.2, Paint()..color = const Color(0xFF6E6E73).withValues(alpha: a));
    }
  }

  @override
  bool shouldRepaint(covariant BurningItemPainter oldDelegate) => true;
}
