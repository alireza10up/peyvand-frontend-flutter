import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class AiService {
  Future<String> enhancePost(String content) async {
    await Future.delayed(Duration(seconds: 1));
    if (content.isEmpty) return '';
    return 'بهبود یافته با هوش مصنوعی: $content\n[گرامر و وضوح این متن توسط هوش مصنوعی ارتقا یافته است.]';
  }

  Future<String> getSimilarProfiles(List<String> skills) async {
    await Future.delayed(Duration(seconds: 1));
    return 'بر اساس مهارت‌های شما (${skills.join("، ")}), این افراد ممکن است برای شما جالب باشند...';
  }

  Future<String> getChatResponse(String message) async {
    await Future.delayed(Duration(seconds: 1));
    if (message.toLowerCase().contains('سلام')) {
      return 'سلام! چطور می‌توانم در مسیر حرفه‌ای به شما کمک کنم؟';
    }
    return 'پیام شما دریافت شد: "$message". در حال پردازش...';
  }

  Future<List<String>> getSuggestions(String userProfile) async {
    await Future.delayed(Duration(seconds: 1));
    return [
      'پروفایل خود را با آخرین دستاوردهایتان به‌روز کنید.',
      'با ۵ متخصص جدید در حوزه کاری خود ارتباط برقرار کنید.',
      'یک مقاله مرتبط با صنعت خود به اشتراک بگذارید.'
    ];
  }

  Future<String> enhanceText(String currentText) async {
    await Future.delayed(Duration(seconds: 1));
    if (currentText.isEmpty) return '';
    return "متن بهبود یافته توسط هوش مصنوعی:\n$currentText\n... شفاف‌تر و جذاب‌تر!";
  }

  Future<File?> generateImageWithAI(String prompt) async {
    await Future.delayed(Duration(seconds: 2));
    try {
      final byteData = await rootBundle.load('assets/images/logo.png');
      final buffer = byteData.buffer;
      final tempDir = await getTemporaryDirectory();
      final fileName = 'ai_generated_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      return file;
    } catch (e) {
      print("Error generating mock AI image: $e");
      return null;
    }
  }
}