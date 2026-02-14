import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../forbidden_line_game.dart';
import 'power_up.dart';
import 'forbidden_line.dart';
import 'bonus_text.dart';
import 'visual_effects.dart';

class DebrisParticle extends RectangleComponent
    with HasGameRef<ForbiddenLineGame> {
  Vector2 velocity;
  double life = 0.8;

  DebrisParticle({required Vector2 position, required Color color})
    : velocity = Vector2.zero(),
      super(
        position: position,
        size: Vector2(8, 8),
        anchor: Anchor.center,
        paint: Paint()..color = color,
        priority: 20,
      ) {
    final random = Random();
    double angle = random.nextDouble() * 2 * pi;
    double speed = random.nextDouble() * 300 + 100;
    velocity = Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    angle += dt * 5;
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      paint.color = paint.color.withOpacity((life / 0.8).clamp(0.0, 1.0));
    }
  }
}

class TrailParticle extends PositionComponent {
  double life = 0.3;
  final double maxLife = 0.3;
  final Paint _paint;
  final int skinIndex;

  TrailParticle({
    required Vector2 pos,
    required Color color,
    required this.skinIndex,
  }) : _paint = Paint()..color = color.withOpacity(0.5),
       super(
         position: pos,
         size: Vector2(18, 18),
         anchor: Anchor.center,
         priority: 5,
       );

  @override
  void render(Canvas canvas) {
    if (skinIndex == 0) {
      canvas.drawCircle(Offset.zero, 9, _paint);
    } else if (skinIndex == 1) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
        _paint,
      );
    } else {
      canvas.drawCircle(Offset.zero, 7, _paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
    } else {
      _paint.color = _paint.color.withOpacity(
        ((life / maxLife) * 0.6).clamp(0.0, 1.0),
      );
      scale = Vector2.all(life / maxLife);
    }
  }
}

class PlayerBall extends PositionComponent
    with HasGameRef<ForbiddenLineGame>, CollisionCallbacks {
  double speed = 400.0;
  int direction = 1;
  double invincibleTimer = 0.0;
  double trailSpawnTimer = 0.0;

  late CircleComponent aura;
  Color currentSkinColor = Colors.cyanAccent;
  int currentSkinIndex = 0;

  static const List<Color> skinColors = [
    Color(0xFF00FFFF), // 0: Cyan
    Color(0xFFFFD700), // 1: Gold
    Color(0xFFFF0055), // 2: Red
    Color(0xFFE020FF), // 3: Purple
    Color(0xFF39FF14), // 4: Green
  ];

  PlayerBall()
    : super(size: Vector2(36, 36), anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    aura = CircleComponent(
      radius: 28.0,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    add(aura);

    updateSkin(gameRef.selectedSkinIndex);
    add(CircleHitbox(radius: 16, anchor: Anchor.center, position: size / 2));
    add(NearMissZone());
  }

  void updateSkin(int skinIndex) {
    currentSkinIndex = skinIndex;
    if (skinIndex < skinColors.length) {
      currentSkinColor = skinColors[skinIndex];
      aura.paint.color = currentSkinColor.withOpacity(0.6);
    }
  }

  void explode() {
    for (int i = 0; i < 20; i++) {
      gameRef.world.add(
        DebrisParticle(position: position.clone(), color: currentSkinColor),
      );
    }
    scale = Vector2.zero();
  }

  void revive() {
    scale = Vector2.all(1.0);
    invincibleTimer = 3.0;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = currentSkinColor;
    final center = Offset(size.x / 2, size.y / 2);

    if (currentSkinIndex == 0) {
      canvas.drawCircle(center, 16, paint);
    } else if (currentSkinIndex == 1) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 26, height: 26),
        paint,
      );
    } else if (currentSkinIndex == 2) {
      Path path = Path();
      path.moveTo(center.dx, center.dy - 18);
      path.lineTo(center.dx + 16, center.dy + 14);
      path.lineTo(center.dx - 16, center.dy + 14);
      path.close();
      canvas.drawPath(path, paint);
    } else if (currentSkinIndex == 3) {
      Path path = Path();
      path.moveTo(center.dx, center.dy - 20);
      path.lineTo(center.dx + 6, center.dy - 6);
      path.lineTo(center.dx + 20, center.dy);
      path.lineTo(center.dx + 6, center.dy + 6);
      path.lineTo(center.dx, center.dy + 20);
      path.lineTo(center.dx - 6, center.dy + 6);
      path.lineTo(center.dx - 20, center.dy);
      path.lineTo(center.dx - 6, center.dy - 6);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      Path path = Path();
      double radius = 18;
      for (int i = 0; i < 6; i++) {
        double angle = (pi / 3) * i;
        double x = center.dx + radius * cos(angle);
        double y = center.dy + radius * sin(angle);
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    if (currentSkinIndex > 0) {
      angle += dt * 5;
    }

    trailSpawnTimer += dt;
    if (trailSpawnTimer > 0.02 && scale.x > 0) {
      trailSpawnTimer = 0.0;
      gameRef.world.add(
        TrailParticle(
          pos: position.clone(),
          color: currentSkinColor,
          skinIndex: currentSkinIndex,
        ),
      );
    }

    if (invincibleTimer > 0) {
      invincibleTimer -= dt;
      aura.paint.color = currentSkinColor.withOpacity(
        (invincibleTimer * 10) % 2 > 1 ? 0.2 : 0.6,
      );
    } else {
      aura.paint.color = currentSkinColor.withOpacity(0.6);
    }

    double adjustedDt = dt * gameRef.timeScale;
    position.x += speed * direction * adjustedDt;

    final halfGameWidth = ForbiddenLineGame.gameWidth / 2;
    if (position.x + 18 >= halfGameWidth) {
      position.x = halfGameWidth - 18;
      direction = -1;
    } else if (position.x - 18 <= -halfGameWidth) {
      position.x = -halfGameWidth + 18;
      direction = 1;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (scale.x == 0) return;

    if (other is PowerUp) {
      if (other.type == PowerUpType.coin) {
        int coinAmount = 5 + (gameRef.coinLevel * 2);
        gameRef.totalCoins += coinAmount;

        // نمایش متن +5
        gameRef.world.add(
          BonusText(
            amount: coinAmount,
            position: other.position.clone(),
            isCoin: true,
          ),
        );

        spawnCoinExplosion(gameRef, other.position.clone());

        // پخش صدای سکه از AudioPool
        gameRef.poolCoin.start(volume: 0.7);
      } else if (other.type == PowerUpType.shield) {
        gameRef.hasShield = true;
        gameRef.world.add(
          ShockwaveEffect(
            position: position.clone(),
            color: Colors.blueAccent,
            maxRadius: 80,
          ),
        );

        // پخش صدای سپر
        gameRef.poolShield.start(volume: 1.0);
      } else if (other.type == PowerUpType.freeze) {
        gameRef.freezeCharges.value++;
        gameRef.world.add(
          ShockwaveEffect(
            position: other.position.clone(),
            color: Colors.cyanAccent,
            maxRadius: 50,
          ),
        );

        // پخش صدای گرفتن یخ (از whoosh استفاده می‌کنیم یا صدای یخ)
        gameRef.poolWhoosh.start(volume: 1.0);
      }
      other.collect();
      return;
    }

    if (other is LaserSegment) {
      if (invincibleTimer > 0) return;

      if (gameRef.hasShield) {
        gameRef.hasShield = false;
        invincibleTimer = 1.0 + (gameRef.shieldLevel * 0.5);

        gameRef.poolWhoosh.start(volume: 1.0); // صدای شکستن سپر
        gameRef.shakeCamera(intensity: 15.0);

        gameRef.world.add(
          ShockwaveEffect(
            position: position.clone(),
            color: Colors.redAccent,
            maxRadius: 100,
          ),
        );
        return;
      }

      gameRef.gameOver();
    }
  }

  void switchDirection() {
    if (!gameRef.isGameOver && scale.x > 0) direction *= -1;
  }
}

class NearMissZone extends CircleComponent
    with HasGameRef<ForbiddenLineGame>, CollisionCallbacks {
  NearMissZone() : super(radius: 35.0, anchor: Anchor.center) {
    paint = Paint()..color = Colors.white.withOpacity(0.1);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2(18, 18);
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is LaserSegment) {
      gameRef.triggerNearMiss();
    }
  }
}
