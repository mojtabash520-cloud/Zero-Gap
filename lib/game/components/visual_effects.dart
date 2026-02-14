import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../forbidden_line_game.dart';

// === افکت موج انفجاری (برای فریز و سپر) ===
class ShockwaveEffect extends CircleComponent
    with HasGameRef<ForbiddenLineGame> {
  double life = 0.5;
  final double maxLife = 0.5;
  final Color color;
  final double maxRadius;

  ShockwaveEffect({
    required Vector2 position,
    required this.color,
    required this.maxRadius,
  }) : super(
         position: position,
         radius: 10,
         anchor: Anchor.center,
         paint: Paint()
           ..color = color
           ..style = PaintingStyle.stroke
           ..strokeWidth = 5,
         priority: 15,
       );

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      double progress = 1.0 - (life / maxLife);
      radius = 10 + (maxRadius * progress); // بزرگ شدن دایره
      paint.color = color.withOpacity(life / maxLife); // محو شدن
      paint.strokeWidth = 5 * (life / maxLife); // نازک شدن خط
    }
  }
}

// === افکت انفجار ذرات (برای سکه) ===
class SparkleParticle extends RectangleComponent {
  Vector2 velocity;
  double life;
  final double maxLife;

  SparkleParticle({required Vector2 position, required Color color})
    : velocity = Vector2.zero(),
      life = 0.5 + Random().nextDouble() * 0.5,
      maxLife = 1.0,
      super(
        position: position,
        size: Vector2(6, 6),
        anchor: Anchor.center,
        paint: Paint()..color = color,
        priority: 20,
      ) {
    final random = Random();
    double angle = random.nextDouble() * 2 * pi;
    double speed = random.nextDouble() * 200 + 50;
    velocity = Vector2(cos(angle), sin(angle)) * speed;
    maxLife == life;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    angle += dt * 10;
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      // کوچک شدن و محو شدن
      scale = Vector2.all(life / maxLife);
      paint.color = paint.color.withOpacity((life / maxLife).clamp(0.0, 1.0));
    }
  }
}

// متد کمکی برای تولید انفجار سکه
void spawnCoinExplosion(ForbiddenLineGame game, Vector2 position) {
  for (int i = 0; i < 15; i++) {
    game.world.add(
      SparkleParticle(position: position, color: const Color(0xFFFFD700)),
    );
  }
  // یک درخشش سفید هم وسطش میزنیم
  game.world.add(
    ShockwaveEffect(position: position, color: Colors.white, maxRadius: 60),
  );
}
