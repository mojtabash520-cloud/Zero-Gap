import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../forbidden_line_game.dart';

enum PowerUpType { coin, shield, freeze }

class PowerUp extends PositionComponent with HasGameRef<ForbiddenLineGame> {
  final PowerUpType type;
  final double speed = 250.0;
  double timer = 0.0;

  late TextComponent iconText;
  late CircleComponent glowEffect;

  PowerUp({required this.type, required Vector2 position})
    : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    String emoji = '';
    Color glowColor = Colors.white;

    switch (type) {
      case PowerUpType.coin:
        emoji = '🪙';
        glowColor = Colors.amber;
        break;
      case PowerUpType.shield:
        emoji = '🛡️';
        glowColor = Colors.blueAccent;
        break;
      case PowerUpType.freeze:
        emoji = '❄️';
        glowColor = Colors.cyanAccent;
        break;
    }

    glowEffect = CircleComponent(
      radius: 25,
      anchor: Anchor.center,
      position: Vector2(20, 20),
      paint: Paint()
        ..color = glowColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    iconText = TextComponent(
      text: emoji,
      anchor: Anchor.center,
      position: Vector2(20, 20),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 30)),
    );

    addAll([glowEffect, iconText]);
    add(
      CircleHitbox(
        radius: 20,
        anchor: Anchor.center,
        position: Vector2(20, 20),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * (dt * gameRef.timeScale);
    timer += dt * 5;
    glowEffect.radius = 25 + (sin(timer) * 5);

    if (position.y > ForbiddenLineGame.gameHeight / 2 + 50) {
      removeFromParent();
    }
  }

  void collect() {
    gameRef.shakeCamera(intensity: 3.0);
    removeFromParent();
  }
}
