import '../database/database.dart';

/// التعلم - كل مرة تتحدث معه: يزيد قاعدة المعرفة، يتذكر الكلمات الجديدة، يحسن إجاباته
class Learning {
  final AppDatabase _db = AppDatabase();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _db.database;
    _initialized = true;
  }

  Future<void> learnFromConversation(String input) async {
    // 1. تعلم الكلمات الجديدة
    final words = input.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    for (var word in words) {
      final clean = word.toLowerCase().replaceAll(RegExp(r'[؟!.,،]'), '').trim();
      if (clean.length > 2) {
        await _db.saveOrUpdateWord(clean);
      }
    }
  }

  Future<void> recordSuccess(String skill) async {
    // زيادة الثقة في مهارة معينة
    // يمكن تطويرها لاحقاً بجدول مهارات
  }

  Future<Map<String, dynamic>> getStats() async {
    final evo = await _db.getEvolution();
    final facts = await _db.getAllFacts();
    return {
      'totalWords': 0, // سيتم حسابه من جدول words
      'facts': facts.length,
      'evolution': evo,
    };
  }
}
