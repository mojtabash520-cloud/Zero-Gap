import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart'; // <--- اضافه کردن این خط

class AdManager {
  static const String appId = 'rhkpmtgkgoplimccapeecbrgcedlnndofpakionmffckhmhlmgdpgghkfnqfasqasoscrd';
  static const String rewardZoneId = '698fc70c8f329b41b224ebfd';

  static Future<void> init() async {
    try {
      await TapsellPlus.instance.initialize(appId);
    } catch (e) {
      debugPrint("⚠️ Tapsell Init Failed: $e");
    }
  }

  static void showRewardAd(BuildContext context, {required VoidCallback onRewarded, VoidCallback? onError}) async {
    // 1. قطع موقت موزیک بازی
    FlameAudio.bgm.pause();

    try {
      String responseId = await TapsellPlus.instance.requestRewardedVideoAd(rewardZoneId);

      await TapsellPlus.instance.showRewardedVideoAd(
        responseId,
        onOpened: (map) => debugPrint('Ad Opened'),
        onClosed: (map) {
          debugPrint('Ad Closed');
          // 2. وصل مجدد موزیک بازی
          FlameAudio.bgm.resume();
        },
        onRewarded: (map) {
          debugPrint('💎 User Rewarded!');
          onRewarded(); 
        },
        onError: (map) {
          debugPrint('❌ Ad Error: ${map['message']}');
          // در صورت ارور هم موزیک باید برگردد
          FlameAudio.bgm.resume();
          if (onError != null) onError();
        },
      );
    } catch (e) {
      // در صورت ارور درخواست هم موزیک باید برگردد
      FlameAudio.bgm.resume();
      debugPrint('❌ Ad Request Error: $e');
      if (onError != null) onError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ad available right now.')),
      );
    }
  }
}
