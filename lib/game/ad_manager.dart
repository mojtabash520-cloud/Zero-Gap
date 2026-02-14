import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:flutter/material.dart';

class AdManager {
  // کلیدهای شما
  static const String appId =
      'rhkpmtgkgoplimccapeecbrgcedlnndofpakionmffckhmhlmgdpgghkfnqfasqasoscrd';
  static const String rewardZoneId = '698fc70c8f329b41b224ebfd';

  // === Safe Init: طبق تجربه شما برای جلوگیری از فریز شدن UI ===
  static Future<void> init() async {
    try {
      await TapsellPlus.instance.initialize(appId);
      debugPrint("✅ Tapsell Initialized Successfully");
    } catch (e) {
      debugPrint("⚠️ Tapsell Init Failed (Safe Catch): $e");
    }
  }

  // متد استاندارد Request -> Show
  static void showRewardAd(
    BuildContext context, {
    required VoidCallback onRewarded,
    VoidCallback? onError,
  }) async {
    try {
      // 1. Request
      String responseId = await TapsellPlus.instance.requestRewardedVideoAd(
        rewardZoneId,
      );

      // 2. Show
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad failed. Please check your internet.'),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Ad Request Error: $e');
      if (onError != null) onError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ad available right now.')),
      );
    }
  }
}
