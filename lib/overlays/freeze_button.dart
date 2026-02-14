import 'package:flutter/material.dart';
import '../game/forbidden_line_game.dart';

class FreezeButton extends StatelessWidget {
  final ForbiddenLineGame game;

  const FreezeButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.freezeCharges,
      builder: (context, count, child) {
        bool isReady = count > 0 && !game.isActiveFreeze;

        return SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft, // <--- تغییر به سمت چپ
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 20.0), // <--- فاصله از چپ
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isReady ? () => game.activateFreeze() : null,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReady 
                          ? Colors.cyanAccent.withOpacity(0.2) 
                          : Colors.grey.withOpacity(0.1),
                      border: Border.all(
                        color: isReady ? Colors.cyanAccent : Colors.white12,
                        width: 2,
                      ),
                      boxShadow: isReady
                          ? [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.ac_unit_rounded,
                          color: isReady ? Colors.white : Colors.white38,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count',
                          style: TextStyle(
                            color: isReady ? Colors.cyanAccent : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
