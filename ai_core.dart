import 'memory.dart';
import 'knowledge.dart';
import 'decision.dart';
import 'learning.dart';
import 'brain.dart';
import 'personality.dart';
import '../database/database.dart';

/// العقل الرئيسي - المدير الذي يربط كل الأجزاء معاً
/// أي رسالة ستدخل هنا أولاً، ثم يمررها إلى بقية الوحدات ويرجع الرد النهائي
/// التسلسل: المستخدم -> تحليل السؤال -> البحث في الذاكرة -> اتخاذ القرار -> إنتاج الرد -> حفظ المعلومة الجديدة

class AICore {
  static final AICore _instance = AICore._internal();
  factory AICore() => _instance;
  AICore._internal();

  late Memory memory;
  late Knowledge knowledge;
  late DecisionEngine decisionEngine;
  late Learning learning;
  late Brain brain;
  late Personality personality;
  late AppDatabase database;

  bool _initialized = false;
  double _evolutionLevel = 50.0;

  double get evolutionLevel => _evolutionLevel;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    database = AppDatabase();
    memory = Memory();
    knowledge = Knowledge();
    decisionEngine = DecisionEngine();
    learning = Learning();
    personality = Personality();

    await database.database;
    await memory.init();
    await knowledge.init();
    await learning.init();

    brain = Brain(memory: memory, knowledge: knowledge, decisionEngine: decisionEngine);

    await _calculateEvolution();
    _initialized = true;
  }

  Future<void> _calculateEvolution() async {
    final evoData = await database.getEvolution();
    final factsCount = (await memory.getAllFacts()).length;
    final convCount = await memory.count();

    double level = 50.0;
    level += (convCount * 0.5);
    level += (factsCount * 3.0);

    if (evoData != null) {
      level = (level + (evoData['level'] as double)) / 2;
    }

    _evolutionLevel = level.clamp(0, 100);

    await database.updateEvolution(
      level: _evolutionLevel,
      conversations: convCount,
      success: convCount, // مبسط
      facts: factsCount,
      words: 0,
    );
  }

  /// معالجة رسالة - نقطة الدخول الرئيسية
  Future<Map<String, dynamic>> process(String input) async {
    if (!_initialized) await init();

    // 1. حلل وفكر
    final analysis = await brain.analyze(input);
    final decision = analysis['decision'] as Decision;
    String response = analysis['response'] as String;

    // 2. معالجة أوامر خاصة
    if (decision.intent == Decision.intent) {
      // معالجة الأوامر الزمنية
      if (decision.command == CommandType.time) {
        final now = DateTime.now();
        response = 'الساعة دلوقتي ${now.hour}:${now.minute.toString().padLeft(2, '0')} ⏰ - أوفلاين';
      } else if (decision.command == CommandType.date) {
        final now = DateTime.now();
        response = 'النهاردة ${now.day}/${now.month}/${now.year} 📅';
      } else if (decision.intent == Intent.clearMemory) {
        if (input.contains('فعلاً')) {
          await clearAll();
          response = 'تم مسح كل شيء - نوار بدأ من الصفر 🗑️';
        }
      }
    }

    // 3. حفظ المحادثة
    await memory.saveConversation(
      input: input,
      output: response,
      intent: decision.intent.toString(),
      command: decision.command.toString(),
      confidence: analysis['confidence'] as double,
      success: true,
    );

    // 4. تعلم
    await learning.learnFromConversation(input);

    // 5. تحديث التطور
    await _calculateEvolution();

    // 6. بناء مسار التفكير النهائي
    final thinking = personality.generateThinking(
      decision,
      elapsed: analysis['elapsed'] as int,
      memorySize: await memory.count(),
    );

    return {
      'thinking': thinking,
      'response': response,
      'decision': decision,
      'confidence': analysis['confidence'],
      'evolution': _evolutionLevel,
    };
  }

  Future<void> clearAll() async {
    await database.clearAll();
    _evolutionLevel = 50.0;
  }

  String getEvolutionDescription() {
    if (_evolutionLevel < 55) return 'مرحلة البداية - نوار لسه بيتعلم منك 🌱';
    if (_evolutionLevel < 65) return 'مرحلة التطور - بدأ يفهم ويتذكر 🧠';
    if (_evolutionLevel < 80) return 'مرحلة الذكاء - ذاكرة SQLite قوية 🚀';
    if (_evolutionLevel < 90) return 'مرحلة متقدمة - عقل مستقل أوفلاين 💎';
    return 'مرحلة الوعي الكامل - AI Core OS مكتمل! 👑';
  }

  Future<Map<String, dynamic>> getStats() async {
    final evo = await database.getEvolution();
    final facts = await memory.getAllFacts();
    final recent = await memory.getRecent(5);
    return {
      'evolution': _evolutionLevel,
      'description': getEvolutionDescription(),
      'evolutionData': evo,
      'facts': facts,
      'recentConversations': recent,
      'totalConversations': await memory.count(),
    };
  }
}
