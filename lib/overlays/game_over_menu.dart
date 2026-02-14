import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/forbidden_line_game.dart';
import '../game/ad_manager.dart'; // <--- ایمپورت
import 'main_menu.dart';

class GameOverMenu extends StatefulWidget {
  final ForbiddenLineGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  State<GameOverMenu> createState() => _GameOverMenuState();
}

class _GameOverMenuState extends State<GameOverMenu> {
  bool isAdLoading = false;

  @override
  Widget build(BuildContext context) {
    bool canRevive = !widget.game.hasRevived;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.redAccent,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.red,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).shake(hz: 4, duration: 500.ms),
            const SizedBox(height: 30),
            Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        '${widget.game.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
            const SizedBox(height: 30),

            if (canRevive) ...[
              if (widget.game.totalCoins >= 200)
                NeonButton(
                  text: 'REVIVE (200 🪙)',
                  icon: Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                  onPressed: () {
                    setState(() {
                      widget.game.totalCoins -= 200;
                      widget.game.reviveGame();
                    });
                  },
                ).animate().fadeIn(delay: 500.ms)
              else
                const Text(
                  "Not enough coins to revive",
                  style: TextStyle(
                    color: Colors.white24,
                    fontFamily: 'Courier',
                  ),
                ),

              const SizedBox(height: 15),

              // === دکمه مشاهده تبلیغ واقعی ===
              ElevatedButton.icon(
                onPressed: isAdLoading
                    ? null
                    : () {
                        setState(() => isAdLoading = true);

                        // فراخوانی AdManager برای نمایش تبلیغ
                        AdManager.showRewardAd(
                          context,
                          onRewarded: () {
                            // اگر کاربر تبلیغ را کامل دید
                            if (mounted) {
                              setState(() => isAdLoading = false);
                              widget.game.reviveGame(); // زنده شدن
                            }
                          },
                          onError: () {
                            // اگر تبلیغ لود نشد
                            if (mounted) setState(() => isAdLoading = false);
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                icon: isAdLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.play_circle_fill, color: Colors.black),
                label: Text(
                  isAdLoading ? 'LOADING AD...' : 'WATCH AD TO REVIVE',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ] else ...[
              const Text(
                "No more revives!",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
            ],

            const SizedBox(height: 40),
            TextButton.icon(
              onPressed: () {
                widget.game.resetGame(restartMusic: true);
                widget.game.overlays.remove('GameOverMenu');
              },
              icon: const Icon(Icons.refresh, color: Colors.white54),
              label: const Text(
                'RESTART GAME',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontFamily: 'Courier',
                  letterSpacing: 2,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
            TextButton.icon(
              onPressed: () {
                widget.game.quitToMenu();
              },
              icon: const Icon(Icons.home, color: Colors.white54),
              label: const Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontFamily: 'Courier',
                  letterSpacing: 2,
                ),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
