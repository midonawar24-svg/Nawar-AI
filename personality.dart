import 'dart:math';
import 'decision.dart';

class Personality {
  static const String name = 'نوار';
  static const String version = 'AI Core OS V2 - Offline';
  final Random _random = Random();

  String generateGreeting() {
    final greetings = [
      'أهلاً! أنا نوار، عقلك المستقل الجديد - شغال 100% أوفلاين بدون Gemini 😎',
      'يا هلا! نوار OS v2 هنا، بذاكرة حقيقية SQLite وبتعلم منك',
      'السلامو عليكو! نوار V2 - ذكاء خاص بيك، مش بيبعت بياناتك لحد 🚀',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }

  String generateThinking(Decision decision, {int elapsed = 0, int memorySize = 0}) {
    return '''
🧠 Nawar AI Core V2 - تحليل أوفلاين:
- المدخل: ${decision.rawInput}
- النية: ${decision.intent}
- الأمر: ${decision.command}
- الثقة: ${(decision.confidence * 100).toStringAsFixed(0)}%
- المنطق: ${decision.reasoning}
- الذاكرة: $memorySize رسالة محفوظة في SQLite
- الكيانات: ${decision.entities}
- الزمن: ${elapsed}ms
- الحالة: أوفلاين 100% - بدون API
''';
  }

  String generateResponse(Decision decision, String baseResponse) {
    return baseResponse;
  }
}
