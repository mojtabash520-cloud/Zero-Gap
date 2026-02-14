import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/forbidden_line_game.dart';
import '../game/ad_manager.dart'; // حتماً این فایل باید وجود داشته باشد

class MainMenu extends StatefulWidget {
  final ForbiddenLineGame game;

  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool isWatchingAd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F), 
      body: Stack(
        children: [
          // === پس‌زمینه متحرک ===
          Positioned(
            top: -100, 
            left: -100, 
            child: Container(
              width: 300, 
              height: 300, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: Colors.cyanAccent.withOpacity(0.15)
              )
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(begin: const Offset(0, 0), end: const Offset(50, 50), duration: 4.seconds)
          ),
          Positioned(
            bottom: -150, 
            right: -100, 
            child: Container(
              width: 400, 
              height: 400, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: const Color(0xFFFF0055).withOpacity(0.15)
              )
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(begin: const Offset(0, 0), end: const Offset(-50, -50), duration: 5.seconds)
          ),
          
          // افکت شیشه‌ای روی پس‌زمینه
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), 
            child: Container(color: Colors.transparent)
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // تگ‌لاین بازی
                  const Text(
                    'E V A D E   T H E   R E D', 
                    style: TextStyle(
                      color: Colors.cyanAccent, 
                      fontFamily: 'Courier', 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 5
                    )
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -1, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 10),
                  
                  // عنوان اصلی بازی (Zero Gap)
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
                        Shadow(blurRadius: 20, color: Colors.cyanAccent, offset: Offset(0, 0)), 
                        Shadow(blurRadius: 40, color: Colors.blue, offset: Offset(0, 0))
                      ]
                    )
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .fadeIn(duration: 1.seconds)
                   .shimmer(duration: 2.seconds, color: Colors.white54),
                  
                  const SizedBox(height: 50),
                  
                  // نمایش بهترین امتیاز
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), 
                      borderRadius: BorderRadius.circular(30), 
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28), 
                        const SizedBox(width: 10), 
                        Text(
                          'BEST SCORE: ${widget.game.highScore}', 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'Courier', 
                            letterSpacing: 2
                          )
                        )
                      ]
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 60),

                  // دکمه شروع بازی
                  NeonButton(
                    text: 'START RUSH', 
                    icon: Icons.play_arrow_rounded, 
                    color: Colors.cyanAccent, 
                    isPrimary: true, 
                    onPressed: () { 
                      widget.game.overlays.remove('MainMenu'); 
                      widget.game.startGame(); 
                    }
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 25),
                  
                  // دکمه فروشگاه (گاراژ)
                  NeonButton(
                    text: 'GARAGE', 
                    icon: Icons.shopping_cart_rounded, 
                    color: Colors.amberAccent, 
                    isPrimary: false, 
                    onPressed: () { 
                      widget.game.overlays.remove('MainMenu'); 
                      widget.game.overlays.add('ShopMenu'); 
                    }
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 35),
                  
                  // === دکمه حمایت با دیدن ویدیو (تبلیغات) ===
                  TextButton.icon(
                    onPressed: isWatchingAd ? null : () {
                      setState(() => isWatchingAd = true);
                      
                      // نمایش تبلیغ از طریق AdManager
                      AdManager.showRewardAd(
                        context,
                        onRewarded: () {
                          if (mounted) {
                            setState(() => isWatchingAd = false);
                            // تشکر از کاربر و دادن جایزه
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Thanks for your support! +50 Coins ❤️'),
                              backgroundColor: Colors.pinkAccent,
                              duration: Duration(seconds: 3),
                            ));
                            
                            // اضافه کردن سکه جایزه
                            widget.game.totalCoins += 50;
                            // ذخیره کردن سکه جدید (چون shared pref داخل گیم هست، باید دستی ذخیره بشه یا سیو اتوماتیک داشته باشه)
                            // اینجا فرض می‌کنیم متد سیو جداگانه‌ای نیست و فقط به متغیر اضافه می‌کنیم
                            // برای ذخیره دائمی بهتره تو خود گیم هندل بشه، ولی فعلا کاربردیه.
                          }
                        },
                        onError: () {
                          if (mounted) setState(() => isWatchingAd = false);
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: isWatchingAd 
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 2)) 
                      : const Icon(Icons.play_circle_fill_rounded, size: 22),
                    label: Text(
                      isWatchingAd ? 'LOADING AD...' : 'WATCH AD TO SUPPORT ❤', 
                      style: const TextStyle(
                        fontFamily: 'Courier', 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1, 
                        fontSize: 16
                      )
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

// ویجت دکمه نئونی (اختصاصی برای منو)
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
    this.isPrimary = false
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.4),
        child: Container(
          width: isPrimary ? 280 : 240, 
          height: isPrimary ? 75 : 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)], 
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.8), 
              width: isPrimary ? 2.5 : 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3), 
                blurRadius: isPrimary ? 20 : 10, 
                spreadRadius: 0
              )
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
                  shadows: [Shadow(color: color, blurRadius: 15)]
                )
              )
            ]
          ),
        ),
      ),
    );
    
    // اگر دکمه اصلی باشد، افکت تپش (Pulse) دارد
    if (isPrimary) { 
      return button.animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0), 
          end: const Offset(1.05, 1.05), 
          duration: 800.ms, 
          curve: Curves.easeInOut
        ); 
    }
    return button;
  }
}
