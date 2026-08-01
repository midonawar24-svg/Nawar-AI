import '../database/database.dart';

/// قاعدة المعرفة - Knowledge Base
/// تخزين معلومات عامة بدون إنترنت
class Knowledge {
  final AppDatabase _db = AppDatabase();
  Map<String, String> _builtinKnowledge = {};

  Future<void> init() async {
    _builtinKnowledge = {
      'من انت': 'أنا نوار AI OS v2 - عقل مستقل 100% أوفلاين، عندي ذاكرة وقاعدة معرفة وبتعلم منك بدون Gemini أو OpenAI',
      'ما هي قدراتك': 'أتذكر اسمك وعمرك وأي معلومة تقولها، بفهم أوامر زي افتح الكاميرا والساعة كام، بتطور مع كل محادثة، وكل ده أوفلاين',
      'كيف تعمل': 'عندي 5 مكونات: ذاكرة، عقل، قرارات، تعلم، معرفة - كله شغال على تليفونك بدون إنترنت',
      'هل تحتاج انترنت': 'لا، أنا شغال 100% أوفلاين، ذاكرتي وقاعدة معرفتي كلها SQLite على جهازك',
      'من صنعك': 'محمد نوار - نظام تشغيل ذكاء اصطناعي خاص ومستقل',
      'ما هو هدفك': 'أكون مساعدك الخاص اللي بيتعلم منك وبيتطور معاك، بدون ما يبعت بياناتك لحد',
    };
  }

  Future<String?> search(String query) async {
    final q = query.toLowerCase().trim();
    
    // بحث في المعرفة المدمجة
    for (var entry in _builtinKnowledge.entries) {
      if (q.contains(entry.key.toLowerCase()) || entry.key.toLowerCase().contains(q)) {
        return entry.value;
      }
    }

    // بحث في الحقائق المحفوظة من المستخدم (عبر DB)
    final fact = await _db.getFact(q);
    if (fact != null) return fact;

    // بحث تقريبي في كل الحقائق
    final allFacts = await _db.getAllFacts();
    for (var f in allFacts) {
      if (q.contains(f.key.toLowerCase())) {
        return '${f.key}: ${f.value}';
      }
    }

    return null;
  }

  Future<void> addKnowledge(String question, String answer) async {
    _builtinKnowledge[question.toLowerCase()] = answer;
  }
}
