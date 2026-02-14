import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../forbidden_line_game.dart';

class ScoreDisplay extends PositionComponent
    with HasGameRef<ForbiddenLineGame> {
  late TextComponent scoreText;
  late TextComponent coinsText;
  late TextComponent statusText;

  final scoreStyle = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 55, // کمی بزرگتر چون الان وسط و مهمه
      fontWeight: FontWeight.w900,
      fontFamily: 'Courier',
      shadows: [
        Shadow(blurRadius: 15, color: Colors.cyanAccent, offset: Offset(0, 0)),
        Shadow(blurRadius: 30, color: Colors.blue, offset: Offset(0, 0)),
      ],
    ),
  );

  final coinsStyle = TextPaint(
    style: const TextStyle(
      color: Colors.amberAccent,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: 'Courier',
      shadows: [
        Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(0, 0)),
      ],
    ),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // === تغییر مکان: امتیاز (تایمر) به بالا وسط ===
    scoreText = TextComponent(
      anchor: Anchor.topCenter,
      position: Vector2(0, -ForbiddenLineGame.gameHeight / 2 + 50),
    );

    // === تغییر مکان: سکه‌ها به بالا سمت چپ ===
    coinsText = TextComponent(
      anchor: Anchor.topLeft,
      position: Vector2(
        -ForbiddenLineGame.gameWidth / 2 + 25,
        -ForbiddenLineGame.gameHeight / 2 + 60,
      ),
    );

    statusText = TextComponent(
      anchor: Anchor.topCenter,
      position: Vector2(0, (-ForbiddenLineGame.gameHeight / 2) + 140),
    );

    addAll([scoreText, coinsText, statusText]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    scoreText.text = gameRef.score.toString();
    scoreText.textRenderer = scoreStyle;

    coinsText.text = '🪙 ${gameRef.totalCoins}';
    coinsText.textRenderer = coinsStyle;

    if (gameRef.hasShield) {
      statusText.text = '🛡️ SHIELD';
      statusText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      );
    } else if (gameRef.isActiveFreeze) {
      statusText.text = '❄️ ${gameRef.activeFreezeTimer.toStringAsFixed(1)}s';
      statusText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      );
    } else {
      statusText.text = '';
    }
  }
}
