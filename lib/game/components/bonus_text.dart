import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BonusText extends TextComponent {
  final int amount;
  final bool isCoin; // متغیر جدید
  double lifespan = 1.0;
  double timer = 0.0;

  BonusText({
    required this.amount,
    required Vector2 position,
    this.isCoin = false,
  }) : super(
         text: '+ $amount',
         position: position,
         anchor: Anchor.center,
         priority: 100,
         textRenderer: TextPaint(
           style: TextStyle(
             // اگر سکه باشد طلایی، اگر امتیاز باشد زرد روشن
             color: isCoin ? const Color(0xFFFFD700) : const Color(0xFFFFFF00),
             fontSize: isCoin ? 35 : 40,
             fontWeight: FontWeight.bold,
             fontFamily: 'Courier',
             shadows: [
               Shadow(
                 blurRadius: 10,
                 color: isCoin ? Colors.orangeAccent : Colors.orange,
                 offset: const Offset(0, 0),
               ),
             ],
           ),
         ),
       );

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= 100 * dt; // حرکت به بالا
    timer += dt;

    if (timer >= lifespan) {
      removeFromParent();
    } else {
      double progress = timer / lifespan;
      int alpha = ((1.0 - progress) * 255).toInt();

      // تغییر شفافیت
      Color baseColor = isCoin
          ? const Color(0xFFFFD700)
          : const Color(0xFFFFFF00);
      Color shadowColor = isCoin ? Colors.orangeAccent : Colors.orange;

      textRenderer = TextPaint(
        style: TextStyle(
          color: baseColor.withAlpha(alpha),
          fontSize: isCoin ? 35 : 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          shadows: [
            Shadow(
              blurRadius: 10,
              color: shadowColor.withAlpha(alpha),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      );
    }
  }
}
