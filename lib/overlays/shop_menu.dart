import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/forbidden_line_game.dart';
import '../game/components/player_ball.dart';

class ShopMenu extends StatefulWidget {
  final ForbiddenLineGame game;

  const ShopMenu({super.key, required this.game});

  @override
  State<ShopMenu> createState() => _ShopMenuState();
}

class _ShopMenuState extends State<ShopMenu> {
  final List<int> skinPrices = [0, 50, 100, 200, 500];
  final List<String> skinNames = [
    'CIRCLE',
    'SQUARE',
    'TRIANGLE',
    'STAR',
    'HEX',
  ];
  final int maxUpgradeLevel = 5;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF1A1A2E), Colors.black],
              radius: 1.5,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          widget.game.overlays.remove('ShopMenu');
                          widget.game.overlays.add('MainMenu');
                        },
                      ),
                      const Text(
                        'GARAGE',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.game.totalCoins}',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const TabBar(
                  indicatorColor: Colors.cyanAccent,
                  labelColor: Colors.cyanAccent,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  tabs: [
                    Tab(text: '🎨 SKINS'),
                    Tab(text: '⚡ UPGRADES'),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSkinsTab().animate().fadeIn(),
                      _buildUpgradesTab().animate().fadeIn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: PlayerBall.skinColors.length,
      itemBuilder: (context, index) {
        final bool isOwned = widget.game.ownedSkins.contains(index.toString());
        final bool isSelected = widget.game.selectedSkinIndex == index;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOwned
                ? () => setState(() => widget.game.equipSkin(index))
                : (widget.game.totalCoins >= skinPrices[index]
                      ? () => setState(
                          () => widget.game.buySkin(index, skinPrices[index]),
                        )
                      : null),
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white12,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CustomPaint(
                      painter: SkinPreviewPainter(
                        color: PlayerBall.skinColors[index],
                        index: index,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    skinNames[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isSelected)
                    const Text(
                      'EQUIPPED',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (isOwned)
                    const Text(
                      'OWNED',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Courier',
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 16)),
                        Text(
                          '${skinPrices[index]}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ).animate().scale(delay: (index * 100).ms);
      },
    );
  }

  Widget _buildUpgradesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildUpgradeTile(
          icon: '❄️',
          title: 'DEEP FREEZE',
          description: '+1 Sec Freeze Time',
          level: widget.game.freezeLevel,
          type: 'freeze',
        ).animate().slideX(begin: 0.5),
        const SizedBox(height: 15),
        _buildUpgradeTile(
          icon: '🪙',
          title: 'LUCKY COIN',
          description: '+2 Coins per drop',
          level: widget.game.coinLevel,
          type: 'coin',
        ).animate().slideX(begin: 0.5, delay: 100.ms),
        const SizedBox(height: 15),
        _buildUpgradeTile(
          icon: '🛡️',
          title: 'IRON SHIELD',
          description: '+0.5s Invincibility',
          level: widget.game.shieldLevel,
          type: 'shield',
        ).animate().slideX(begin: 0.5, delay: 200.ms),
      ],
    );
  }

  Widget _buildUpgradeTile({
    required String icon,
    required String title,
    required String description,
    required int level,
    required String type,
  }) {
    bool isMax = level >= maxUpgradeLevel;
    int cost = (level + 1) * 150;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: isMax || widget.game.totalCoins < cost
            ? null
            : () => setState(() => widget.game.buyUpgrade(type, cost)),
        splashColor: Colors.white12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Courier',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(maxUpgradeLevel, (index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 12,
                          height: 5,
                          decoration: BoxDecoration(
                            color: index < level
                                ? Colors.cyanAccent
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: index < level
                                ? [
                                    const BoxShadow(
                                      color: Colors.cyan,
                                      blurRadius: 5,
                                    ),
                                  ]
                                : [],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMax ? Colors.grey : Colors.amber.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isMax ? 'MAX' : '🪙 $cost',
                  style: TextStyle(
                    color: isMax ? Colors.white54 : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkinPreviewPainter extends CustomPainter {
  final Color color;
  final int index;

  SkinPreviewPainter({required this.color, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);
    final center = Offset(size.width / 2, size.height / 2);

    if (index == 0) {
      canvas.drawCircle(center, 20, paint);
    } else if (index == 1) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 34, height: 34),
        paint,
      );
    } else if (index == 2) {
      Path path = Path()
        ..moveTo(center.dx, center.dy - 24)
        ..lineTo(center.dx + 20, center.dy + 18)
        ..lineTo(center.dx - 20, center.dy + 18)
        ..close();
      canvas.drawPath(path, paint);
    } else if (index == 3) {
      Path path = Path()
        ..moveTo(center.dx, center.dy - 25)
        ..lineTo(center.dx + 7, center.dy - 7)
        ..lineTo(center.dx + 25, center.dy)
        ..lineTo(center.dx + 7, center.dy + 7)
        ..lineTo(center.dx, center.dy + 25)
        ..lineTo(center.dx - 7, center.dy + 7)
        ..lineTo(center.dx - 25, center.dy)
        ..lineTo(center.dx - 7, center.dy - 7)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      Path path = Path();
      double radius = 22;
      for (int i = 0; i < 6; i++) {
        double angle = (pi / 3) * i;
        double x = center.dx + radius * cos(angle);
        double y = center.dy + radius * sin(angle);
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
