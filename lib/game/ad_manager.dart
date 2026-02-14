import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:flutter/material.dart';
// ایمپورت FlameAudio رو پاک کردیم چون دیگه دخالت نمی‌کنیم

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
    // اینجا دیگه موزیک رو قطع نمی‌کنیم. اگر تداخل کرد هم اشکالی نداره (طبق خواست شما)
    try {
      String responseId = await TapsellPlus.instance.requestRewardedVideoAd(rewardZoneId);

      await TapsellPlus.instance.showRewardedVideoAd(
        responseId,
        onOpened: (map) => debugPrint('Ad Opened'),
        onClosed: (map) => debugPrint('Ad Closed'),
        onRewarded: (map) {
          debugPrint('💎 User Rewarded!');
          onRewarded(); 
        },
        onError: (map) {
          debugPrint('❌ Ad Error: ${map['message']}');
          if (onError != null) onError();
          // اسنک‌بار خطا
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad failed to load.')),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Ad Request Error: $e');
      if (onError != null) onError();
    }
  }
}
