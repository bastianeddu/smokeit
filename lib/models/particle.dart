import 'dart:math' as math;

class SmokeParticle {
  SmokeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.radius,
  }) : age = 0.0;

  double x;
  double y;
  double vx;
  double vy;
  double radius;
  final double life;
  double age;

  bool get dead => age >= life;

  double get t => (age / life).clamp(0.0, 1.0);

  void update(double dt) {
    age += dt;
    x += vx * dt;
    y += vy * dt;
    vx += math.sin(age * 2.3 + y * 0.03) * 14 * dt;
    vy -= 10 * dt;
    radius += 16 * dt;
  }
}

class AshParticle {
  AshParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required double life,
  })  : life = life,
        age = 0.0;

  double x;
  double y;
  double vx;
  double vy;
  final double life;
  double age;

  bool get dead => age >= life;

  double get t => (age / life).clamp(0.0, 1.0);

  void update(double dt) {
    age += dt;
    vy += 240 * dt;
    x += vx * dt;
    y += vy * dt;
  }
}
