import 'package:flutter/material.dart';
import '../game/forbidden_line_game.dart';

class PauseMenu extends StatelessWidget {
  final ForbiddenLineGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 50),

            // دکمه ادامه بازی
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  game.resumeGameplay();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'RESUME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // دکمه خروج به منوی اصلی
            TextButton(
              onPressed: () {
                game.quitToMenu();
              },
              child: const Text(
                'Quit to Menu',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
