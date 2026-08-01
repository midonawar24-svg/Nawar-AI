import '../database/database.dart';
import '../database/models.dart';

/// الذاكرة - مسؤولة عن تخزين واسترجاع المعلومات بدون إنترنت
/// في البداية تدعم: حفظ الاسم، العمر، أي معلومة يتعلمها، واسترجاعها لاحقاً
class Memory {
  final AppDatabase _db = AppDatabase();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _db.database; // تهيئة DB
    _initialized = true;
  }

  // حفظ حقيقة - مثل: الاسم
  Future<void> saveFact(String key, String value) async {
    await _db.saveFact(key, value, source: 'user_told');
  }

  // حفظ أي معلومة يتعلمها
  Future<void> saveInfo(String key, String value) async {
    await _db.saveFact(key, value, source: 'learned');
  }

  Future<String?> getFact(String key) async {
    return await _db.getFact(key);
  }

  Future<List<FactModel>> getAllFacts() async {
    return await _db.getAllFacts();
  }

  // حفظ محادثة
  Future<void> saveConversation({
    required String input,
    required String output,
    required String intent,
    required String command,
    required double confidence,
    required bool success,
  }) async {
    final conv = ConversationModel(
      input: input,
      output: output,
      intent: intent,
      command: command,
      confidence: confidence,
      success: success,
      timestamp: DateTime.now(),
    );
    await _db.insertConversation(conv);
  }

  Future<List<ConversationModel>> getRecent(int limit) async {
    return await _db.getRecentConversations(limit);
  }

  Future<List<ConversationModel>> search(String query) async {
    return await _db.searchConversations(query);
  }

  // البحث عن إجابة سابقة مشابهة
  Future<String?> findSimilarAnswer(String input) async {
    final results = await search(input);
    if (results.isNotEmpty && results.first.confidence > 0.85) {
      return results.first.output;
    }
    return null;
  }

  Future<int> count() async => await _db.getConversationsCount();

  Future<void> clear() async => await _db.clearAll();
}
