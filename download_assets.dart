import 'dart:io';

void main() async {
  print('🎧 تلاش مجدد برای دانلود فایل‌های صوتی...');

  // لینک‌های جدید و سالم (از پروژه Pixel Adventure و Audioplayers)
  final assets = {
    // موزیک پس‌زمینه (این قبلاً سالم بود ولی دوباره می‌گذاریم)
    'assets/audio/music/bgm.mp3':
        'https://raw.githubusercontent.com/bluefireteam/audioplayers/main/packages/audioplayers/example/assets/ambient_c_motion.mp3',

    // صدای تپ (صدای پرش - جایگزین تپ)
    'assets/audio/sfx/tap.wav':
        'https://raw.githubusercontent.com/erickzanardo/pixel_adventure/master/assets/audio/jump.wav',

    // صدای باخت (صدای ضربه - جایگزین تصادف)
    'assets/audio/sfx/crash.wav':
        'https://raw.githubusercontent.com/erickzanardo/pixel_adventure/master/assets/audio/hit.wav',

    // صدای Near Miss (صدای جمع کردن آیتم - جایگزین وووش)
    'assets/audio/sfx/whoosh.wav':
        'https://raw.githubusercontent.com/erickzanardo/pixel_adventure/master/assets/audio/collect_fruit.wav',
  };

  for (final entry in assets.entries) {
    final path = entry.key;
    final url = entry.value;

    await downloadFile(url, path);
  }

  print('\n✅ تمام فایل‌ها با موفقیت دانلود شدند!');
  print('👉 حالا دستور "flutter run" را اجرا کنید.');
}

Future<void> downloadFile(String url, String savePath) async {
  final file = File(savePath);

  // اگر فایل وجود داشت، پاکش می‌کنیم تا نسخه جدید دانلود شود
  if (file.existsSync()) {
    file.deleteSync();
  }

  if (!file.parent.existsSync()) {
    file.parent.createSync(recursive: true);
  }

  print('⬇️ در حال دانلود: $savePath ...');

  try {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode == 200) {
      final bytes = await response.fold<List<int>>([], (a, b) => a..addAll(b));
      await file.writeAsBytes(bytes);
      print('   ✔️ ذخیره شد.');
    } else {
      print('   ❌ خطا در دانلود (کد ${response.statusCode})');
    }
  } catch (e) {
    print('   ❌ ارور ارتباطی: $e');
  }
}
