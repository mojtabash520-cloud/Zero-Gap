import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/forbidden_line_game.dart';
import 'game/ad_manager.dart'; // <--- ایمپورت
import 'overlays/main_menu.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/shop_menu.dart';
import 'overlays/pause_button.dart';
import 'overlays/pause_menu.dart';
import 'overlays/freeze_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  // === راه اندازی تپسل ===
  await AdManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameWidget<ForbiddenLineGame>(
        game: ForbiddenLineGame(),
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game),
          'GameOverMenu': (context, game) => GameOverMenu(game: game),
          'ShopMenu': (context, game) => ShopMenu(game: game),
          'PauseButton': (context, game) => PauseButton(game: game),
          'PauseMenu': (context, game) => PauseMenu(game: game),
          'FreezeButton': (context, game) => FreezeButton(game: game),
        },
      ),
    );
  }
}
