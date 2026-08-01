/// محرك اتخاذ القرار
/// يقرر: هل يبحث في الذاكرة؟ هل يجيب مباشرة؟ هل يتعلم معلومة جديدة؟ هل يطلب توضيحاً؟

enum Intent {
  chat,           // محادثة عادية
  greeting,       // تحية
  identity,       // من انت
  learnName,      // تعلم الاسم - اسمي محمد
  learnAge,       // تعلم العمر - عندي 25 سنة
  learnFact,      // تعلم حقيقة عامة - احفظ اني بحب البرمجة
  memoryQuery,    // استرجاع - ما اسمي؟ كام عمري؟
  question,       // سؤال عام
  command,        // أمر تنفيذي
  clearMemory,    // مسح الذاكرة
  unknown,        // غير مفهوم
}

enum CommandType {
  none,
  openCamera,
  openSettings,
  time,
  date,
}

class Decision {
  final Intent intent;
  final CommandType command;
  final double confidence;
  final String reasoning;
  final Map<String, dynamic> entities;
  final String rawInput;

  Decision({
    required this.intent,
    this.command = CommandType.none,
    required this.confidence,
    required this.reasoning,
    this.entities = const {},
    required this.rawInput,
  });
}

class DecisionEngine {
  Decision analyze(String input) {
    final text = input.toLowerCase().trim();
    final raw = input;

    // 1. تحية
    if (_contains(text, ['السلام عليكم', 'سلام', 'هاي', 'هلا', 'مرحبا', 'أهلا', 'صباح الخير'])) {
      return Decision(intent: Intent.greeting, confidence: 0.95, reasoning: 'تحية', rawInput: raw);
    }

    // 2. هوية
    if (_contains(text, ['من انت', 'انت مين', 'اسمك ايه', 'عرف نفسك'])) {
      return Decision(intent: Intent.identity, confidence: 0.95, reasoning: 'سؤال عن هوية النظام', rawInput: raw);
    }

    // 3. تعلم الاسم: "اسمي محمد"
    if (text.contains('اسمي') && !text.contains('ما') && !text.contains('ايه')) {
      final name = _extractName(text);
      if (name.isNotEmpty) {
        return Decision(
          intent: Intent.learnName,
          confidence: 0.95,
          reasoning: 'المستخدم يعلم النظام اسمه: $name -> يجب حفظه',
          entities: {'name': name, 'fact_key': 'name', 'fact_value': name},
          rawInput: raw,
        );
      }
    }

    // 4. تعلم العمر: "عندي 25 سنة" / "عمري 25"
    if (text.contains('عندي') && text.contains('سنة') || text.contains('عمري')) {
      final age = _extractAge(text);
      if (age.isNotEmpty) {
        return Decision(
          intent: Intent.learnAge,
          confidence: 0.9,
          reasoning: 'تعلم العمر: $age',
          entities: {'age': age, 'fact_key': 'age', 'fact_value': age},
          rawInput: raw,
        );
      }
    }

    // 5. استرجاع الاسم: "كام اسمي؟" / "ما اسمي؟"
    if (_contains(text, ['ما اسمي', 'كام اسمي', 'ايه اسمي', 'تعرف اسمي', 'ما هو اسمي'])) {
      return Decision(
        intent: Intent.memoryQuery,
        confidence: 0.95,
        reasoning: 'سؤال عن الاسم - يجب البحث في الذاكرة',
        entities: {'fact_type': 'name', 'fact_key': 'name'},
        rawInput: raw,
      );
    }

    // 6. استرجاع العمر: "كام عمري؟"
    if (_contains(text, ['كام عمري', 'ما عمري', 'كم عمري', 'ايه عمري'])) {
      return Decision(
        intent: Intent.memoryQuery,
        confidence: 0.9,
        reasoning: 'سؤال عن العمر - بحث في الذاكرة',
        entities: {'fact_type': 'age', 'fact_key': 'age'},
        rawInput: raw,
      );
    }

    // 7. تعلم حقيقة عامة: "احفظ اني بحب البرمجة" / "تذكر ان..."
    if (_contains(text, ['احفظ ان', 'تذكر ان', 'اعرف ان', 'احفظ معلومة'])) {
      final fact = _extractFact(text);
      return Decision(
        intent: Intent.learnFact,
        confidence: 0.9,
        reasoning: 'المستخدم يريد تعليم النظام حقيقة جديدة: $fact',
        entities: {'fact_key': 'custom_${DateTime.now().millisecondsSinceEpoch}', 'fact_value': fact},
        rawInput: raw,
      );
    }

    // 8. أوامر
    if (_contains(text, ['افتح الكاميرا', 'شغل الكاميرا'])) {
      return Decision(intent: Intent.command, command: CommandType.openCamera, confidence: 0.95, reasoning: 'أمر فتح الكاميرا', rawInput: raw);
    }
    if (_contains(text, ['الساعة كام', 'كم الساعة'])) {
      return Decision(intent: Intent.command, command: CommandType.time, confidence: 0.9, reasoning: 'سؤال عن الوقت', rawInput: raw);
    }
    if (_contains(text, ['التاريخ', 'النهاردة ايه'])) {
      return Decision(intent: Intent.command, command: CommandType.date, confidence: 0.9, reasoning: 'سؤال عن التاريخ', rawInput: raw);
    }

    // 9. مسح الذاكرة
    if (_contains(text, ['امسح الذاكرة', 'احذف الذاكرة', 'انسى كل حاجة'])) {
      return Decision(intent: Intent.clearMemory, confidence: 0.95, reasoning: 'طلب مسح الذاكرة', rawInput: raw);
    }

    // 10. سؤال عام
    if (text.contains('؟') || text.startsWith('ما ') || text.startsWith('كيف') || text.startsWith('ليه') || text.startsWith('ازاي')) {
      return Decision(intent: Intent.question, confidence: 0.7, reasoning: 'سؤال عام - بحث في قاعدة المعرفة', rawInput: raw);
    }

    // افتراضي
    return Decision(intent: Intent.chat, confidence: 0.6, reasoning: 'محادثة عامة', rawInput: raw);
  }

  bool _contains(String text, List<String> keywords) {
    for (var k in keywords) if (text.contains(k)) return true;
    return false;
  }

  String _extractName(String text) {
    // "اسمي محمد" -> "محمد"
    // "اسمي محمد أحمد" -> "محمد أحمد"
    final parts = text.split('اسمي');
    if (parts.length > 1) {
      return parts.last.trim().split(RegExp(r'[؟!.,]')).first.trim();
    }
    return '';
  }

  String _extractAge(String text) {
    // استخراج رقم من "عندي 25 سنة"
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match?.group(1) ?? '';
  }

  String _extractFact(String text) {
    for (var prefix in ['احفظ ان', 'تذكر ان', 'اعرف ان', 'احفظ معلومة']) {
      if (text.contains(prefix)) {
        return text.split(prefix).last.trim();
      }
    }
    return text;
  }
}
