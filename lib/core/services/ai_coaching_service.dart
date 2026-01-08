import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/question.dart';
import '../debug/app_logger.dart';
import '../storage/hive_service.dart';
import '../config/api_config.dart';

/// خدمة AI Coaching لتقديم نصائح دراسية مخصصة
/// تحلل أداء المستخدم وتحدد أضعف المواضيع وتقدم خطة دراسة
class AiCoachingService {
  /// تحليل أداء المستخدم وتحديد أضعف 3 مواضيع
  static Future<List<TopicPerformance>> getWeakestTopics(List<Question> allQuestions) async {
    AppLogger.functionStart('getWeakestTopics', source: 'AiCoachingService');
    
    final progress = HiveService.getUserProgress();
    if (progress == null) {
      AppLogger.warn('No user progress found', source: 'AiCoachingService');
      return [];
    }

    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null || answers.isEmpty) {
      AppLogger.warn('No answers found', source: 'AiCoachingService');
      return [];
    }

    // حساب الأداء لكل موضوع
    final topicStats = <String, TopicPerformance>{};
    
    for (final question in allQuestions) {
      final topic = question.topic ?? question.categoryId;
      if (topic.isEmpty) continue;

      topicStats.putIfAbsent(topic, () => TopicPerformance(
        topic: topic,
        total: 0,
        correct: 0,
        answered: 0,
      ));

      final answerData = answers[question.id.toString()];
      if (answerData != null && answerData is Map) {
        topicStats[topic]!.total++;
        topicStats[topic]!.answered++;
        if (answerData['isCorrect'] == true) {
          topicStats[topic]!.correct++;
        }
      } else {
        topicStats[topic]!.total++;
      }
    }

    // حساب النسبة المئوية لكل موضوع
    final topicPerformances = topicStats.values.map((stats) {
      final accuracy = stats.answered > 0 
          ? (stats.correct / stats.answered * 100).round()
          : 0;
      return TopicPerformance(
        topic: stats.topic,
        total: stats.total,
        correct: stats.correct,
        answered: stats.answered,
        accuracy: accuracy,
      );
    }).toList();

    // ترتيب حسب الأداء (الأضعف أولاً)
    topicPerformances.sort((a, b) {
      // أولاً: المواضيع التي لم يتم الإجابة عليها
      if (a.answered == 0 && b.answered > 0) return -1;
      if (b.answered == 0 && a.answered > 0) return 1;
      if (a.answered == 0 && b.answered == 0) return 0;
      
      // ثانياً: حسب الدقة
      return a.accuracy.compareTo(b.accuracy);
    });

    // إرجاع أضعف 3 مواضيع
    final weakest = topicPerformances.take(3).toList();
    
    AppLogger.event('Weakest topics identified', source: 'AiCoachingService', data: {
      'count': weakest.length,
      'topics': weakest.map((t) => '${t.topic}: ${t.accuracy}%').toList(),
    });
    
    AppLogger.functionEnd('getWeakestTopics', source: 'AiCoachingService', result: weakest.length);
    return weakest;
  }

  /// الحصول على نصيحة AI مخصصة بناءً على أداء المستخدم
  static Future<String> getCoachingAdvice({
    required List<TopicPerformance> weakestTopics,
    required String userLanguage,
    int? overallScore,
    int? streak,
  }) async {
    AppLogger.functionStart('getCoachingAdvice', source: 'AiCoachingService');
    
    // إذا لم يكن هناك مواضيع ضعيفة، نعطي نصيحة عامة
    if (weakestTopics.isEmpty) {
      return _getDefaultAdvice(userLanguage, overallScore, streak);
    }

    // بناء البرومبت
    final topicInfo = weakestTopics.map((t) {
      return '${_getTopicName(t.topic, userLanguage)}: ${t.accuracy}% accuracy (${t.answered}/${t.total} answered)';
    }).join(', ');

    final languageName = _getLanguageName(userLanguage);
    final overallScoreText = overallScore != null ? '$overallScore%' : 'unknown';
    final streakText = streak != null && streak > 0 ? '$streak days' : 'just starting';

    final systemPrompt = 'You are a friendly and motivating German Citizenship Test coach. Give short, actionable study advice in $languageName. Keep it to 3 sentences (60-90 words). Be encouraging and specific.';
    
    final userPrompt = '''The user has an overall score of $overallScoreText and a study streak of $streakText.

Their weakest topics are: $topicInfo

Give them a personalized 3-sentence study plan in $languageName. Focus on improving these weak areas. Be motivating and specific.''';

    try {
      // استخدام AiTutorService للاستفادة من البنية الموجودة
      // لكننا نحتاج إلى إنشاء Question وهمي للاستفادة من explainQuestion
      // أو يمكننا إنشاء دالة جديدة في AiTutorService
      
      // بدلاً من ذلك، سنستخدم نفس منطق AiTutorService مباشرة
      final advice = await _callAiApi(systemPrompt, userPrompt, userLanguage);
      
      AppLogger.functionEnd('getCoachingAdvice', source: 'AiCoachingService', result: 'success');
      return advice;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get AI coaching advice', source: 'AiCoachingService', error: e, stackTrace: stackTrace);
      return _getDefaultAdvice(userLanguage, overallScore, streak);
    }
  }

  /// استدعاء AI API (نفس منطق AiTutorService)
  static Future<String> _callAiApi(String systemPrompt, String userPrompt, String userLanguage) async {
    // استخدام نفس API Key والـ Model من ApiConfig
    const apiKey = ApiConfig.groqApiKey;
    const model = ApiConfig.groqModel;
    
    if (apiKey.isEmpty || apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      // Mock response
      return _getDefaultAdvice(userLanguage, null, null);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        AppLogger.warn('AI API returned status ${response.statusCode}', source: 'AiCoachingService');
        return _getDefaultAdvice(userLanguage, null, null);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to call AI API', source: 'AiCoachingService', error: e, stackTrace: stackTrace);
      return _getDefaultAdvice(userLanguage, null, null);
    }
  }

  static String _getDefaultAdvice(String userLanguage, int? overallScore, int? streak) {
    final isArabic = userLanguage == 'ar';
    
    if (isArabic) {
      return 'استمر في الممارسة! ركز على المواضيع التي تجدها صعبة. كل يوم من الدراسة يقربك من النجاح.';
    } else if (userLanguage == 'de') {
      return 'Weiter so! Konzentrieren Sie sich auf die Themen, die Ihnen schwerfallen. Jeder Studientag bringt Sie dem Erfolg näher.';
    } else {
      return 'Keep practicing! Focus on the topics you find difficult. Every day of study brings you closer to success.';
    }
  }

  static String _getTopicName(String topic, String userLanguage) {
    final isArabic = userLanguage == 'ar';
    
    final topicNames = {
      'system': isArabic ? 'النظام السياسي' : 'Political System',
      'rights': isArabic ? 'الحقوق الأساسية' : 'Basic Rights',
      'history': isArabic ? 'التاريخ الألماني' : 'German History',
      'society': isArabic ? 'المجتمع' : 'Society',
      'europe': isArabic ? 'ألمانيا في أوروبا' : 'Germany in Europe',
      'welfare': isArabic ? 'العمل والتعليم' : 'Work & Education',
    };
    
    return topicNames[topic] ?? topic;
  }

  static String _getLanguageName(String langCode) {
    final names = {
      'ar': 'Arabic',
      'en': 'English',
      'de': 'German',
      'tr': 'Turkish',
      'uk': 'Ukrainian',
      'ru': 'Russian',
    };
    return names[langCode] ?? 'English';
  }
}

/// نموذج لأداء موضوع معين
class TopicPerformance {
  final String topic;
  int total;
  int correct;
  int answered;
  int accuracy;

  TopicPerformance({
    required this.topic,
    required this.total,
    required this.correct,
    required this.answered,
    this.accuracy = 0,
  });
}

