import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/forbidden_line_game.dart';

class MainMenu extends StatelessWidget {
  final ForbiddenLineGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyanAccent.withOpacity(0.15),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(
                      begin: const Offset(0, 0),
                      end: const Offset(50, 50),
                      duration: 4.seconds,
                    ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child:
                Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF0055).withOpacity(0.15),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(
                      begin: const Offset(0, 0),
                      end: const Offset(-50, -50),
                      duration: 5.seconds,
                    ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                        'E V A D E   T H E   R E D',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontFamily: 'Courier',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: -1, end: 0, curve: Curves.easeOutBack),
                  const SizedBox(height: 10),
                  const Text(
                        'ZERO\nGAP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 85,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: Colors.cyanAccent,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              blurRadius: 40,
                              color: Colors.blue,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 1.seconds)
                      .shimmer(duration: 2.seconds, color: Colors.white54),
                  const SizedBox(height: 50),

                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'BEST SCORE: ${game.highScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 60),

                  NeonButton(
                        text: 'START RUSH',
                        icon: Icons.play_arrow_rounded,
                        color: Colors.cyanAccent,
                        isPrimary: true,
                        onPressed: () {
                          game.overlays.remove('MainMenu');
                          game.startGame();
                        },
                      )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                  const SizedBox(height: 25),
                  NeonButton(
                        text: 'GARAGE',
                        icon: Icons.shopping_cart_rounded,
                        color: Colors.amberAccent,
                        isPrimary: false,
                        onPressed: () {
                          game.overlays.remove('MainMenu');
                          game.overlays.add('ShopMenu');
                        },
                      )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 35),

                  // === دکمه جدید حمایت (تبلیغات) ===
                  TextButton.icon(
                    onPressed: () {
                      // اینجا بعدا کد تبلیغ حمایتی رو میذاری
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ad functionality coming soon!'),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                    ),
                    icon: const Icon(Icons.favorite, size: 20),
                    label: const Text(
                      'SUPPORT DEV (WATCH AD)',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onPressed;

  const NeonButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.4), // افکت کلیک
        child: Container(
          width: isPrimary ? 280 : 240,
          height: isPrimary ? 75 : 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.8),
              width: isPrimary ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: isPrimary ? 20 : 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: isPrimary ? 35 : 28),
              const SizedBox(width: 15),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPrimary ? 26 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  letterSpacing: 3,
                  shadows: [Shadow(color: color, blurRadius: 15)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (isPrimary) {
      return button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 800.ms,
            curve: Curves.easeInOut,
          );
    }
    return button;
  }
}
