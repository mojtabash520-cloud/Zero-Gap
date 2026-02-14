import 'package:flutter/material.dart';
import '../game/forbidden_line_game.dart';

class FreezeButton extends StatelessWidget {
  final ForbiddenLineGame game;

  const FreezeButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          // فاصله کمتر از لبه‌ها برای جمع‌وجورتر شدن
          padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
          child: ValueListenableBuilder<int>(
            valueListenable: game.freezeCharges,
            builder: (context, charges, child) {
              bool canUse = charges > 0 && !game.isActiveFreeze;

              return GestureDetector(
                onTap: () {
                  if (canUse) game.activateFreeze();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // === سایز دکمه از 75 به 58 کاهش یافت ===
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // وقتی شارژ نداره، خیلی کمرنگ بشه تا مزاحم نباشه
                    color: canUse
                        ? Colors.cyanAccent.withOpacity(0.2)
                        : Colors.black.withOpacity(0.3),
                    border: Border.all(
                      color: canUse ? Colors.cyanAccent : Colors.white12,
                      width: 1.5,
                    ),
                    boxShadow: canUse
                        ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // آیکون برف کوچکتر
                      Opacity(
                        opacity: canUse ? 1.0 : 0.4,
                        child: const Icon(
                          Icons.ac_unit_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // عدد شارژ
                      Text(
                        '$charges',
                        style: TextStyle(
                          color: canUse ? Colors.white : Colors.white38,
                          fontSize: 14, // فونت ریزتر
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
