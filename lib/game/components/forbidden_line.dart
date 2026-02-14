import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../forbidden_line_game.dart';

class LaserSegment extends PositionComponent {
  final Color glowColor;
  late RectangleHitbox hitbox;

  LaserSegment({required this.glowColor}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    hitbox = RectangleHitbox(isSolid: true);
    add(hitbox);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return; // ضد باگ
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(15.0),
    );
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);
    canvas.drawRRect(rrect, glowPaint);
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    RRect coreRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
      const Radius.circular(10.0),
    );
    canvas.drawRRect(coreRRect, corePaint);
  }
}

class ForbiddenLine extends PositionComponent
    with HasGameRef<ForbiddenLineGame> {
  static const double lineHeight = 22.0;

  final double baseSpeed = 220.0;
  final double maxSpeed = 700.0;
  final double startGapSize = 280.0;
  final double minGapSize = 80.0;

  double currentGapSize = 280.0;
  bool isMoving = false;
  double baseGapCenter = 0.0;
  double oscillationTimer = 0.0;
  final double oscillationSpeed = 3.0;
  final double oscillationAmplitude = 100.0;
  double globalMoveTimer = 0.0;

  late LaserSegment leftSegment;
  late LaserSegment rightSegment;
  final _random = Random();

  ForbiddenLine({required double yPosition})
    : super(position: Vector2(0, yPosition));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    leftSegment = LaserSegment(glowColor: const Color(0xFFFF0055))
      ..anchor = Anchor.centerRight;
    rightSegment = LaserSegment(glowColor: const Color(0xFFFF0055))
      ..anchor = Anchor.centerLeft;
    addAll([leftSegment, rightSegment]);
    _generateGap();
    globalMoveTimer = _random.nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);

    double currentSpeed;
    if (gameRef.survivalTime <= 20.0 || gameRef.isActiveFreeze) {
      currentSpeed = baseSpeed;
    } else {
      double speedBoost = ((gameRef.survivalTime - 20.0) / 10.0) * 40.0;
      currentSpeed = (baseSpeed + speedBoost).clamp(baseSpeed, maxSpeed);
    }

    double adjustedDt = dt * gameRef.timeScale;
    position.y += currentSpeed * adjustedDt;

    if (isMoving && !gameRef.isGameOver) {
      double moveMultiplier = gameRef.isActiveFreeze ? 0.3 : 1.0;
      oscillationTimer += (adjustedDt * moveMultiplier);
      double offset =
          sin(oscillationTimer * oscillationSpeed) * oscillationAmplitude;
      _applyGapPositions(baseGapCenter + offset);
    }

    if (gameRef.survivalTime > 90.0 &&
        !gameRef.isActiveFreeze &&
        !gameRef.isGameOver) {
      globalMoveTimer += dt;
      position.x = sin(globalMoveTimer * 2.0) * 50.0;
    } else {
      position.x = 0;
    }
  }

  void resetLine(double newY) {
    position.y = newY;
    position.x = 0;
    if (gameRef.survivalTime <= 20.0) {
      currentGapSize = startGapSize;
      isMoving = false;
    } else {
      double gapShrinkStages = ((gameRef.survivalTime - 20.0) / 10.0)
          .floorToDouble();
      currentGapSize = (200.0 - (gapShrinkStages * 20.0)).clamp(
        minGapSize,
        200.0,
      );
      if (gameRef.survivalTime > 60.0) {
        isMoving = _random.nextBool();
      } else {
        isMoving = false;
      }
    }
    oscillationTimer = 0.0;
    _generateGap();
  }

  void _generateGap() {
    final halfWidth = ForbiddenLineGame.gameWidth / 2;
    double safeMargin = isMoving ? oscillationAmplitude : 0;
    double zone3Margin = 50.0;
    double safeGap = currentGapSize.clamp(minGapSize, 280.0);

    final maxGapCenter = halfWidth - (safeGap / 2) - safeMargin - zone3Margin;
    final minGapCenter = -halfWidth + (safeGap / 2) + safeMargin + zone3Margin;

    if (maxGapCenter <= minGapCenter) {
      baseGapCenter = 0;
    } else {
      baseGapCenter =
          minGapCenter + _random.nextDouble() * (maxGapCenter - minGapCenter);
    }

    _applyGapPositions(baseGapCenter);
  }

  void _applyGapPositions(double centerPos) {
    final halfWidth = ForbiddenLineGame.gameWidth / 2;

    // همیشه عرض حداقل 10 پیکسل باشد
    double leftW = max(10.0, centerPos - (-halfWidth) - (currentGapSize / 2));
    double rightW = max(10.0, halfWidth - centerPos - (currentGapSize / 2));

    leftSegment.size = Vector2(leftW, lineHeight);
    leftSegment.position = Vector2(centerPos - (currentGapSize / 2), 0);
    leftSegment.hitbox.size = Vector2(leftW, lineHeight);

    rightSegment.size = Vector2(rightW, lineHeight);
    rightSegment.position = Vector2(centerPos + (currentGapSize / 2), 0);
    rightSegment.hitbox.size = Vector2(rightW, lineHeight);
  }
}
