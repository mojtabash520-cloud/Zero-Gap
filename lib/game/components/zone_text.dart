import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ZoneText extends TextComponent {
  ZoneText({required String text, required Vector2 position})
    : super(
        text: text,
        position: position,
        anchor: Anchor.center,
        priority: 200,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF0055),
            fontSize: 65,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            shadows: [
              Shadow(
                blurRadius: 20,
                color: Colors.redAccent,
                offset: Offset(0, 0),
              ),
              Shadow(blurRadius: 40, color: Colors.black, offset: Offset(3, 3)),
            ],
          ),
        ),
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // === فیکس ارور صفحه قرمز ===
    // به جای OpacityEffect از ScaleEffect و Timer استفاده می‌کنیم که امن هستند.

    // 1. افکت تپش (بزرگ و کوچک شدن)
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.2, alternate: true, repeatCount: 3),
      ),
    );

    // 2. حذف خودکار بعد از 2 ثانیه (بدون استفاده از OpacityEffect)
    add(
      TimerComponent(
        period: 2.0,
        removeOnFinish: true,
        onTick: () => removeFromParent(),
      ),
    );
  }
}
