import 'package:flutter/material.dart';
import '../game/forbidden_line_game.dart';

class PauseButton extends StatelessWidget {
  final ForbiddenLineGame game;

  const PauseButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight, // انتقال به بالا سمت راست
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, right: 20.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // افکت کلیک (Ripple)
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                game.pauseGameplay();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const Icon(
                  Icons.menu_rounded, // آیکون همبرگری
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
