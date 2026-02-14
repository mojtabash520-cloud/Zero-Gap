import 'dart:async' as dart_async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/player_ball.dart';
import 'components/forbidden_line.dart';
import 'components/score_display.dart';
import 'components/bonus_text.dart';
import 'components/zone_text.dart';
import 'components/power_up.dart'; 
import 'components/visual_effects.dart'; 

class ForbiddenLineGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  static const double gameWidth = 800;
  static const double gameHeight = 1600;

  late PlayerBall player;
  final List<ForbiddenLine> obstacles = [];
  final int numberOfLines = 6;
  final double lineSpacing = 400.0;

  bool isPlaying = false;
  bool isGameOver = false;
  double timeScale = 1.0;

  double rawScore = 0.0; 
  int get score => rawScore.toInt(); 
  int scoreMultiplier = 1; 
  double multiplierTimer = 0.0; 
  int highScore = 0; 
  double survivalTime = 0.0; 

  int totalCoins = 0;
  int selectedSkinIndex = 0;
  List<String> ownedSkins = ['0'];
  
  int freezeLevel = 0; 
  int coinLevel = 0;   
  int shieldLevel = 0; 

  int nearMissCount = 0; 
  int currentZone = 1; 

  double shakeTimer = 0.0;
  double shakeIntensity = 0.0;
  final Random _random = Random();
  double slowMotionTimer = 0.0; 

  final ValueNotifier<int> freezeCharges = ValueNotifier<int>(0); 
  bool isActiveFreeze = false; 
  double activeFreezeTimer = 0.0; 
  bool hasShield = false; 
  double powerUpSpawnTimer = 0.0;
  double gridScrollOffset = 0.0;

  bool hasRevived = false; 

  // === سیستم صوتی بهینه‌شده (Audio Pools) ===
  late AudioPool poolWhoosh;
  late AudioPool poolTap;
  late AudioPool poolCoin;
  late AudioPool poolShield;
  late AudioPool poolIce;

  late SharedPreferences prefs;

  ForbiddenLineGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // لود کردن موزیک و صدای کرش (Crash معمولاً تک پخش است)
    // فرض بر این است که bgm همچنان mp3 است چون طولانی است
    // اما crash باید wav باشد
    await FlameAudio.audioCache.loadAll(['sfx/crash.wav', 'music/bgm.mp3']);

    // === تنظیمات جدید برای رفع لگ (کاهش تعداد همزمانی) ===
    // فایل‌ها باید فرمت .wav داشته باشند
    poolWhoosh = await FlameAudio.createPool('sfx/whoosh.wav', minPlayers: 1, maxPlayers: 3);
    poolTap = await FlameAudio.createPool('sfx/tap.wav', minPlayers: 1, maxPlayers: 4);
    poolCoin = await FlameAudio.createPool('sfx/coin.wav', minPlayers: 1, maxPlayers: 4);
    poolShield = await FlameAudio.createPool('sfx/shield.wav', minPlayers: 1, maxPlayers: 2);
    poolIce = await FlameAudio.createPool('sfx/ice.wav', minPlayers: 1, maxPlayers: 2);

    prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
    totalCoins = prefs.getInt('total_coins') ?? 0;
    selectedSkinIndex = prefs.getInt('current_skin') ?? 0;
    ownedSkins = prefs.getStringList('owned_skins') ?? ['0'];
    
    freezeLevel = prefs.getInt('freeze_level') ?? 0;
    coinLevel = prefs.getInt('coin_level') ?? 0;
    shieldLevel = prefs.getInt('shield_level') ?? 0;

    player = PlayerBall()..position = Vector2(0, gameHeight / 4);
    world.add(player);

    for (int i = 0; i < numberOfLines; i++) {
      final yPos = (-gameHeight / 2) - (i * lineSpacing);
      final line = ForbiddenLine(yPosition: yPos);
      obstacles.add(line);
      world.add(line);
    }

    world.add(ScoreDisplay());
    
    // شروع موزیک پس‌زمینه
    FlameAudio.bgm.play('music/bgm.mp3', volume: 0.5);

    pauseEngine(); 
    overlays.add('MainMenu');
  }

  @override
  void render(Canvas canvas) {
    Color bgColor = currentZone == 1 ? const Color(0xFF0D0D14) : const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y), Paint()..color = bgColor);

    final gridPaint = Paint()
      ..color = const Color(0xFF202035).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double gridSize = 100.0;
    for (double i = 0; i < canvasSize.x; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, canvasSize.y), gridPaint);
    }
    for (double i = (gridScrollOffset % gridSize) - gridSize; i < canvasSize.y; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(canvasSize.x, i), gridPaint);
    }

    super.render(canvas); 
  }

  void activateFreeze() {
    if (freezeCharges.value > 0 && !isActiveFreeze) {
      freezeCharges.value--;
      isActiveFreeze = true;
      activeFreezeTimer = 5.0 + (freezeLevel * 1.0); 
      
      poolIce.start(volume: 1.0); // صدای wav
      
      shakeCamera(intensity: 5.0);
      HapticFeedback.mediumImpact(); 
      
      world.add(ShockwaveEffect(position: player.position.clone(), color: Colors.cyanAccent, maxRadius: 150));
    }
  }

  void buyUpgrade(String type, int cost) {
    if (totalCoins >= cost) {
      totalCoins -= cost;
      if (type == 'freeze') { freezeLevel++; prefs.setInt('freeze_level', freezeLevel); }
      else if (type == 'coin') { coinLevel++; prefs.setInt('coin_level', coinLevel); }
      else if (type == 'shield') { shieldLevel++; prefs.setInt('shield_level', shieldLevel); }
      prefs.setInt('total_coins', totalCoins);
      poolTap.start(volume: 1.0);
      HapticFeedback.lightImpact();
    }
  }

  void pauseGameplay() {
    if (!isPlaying || isGameOver) return;
    pauseEngine(); FlameAudio.bgm.pause(); 
    overlays.remove('PauseButton'); overlays.remove('FreezeButton');
    overlays.add('PauseMenu'); 
    HapticFeedback.lightImpact();
  }

  void resumeGameplay() {
    resumeEngine(); FlameAudio.bgm.resume(); 
    overlays.remove('PauseMenu');
    overlays.add('PauseButton'); overlays.add('FreezeButton');
  }

  void quitToMenu() {
    FlameAudio.bgm.stop(); FlameAudio.bgm.play('music/bgm.mp3', volume: 0.5);
    isPlaying = false; 
    overlays.remove('PauseMenu'); overlays.remove('GameOverMenu'); 
    overlays.add('MainMenu'); 
  }

  void shakeCamera({double intensity = 10.0}) { shakeIntensity = intensity; shakeTimer = 0.3; }

  void startGame() {
    resetGame(restartMusic: false);
    overlays.remove('MainMenu'); overlays.remove('GameOverMenu'); overlays.remove('ShopMenu');
  }

  void buySkin(int skinId, int cost) {
    if (totalCoins >= cost && !ownedSkins.contains(skinId.toString())) {
      totalCoins -= cost; ownedSkins.add(skinId.toString());
      prefs.setInt('total_coins', totalCoins); prefs.setStringList('owned_skins', ownedSkins);
      poolTap.start(volume: 1.0);
      HapticFeedback.lightImpact();
    }
  }

  void equipSkin(int skinId) {
    if (ownedSkins.contains(skinId.toString())) {
      selectedSkinIndex = skinId; prefs.setInt('current_skin', selectedSkinIndex);
      player.updateSkin(skinId); poolTap.start(volume: 1.0);
      HapticFeedback.selectionClick();
    }
  }

  @override
  void update(double dt) {
    if (!isPlaying || isGameOver) {
      for (var child in world.children) {
        if (child is DebrisParticle || child is SparkleParticle || child is ShockwaveEffect) {
          child.update(dt);
        }
      }
      super.update(0); 
      return;
    }
    super.update(dt);

    double baseSpeed = 220.0;
    double speedBoost = survivalTime <= 20.0 ? 0 : ((survivalTime - 20.0) / 10.0) * 40.0;
    double gridSpeed = isActiveFreeze ? baseSpeed : baseSpeed + speedBoost;
    gridScrollOffset += gridSpeed * (dt * timeScale);

    powerUpSpawnTimer += dt;
    if (powerUpSpawnTimer > 7.0) { powerUpSpawnTimer = 0.0; _spawnRandomPowerUp(); }

    if (isActiveFreeze) {
      activeFreezeTimer -= dt;
      if (activeFreezeTimer <= 0) { isActiveFreeze = false; activeFreezeTimer = 0.0; }
    }

    if (slowMotionTimer > 0) {
      slowMotionTimer -= dt;
      if (slowMotionTimer <= 0) timeScale = 1.0; 
    }

    if (shakeTimer > 0) {
      shakeTimer -= dt;
      camera.viewfinder.position = Vector2((_random.nextDouble() - 0.5) * shakeIntensity * 2, (_random.nextDouble() - 0.5) * shakeIntensity * 2);
    } else if (camera.viewfinder.position.x != 0 || camera.viewfinder.position.y != 0) {
      camera.viewfinder.position = Vector2.zero();
    }

    survivalTime += dt;
    if (survivalTime >= 60.0 && currentZone == 1) { currentZone = 2; triggerZone2(); }

    if (multiplierTimer > 0) {
      multiplierTimer -= dt; 
      if (multiplierTimer <= 0) scoreMultiplier = 1; 
    }
    rawScore += dt * scoreMultiplier;

    final halfHeight = gameHeight / 2;
    for (var line in obstacles) {
      if (line.position.y > halfHeight + ForbiddenLine.lineHeight) {
        double highestY = line.position.y;
        for (var otherLine in obstacles) { if (otherLine.position.y < highestY) highestY = otherLine.position.y; }
        line.resetLine(highestY - lineSpacing);
      }
    }
  }

  void _spawnRandomPowerUp() {
    PowerUpType type;
    int rand = _random.nextInt(100);
    if (rand < 60) type = PowerUpType.coin;
    else if (rand < 80) type = PowerUpType.shield;
    else type = PowerUpType.freeze;

    double randomX = (_random.nextDouble() - 0.5) * (gameWidth - 100);
    world.add(PowerUp(type: type, position: Vector2(randomX, (-gameHeight / 2) - 100)));
  }

  void triggerZone2() {
    world.add(ZoneText(text: 'ZONE 2\nMAX SPEED', position: Vector2(0, 0)));
    shakeCamera(intensity: 15.0); 
    poolWhoosh.start(volume: 1.0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return; 
    if (!isPlaying) return;
    super.onTapDown(event);
    player.switchDirection();
    poolTap.start(volume: 0.8);
    HapticFeedback.lightImpact(); 
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true; isPlaying = false; timeScale = 0.0;
    overlays.remove('PauseButton'); overlays.remove('FreezeButton');
    
    FlameAudio.bgm.stop(); 
    // صدای کرش با فرمت wav
    FlameAudio.play('sfx/crash.wav');
    shakeCamera(intensity: 25.0); 
    HapticFeedback.heavyImpact(); 

    player.explode(); 

    if (score > highScore) { highScore = score; prefs.setInt('high_score', highScore); }
    int coinsEarned = (score / 5).floor();
    if (coinsEarned > 0) { totalCoins += coinsEarned; prefs.setInt('total_coins', totalCoins); }
    
    dart_async.Timer(const Duration(milliseconds: 800), () {
       overlays.add('GameOverMenu');
    });
  }

  void reviveGame() {
    hasRevived = true; 
    isGameOver = false;
    isPlaying = true;
    timeScale = 1.0;
    
    player.revive();
    
    // دور کردن موانع نزدیک برای جلوگیری از باخت فوری
    for (var line in obstacles) {
      if ((line.position.y - player.position.y).abs() < 300) {
        line.position.y -= 600; 
      }
    }
    
    overlays.remove('GameOverMenu');
    overlays.add('PauseButton');
    overlays.add('FreezeButton');
    
    FlameAudio.bgm.resume();
  }

  void triggerNearMiss() {
    if (isGameOver || timeScale < 1.0) return; 
    
    poolWhoosh.start(volume: 1.0); 
    
    shakeCamera(intensity: 8.0); nearMissCount++;
    HapticFeedback.mediumImpact();

    int bonusPoints = nearMissCount <= 10 ? nearMissCount : (nearMissCount <= 20 ? 5 : 10);
    rawScore += bonusPoints;
    world.add(BonusText(amount: bonusPoints, position: Vector2(player.position.x, player.position.y - 60)));

    slowMotionTimer = 0.4; timeScale = 0.3; multiplierTimer = 2.0; 
  }

  void resetGame({bool restartMusic = false}) {
    isGameOver = false; isPlaying = true; timeScale = 1.0; slowMotionTimer = 0.0; 
    rawScore = 0.0; scoreMultiplier = 1; multiplierTimer = 0.0; survivalTime = 0.0; 
    nearMissCount = 0; currentZone = 1; 

    hasShield = false; 
    freezeCharges.value = 0; 
    isActiveFreeze = false;
    activeFreezeTimer = 0.0;
    powerUpSpawnTimer = 0.0; 
    gridScrollOffset = 0.0;
    hasRevived = false; 

    // پاکسازی کامل صحنه
    world.children.whereType<PowerUp>().forEach((powerUp) => powerUp.removeFromParent());
    world.children.whereType<TrailParticle>().forEach((trail) => trail.removeFromParent());
    world.children.whereType<DebrisParticle>().forEach((d) => d.removeFromParent()); 
    world.children.whereType<SparkleParticle>().forEach((d) => d.removeFromParent());
    world.children.whereType<ShockwaveEffect>().forEach((d) => d.removeFromParent());

    shakeTimer = 0; camera.viewfinder.position = Vector2.zero();
    
    player.position = Vector2(0, gameHeight / 4); 
    player.updateSkin(selectedSkinIndex);
    player.revive(); 
    player.invincibleTimer = 0; 

    for (int i = 0; i < numberOfLines; i++) { obstacles[i].resetLine((-gameHeight / 2) - (i * lineSpacing)); }
    
    overlays.add('PauseButton'); 
    overlays.add('FreezeButton'); 
    resumeEngine(); 
    if (restartMusic) { FlameAudio.bgm.stop(); FlameAudio.bgm.play('music/bgm.mp3', volume: 0.5); }
  }
}
