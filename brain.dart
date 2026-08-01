import 'memory.dart';
import 'knowledge.dart';
import 'decision.dart';

/// محلل اللغة - Brain
/// مثال:
/// إذا قلت: "اسمي محمد" -> يفهم أنها معلومة يجب حفظها
/// إذا قلت: "كام اسمي؟" -> يفهم أنك تسأل عن الاسم
class Brain {
  final Memory memory;
  final Knowledge knowledge;
  final DecisionEngine decisionEngine;

  Brain({required this.memory, required this.knowledge, required this.decisionEngine});

  /// التسلسل الكامل:
  /// المستخدم -> تحليل السؤال -> البحث في الذاكرة -> اتخاذ القرار -> إنتاج الرد -> حفظ المعلومة الجديدة
  Future<Map<String, dynamic>> analyze(String input) async {
    final start = DateTime.now();

    // 1. تحليل السؤال
    final decision = decisionEngine.analyze(input);

    // 2. البحث في الذاكرة - هل أعرف هذه المعلومة؟
    String? memoryAnswer;
    if (decision.intent == Intent.memoryQuery) {
      final factKey = decision.entities['fact_key'] ?? decision.entities['fact_type'];
      if (factKey != null) {
        final fact = await memory.getFact(factKey);
        if (fact != null) {
          memoryAnswer = fact;
        }
      }
    }

    // 3. البحث في قاعدة المعرفة
    final kbAnswer = await knowledge.search(input);

    // 4. إنتاج الرد المبدئي
    String response = '';
    String reasoning = decision.reasoning;
    double confidence = decision.confidence;

    switch (decision.intent) {
      case Intent.learnName:
        final name = decision.entities['name'] as String;
        await memory.saveFact('name', name);
        response = 'أهلاً يا $name! حفظت اسمك وهفضل فاكره طول العمر 🎉';
        reasoning += ' -> تم حفظ الاسم في الذاكرة الدائمة';
        break;

      case Intent.learnAge:
        final age = decision.entities['age'] as String;
        await memory.saveFact('age', age);
        response = 'تمام، عندك $age سنة - حفظتها في ذاكرتي';
        break;

      case Intent.learnFact:
        final key = decision.entities['fact_key'] as String;
        final value = decision.entities['fact_value'] as String;
        await memory.saveInfo(key, value);
        response = 'حفظت معلومة جديدة: $key = $value 🧠';
        reasoning += ' -> تعلم حقيقة جديدة';
        break;

      case Intent.memoryQuery:
        if (memoryAnswer != null) {
          if (decision.entities['fact_type'] == 'name') {
            response = 'اسمك ${memoryAnswer} - فاكره من أول مرة قلتهولي 😎';
          } else {
            response = '${decision.entities['fact_type']}: $memoryAnswer';
          }
          confidence = 0.95;
        } else {
          response = 'لسه معرفش ${decision.entities['fact_type'] ?? 'المعلومة دي'}، قولي وعلمني وهحفظها فوراً';
          confidence = 0.5;
        }
        break;

      case Intent.question:
        if (kbAnswer != null) {
          response = kbAnswer;
          confidence = 0.9;
        } else if (memoryAnswer != null) {
          response = memoryAnswer;
        } else {
          response = 'سؤال ذكي! لسه بتعلم إجابته - علمني الإجابة الصح وقول "احفظ ان..."';
          confidence = 0.4;
        }
        break;

      default:
        if (kbAnswer != null) {
          response = kbAnswer;
        } else {
          response = 'فهمت قصدك! "$input" - معلومة مهمة هحفظها وأتعلم منها';
        }
    }

    final elapsed = DateTime.now().difference(start).inMilliseconds;

    return {
      'decision': decision,
      'response': response,
      'memoryAnswer': memoryAnswer,
      'kbAnswer': kbAnswer,
      'confidence': confidence,
      'reasoning': reasoning,
      'elapsed': elapsed,
    };
  }
}
