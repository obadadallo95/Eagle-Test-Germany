import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/question.dart';
import '../debug/app_logger.dart';
import '../config/api_config.dart';
import '../storage/hive_service.dart';

/// خدمة AI Tutor لشرح الأسئلة باستخدام Groq API (مجاني وسريع)
/// 
/// **Important:** قبل استخدام هذه الخدمة، يجب الحصول على API Key من:
/// 1. اذهب إلى https://console.groq.com/keys
/// 2. سجل دخول أو أنشئ حساب جديد (مجاني تماماً)
/// 3. أنشئ API Key جديد
/// 4. استبدل 'YOUR_GROQ_API_KEY_HERE' في الكود بـ API Key الخاص بك
/// 5. **لا تضع API Key مباشرة في الكود** - استخدم environment variables أو secure storage
/// 
/// **مزايا Groq:**
/// - ✅ مجاني تماماً (لا يحتاج بطاقة ائتمان)
/// - ✅ سريع جداً (يستخدم TPU)
/// - ✅ يدعم العربية بشكل ممتاز
/// - ✅ API مشابه لـ OpenAI (سهل الاستخدام)
class AiTutorService {
  // API Key من ApiConfig (ملف آمن)
  // ⚠️ **مهم:** ملف api_config.dart موجود في .gitignore ولا يتم رفعه إلى Git
  static String get _apiKey => ApiConfig.groqApiKey;
  
  // Model من ApiConfig
  static String get _model => ApiConfig.groqModel;
  /// شرح السؤال والإجابة الصحيحة باللغة المطلوبة باستخدام Groq API
  /// 
  /// [question] - السؤال المراد شرحه
  /// [userLanguage] - كود اللغة المطلوبة (ar, en, de, tr, uk, ru)
  /// 
  /// Returns: شرح السؤال والإجابة الصحيحة بصيغة Markdown
  static Future<String> explainQuestion({
    required Question question,
    required String userLanguage,
  }) async {
    AppLogger.functionStart('explainQuestion', source: 'AiTutorService');
    AppLogger.info('Explaining question: id=${question.id}, language=$userLanguage', source: 'AiTutorService');
    
    // إذا لم يتم تعيين API Key، نستخدم mock response
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      AppLogger.warn('Groq API Key not set, using mock explanation', source: 'AiTutorService');
      
      // الحصول على الإجابة الصحيحة بشكل آمن
      Answer correctAnswer;
      try {
        correctAnswer = question.answers.firstWhere(
          (answer) => answer.id == question.correctAnswerId,
        );
      } catch (e) {
        // إذا لم يتم العثور على الإجابة الصحيحة، نستخدم الأولى
        correctAnswer = question.answers.isNotEmpty 
            ? question.answers.first 
            : throw Exception('No answers available');
      }
      
      final mockResult = _getMockExplanation(
        questionText: question.getText('de'),
        correctAnswerText: correctAnswer.getText('de'),
        language: userLanguage,
      );
      AppLogger.functionEnd('explainQuestion', source: 'AiTutorService', result: 'mock');
      return mockResult;
    }

    try {
      AppLogger.info('Using Groq API', source: 'AiTutorService');
      
      // الحصول على نص السؤال وجميع الإجابات
      final questionText = question.getText('de');
      
      // بناء قائمة بجميع الإجابات
      final allAnswers = question.answers.map((answer) {
        final isCorrect = answer.id == question.correctAnswerId;
        return '${isCorrect ? "✓" : "✗"} ${answer.getText('de')}';
      }).join('\n');

      // تحويل كود اللغة إلى اسم اللغة
      final languageName = _getLanguageName(userLanguage);

      // بناء Prompt محسّن ومبسّط
      const systemPrompt = 'You are an expert German Citizenship Tutor. Explain answers clearly and concisely in the requested language. Use Markdown with **bold** for keywords. Keep explanations 2-4 sentences (80-120 words).';
      
      final userPrompt = '''Question: $questionText

Answers:
$allAnswers

Explain in $languageName why the correct answer (✓) is right. Include context if relevant. Write ONLY in $languageName.''';

      // استدعاء Groq API
      AppLogger.event('Calling Groq API', source: 'AiTutorService');
      AppLogger.info('Question text length: ${questionText.length}', source: 'AiTutorService');
      AppLogger.info('User prompt length: ${userPrompt.length}', source: 'AiTutorService');
      AppLogger.info('System prompt length: ${systemPrompt.length}', source: 'AiTutorService');
      
      final stopwatch = Stopwatch()..start();
      
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
      AppLogger.info('Using model: $_model', source: 'AiTutorService');
      AppLogger.info('API Key length: ${_apiKey.length}', source: 'AiTutorService');
      
      http.Response response;
      try {
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content': systemPrompt,
              },
              {
                'role': 'user',
                'content': userPrompt,
              },
            ],
            'max_tokens': 250,
            'temperature': 0.5,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            AppLogger.error('API call timeout after 30 seconds', source: 'AiTutorService');
            throw Exception('API call timeout');
          },
        );
      } catch (e) {
        AppLogger.error('HTTP request failed', source: 'AiTutorService', error: e);
        rethrow;
      }
      
      stopwatch.stop();
      AppLogger.performance('Groq API call', stopwatch.elapsed, source: 'AiTutorService');
      AppLogger.info('API response status: ${response.statusCode}', source: 'AiTutorService');
      AppLogger.info('API response body length: ${response.body.length}', source: 'AiTutorService');

      if (response.statusCode != 200) {
        AppLogger.error('API returned status ${response.statusCode}', source: 'AiTutorService');
        final errorBody = response.body;
        AppLogger.error('API error response: $errorBody', source: 'AiTutorService');
        
        // محاولة استخراج رسالة الخطأ من JSON
        try {
          final errorData = jsonDecode(errorBody) as Map<String, dynamic>?;
          final errorMessage = errorData?['error']?['message'] as String?;
          if (errorMessage != null) {
            AppLogger.error('API error message: $errorMessage', source: 'AiTutorService');
            throw Exception('API error: $errorMessage');
          }
        } catch (_) {
          // إذا فشل parsing، نستخدم الرسالة الأصلية
        }
        
        throw Exception('API error: ${response.statusCode} - $errorBody');
      }

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.info('Response data keys: ${responseData.keys.join(", ")}', source: 'AiTutorService');
      } catch (e) {
        AppLogger.error('Failed to parse API response as JSON', source: 'AiTutorService', error: e);
        AppLogger.error('Response body: ${response.body}', source: 'AiTutorService');
        throw Exception('Invalid JSON response from API');
      }
      
      // استخراج النص من الرد
      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        AppLogger.error('No choices in API response', source: 'AiTutorService');
        AppLogger.error('Response data: $responseData', source: 'AiTutorService');
        throw Exception('No response from AI');
      }
      
      final message = choices[0]['message'] as Map<String, dynamic>?;
      if (message == null) {
        AppLogger.error('No message in choices[0]', source: 'AiTutorService');
        AppLogger.error('Choices[0]: ${choices[0]}', source: 'AiTutorService');
        throw Exception('Invalid response structure from AI');
      }
      
      final explanation = message['content'] as String? ?? '';

      if (explanation.isEmpty) {
        AppLogger.error('Empty response from AI', source: 'AiTutorService');
        AppLogger.error('Message content: ${message['content']}', source: 'AiTutorService');
        throw Exception('Empty response from AI');
      }

      AppLogger.event('AI explanation received', source: 'AiTutorService', data: {
        'length': explanation.length,
        'model': _model,
      });
      
      // تسجيل استخدام AI Tutor (بعد نجاح الاستدعاء فقط)
      await HiveService.recordAiTutorUsage();
      
      AppLogger.functionEnd('explainQuestion', source: 'AiTutorService', result: 'success');
      return explanation.trim();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get AI explanation', source: 'AiTutorService', error: e, stackTrace: stackTrace);
      
      // Log detailed error information
      if (e.toString().contains('401') || e.toString().contains('invalid_api_key')) {
        AppLogger.error('Groq API Key is invalid or expired', source: 'AiTutorService');
      } else if (e.toString().contains('429') || e.toString().contains('rate_limit')) {
        AppLogger.error('Groq API rate limit exceeded - too many requests', source: 'AiTutorService');
      } else if (e.toString().contains('quota') || e.toString().contains('insufficient')) {
        AppLogger.error('Groq API quota exceeded', source: 'AiTutorService');
      } else if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        AppLogger.error('Network error - check internet connection', source: 'AiTutorService');
      }
      
      // في حالة الخطأ، نرجع رسالة خطأ باللغة المطلوبة
      return _getErrorMessage(userLanguage, e.toString());
    }
  }

  /// تحويل كود اللغة إلى اسم اللغة
  static String _getLanguageName(String languageCode) {
    const languageMap = {
      'ar': 'Arabic',
      'en': 'English',
      'de': 'German',
      'tr': 'Turkish',
      'uk': 'Ukrainian',
      'ru': 'Russian',
    };
    return languageMap[languageCode] ?? 'English';
  }

  /// رسالة خطأ باللغة المطلوبة
  static String _getErrorMessage(String languageCode, String error) {
    final errorMessages = {
      'ar': 'عذراً، حدث خطأ في تحميل الشرح. يرجى المحاولة مرة أخرى لاحقاً.',
      'en': 'Sorry, an error occurred while loading the explanation. Please try again later.',
      'de': 'Entschuldigung, beim Laden der Erklärung ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.',
      'tr': 'Üzgünüz, açıklama yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
      'uk': 'Вибачте, сталася помилка під час завантаження пояснення. Будь ласка, спробуйте пізніше.',
      'ru': 'Извините, произошла ошибка при загрузке объяснения. Пожалуйста, попробуйте позже.',
    };
    return errorMessages[languageCode] ?? errorMessages['en']!;
  }
  
  /// Mock explanation (سيتم استبداله بـ API call)
  static String _getMockExplanation({
    required String questionText,
    required String correctAnswerText,
    required String language,
  }) {
    final explanations = {
      'ar': 'الإجابة الصحيحة هي "$correctAnswerText" لأنها تمثل المفهوم الصحيح في القانون الألماني. هذا السؤال يتعلق بـ "$questionText" وهو جزء مهم من اختبار الجنسية الألمانية.',
      'en': 'The correct answer is "$correctAnswerText" because it represents the correct concept in German law. This question relates to "$questionText" and is an important part of the German citizenship test.',
      'de': 'Die richtige Antwort ist "$correctAnswerText", weil sie das richtige Konzept im deutschen Recht darstellt. Diese Frage bezieht sich auf "$questionText" und ist ein wichtiger Teil des Einbürgerungstests.',
      'tr': 'Doğru cevap "$correctAnswerText" çünkü Alman hukukundaki doğru kavramı temsil ediyor. Bu soru "$questionText" ile ilgilidir ve Alman vatandaşlık testinin önemli bir parçasıdır.',
      'uk': 'Правильна відповідь - "$correctAnswerText", оскільки вона представляє правильне поняття в німецькому праві. Це питання стосується "$questionText" і є важливою частиною тесту на німецьке громадянство.',
      'ru': 'Правильный ответ - "$correctAnswerText", потому что он представляет правильное понятие в немецком праве. Этот вопрос относится к "$questionText" и является важной частью теста на немецкое гражданство.',
    };
    
    return explanations[language] ?? explanations['en']!;
  }
  
  /// **ملاحظات مهمة:**
  /// 
  /// 1. **الحصول على Groq API Key (مجاني تماماً):**
  ///    - اذهب إلى https://console.groq.com/keys
  ///    - سجل دخول أو أنشئ حساب جديد (لا يحتاج بطاقة ائتمان)
  ///    - أنشئ API Key جديد
  ///    - ✅ مجاني تماماً بدون حدود للتجريب
  /// 
  /// 2. **النماذج المتاحة:**
  ///    - llama-3.1-8b-instant: سريع ومجاني (الافتراضي)
  ///    - mixtral-8x7b-32768: أكثر دقة
  ///    - llama-3.1-70b-versatile: أقوى لكن أبطأ
  /// 
  /// 3. **المزايا:**
  ///    - ✅ مجاني تماماً
  ///    - ✅ سريع جداً (يستخدم TPU)
  ///    - ✅ يدعم العربية بشكل ممتاز
  ///    - ✅ API مشابه لـ OpenAI (سهل الاستخدام)
  /// 
  /// 4. **الأمان:**
  ///    - ⚠️ لا تضع API Key مباشرة في الكود
  ///    - استخدم environment variables أو flutter_dotenv
  ///    - في الإنتاج، استخدم secure storage
}

