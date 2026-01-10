import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'srs_service.dart';
import 'user_preferences_service.dart';
import '../debug/app_logger.dart';

/// خدمة Hive لحفظ التقدم والإعدادات
class HiveService {
  static const String _settingsBoxName = 'settings';
  static const String _progressBoxName = 'progress';

  static const String _languageKey = 'language';
  static const String _userProgressKey = 'user_progress';
  static const String _examHistoryKey = 'exam_history';
  static const String _totalStudySecondsKey = 'total_study_seconds';
  static const String _dailyStudySecondsKey = 'daily_study_seconds';
  static const String _favoritesKey = 'favorites';
  static const String _aiTutorDailyUsageKey = 'ai_tutor_daily_usage';
  static const String _totalPointsKey = 'total_points';
  static const String _pointsHistoryKey = 'points_history';

  static Box? _settingsBox;
  static Box? _progressBox;

  /// تهيئة Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    _settingsBox = await Hive.openBox(_settingsBoxName);
    _progressBox = await Hive.openBox(_progressBoxName);

    // تهيئة SRS Service
    await SrsService.init();
  }

  /// حفظ اللغة المختارة
  static Future<void> saveLanguage(String languageCode) async {
    await _settingsBox?.put(_languageKey, languageCode);
  }

  /// جلب اللغة المحفوظة
  static String? getSavedLanguage() {
    return _settingsBox?.get(_languageKey) as String?;
  }

  /// حفظ تقدم المستخدم
  static Future<void> saveUserProgress(Map<String, dynamic> progress) async {
    AppLogger.functionStart('saveUserProgress', source: 'HiveService');
    try {
      if (_progressBox == null) {
        AppLogger.warn('Progress box is null! Initializing...',
            source: 'HiveService');
        _progressBox = await Hive.openBox(_progressBoxName);
      }
      await _progressBox?.put(_userProgressKey, progress);
      AppLogger.event('User progress saved', source: 'HiveService');

      // Verify it was saved
      final saved = _progressBox?.get(_userProgressKey);
      if (saved != null) {
        AppLogger.log('Verification: Data exists in box',
            source: 'HiveService');
      } else {
        AppLogger.warn('Data not found after save!', source: 'HiveService');
      }
      AppLogger.functionEnd('saveUserProgress', source: 'HiveService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save user progress',
          source: 'HiveService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// جلب تقدم المستخدم
  static Map<String, dynamic>? getUserProgress() {
    final data = _progressBox?.get(_userProgressKey);
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// حفظ إجابة سؤال معين
  static Future<void> saveQuestionAnswer(
      int questionId, String answerId, bool isCorrect) async {
    final progress = getUserProgress() ?? {};

    // تحويل answers بشكل آمن من _Map<dynamic, dynamic> إلى Map<String, dynamic>
    final answersRaw = progress['answers'];
    Map<String, dynamic> answers;
    if (answersRaw == null) {
      answers = {};
    } else if (answersRaw is Map) {
      answers = Map<String, dynamic>.from(
          answersRaw.map((key, value) => MapEntry(key.toString(), value)));
    } else {
      answers = {};
    }

    answers[questionId.toString()] = {
      'answerId': answerId,
      'isCorrect': isCorrect,
      'timestamp': DateTime.now().toIso8601String(),
    };
    progress['answers'] = answers;
    await saveUserProgress(progress);

    // تحديث SRS
    await SrsService.updateSrsAfterAnswer(questionId, isCorrect);

    // تحديث آخر تاريخ دراسة
    await UserPreferencesService.saveLastStudyDate(DateTime.now());

    AppLogger.event('Question answer saved', source: 'HiveService', data: {
      'questionId': questionId,
      'isCorrect': isCorrect,
    });
  }

  /// جلب إجابة سؤال معين
  static Map<String, dynamic>? getQuestionAnswer(int questionId) {
    final progress = getUserProgress();
    if (progress == null) return null;
    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null) return null;
    return answers[questionId.toString()] as Map<String, dynamic>?;
  }

  /// مسح جميع البيانات
  static Future<void> clearAll() async {
    await _settingsBox?.clear();
    await _progressBox?.clear();
  }

  /// حفظ نتيجة امتحان
  static Future<void> saveExamResult({
    required int scorePercentage,
    required int correctCount,
    required int wrongCount,
    required int totalQuestions,
    required int timeSeconds,
    required String mode, // 'full' or 'quick'
    required bool isPassed,
    required List<Map<String, dynamic>>
        questionDetails, // List of {questionId, userAnswer, correctAnswer, isCorrect}
  }) async {
    final progress = getUserProgress() ?? {};
    final examHistory = progress[_examHistoryKey] as List<dynamic>? ?? [];

    final examResult = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'date': DateTime.now().toIso8601String(),
      'scorePercentage': scorePercentage,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'totalQuestions': totalQuestions,
      'timeSeconds': timeSeconds,
      'mode': mode,
      'isPassed': isPassed,
      'questionDetails': questionDetails, // Save all question details
    };

    examHistory.insert(0, examResult); // Add to beginning

    // Keep only last 50 results
    if (examHistory.length > 50) {
      examHistory.removeRange(50, examHistory.length);
    }

    progress[_examHistoryKey] = examHistory;

    AppLogger.functionStart('saveExamResult', source: 'HiveService');
    AppLogger.info(
        'Saving exam: mode=$mode, score=$scorePercentage%, time=${timeSeconds}s, historyLength=${examHistory.length}',
        source: 'HiveService');

    try {
      await saveUserProgress(progress);

      // Verify it was saved
      final savedHistory = getExamHistory();
      AppLogger.event('Exam result saved', source: 'HiveService', data: {
        'historyLength': savedHistory.length,
      });
      if (savedHistory.isNotEmpty) {
        final lastExam = savedHistory.first;
        AppLogger.log(
            'Last exam: id=${lastExam['id']}, score=${lastExam['scorePercentage']}%, mode=${lastExam['mode']}',
            source: 'HiveService');
      }
      AppLogger.functionEnd('saveExamResult', source: 'HiveService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save exam result',
          source: 'HiveService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// جلب تفاصيل امتحان معين
  static Map<String, dynamic>? getExamDetails(int examId) {
    final history = getExamHistory();
    return history.firstWhere(
      (exam) => exam['id'] == examId,
      orElse: () => <String, dynamic>{},
    );
  }

  /// جلب تاريخ الامتحانات
  static List<Map<String, dynamic>> getExamHistory() {
    AppLogger.functionStart('getExamHistory', source: 'HiveService');
    try {
      final progress = getUserProgress();
      if (progress == null) {
        AppLogger.warn('No progress data found', source: 'HiveService');
        return [];
      }

      final examHistory = progress[_examHistoryKey];
      if (examHistory == null) {
        AppLogger.warn('No exam_history key found', source: 'HiveService');
        return [];
      }

      if (examHistory is! List) {
        AppLogger.warn(
            'exam_history is not a List, type: ${examHistory.runtimeType}',
            source: 'HiveService');
        return [];
      }

      final history = examHistory
          .map((e) {
            if (e is Map) {
              return Map<String, dynamic>.from(
                  e.map((key, value) => MapEntry(key.toString(), value)));
            }
            return <String, dynamic>{};
          })
          .where((e) => e.isNotEmpty)
          .toList();

      AppLogger.info('Found ${history.length} exams', source: 'HiveService');
      if (history.isNotEmpty) {
        AppLogger.log(
            'Latest exam: id=${history.first['id']}, score=${history.first['scorePercentage']}%, mode=${history.first['mode']}',
            source: 'HiveService');
      }

      AppLogger.functionEnd('getExamHistory',
          source: 'HiveService', result: history.length);
      return history;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get exam history',
          source: 'HiveService', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// جلب آخر نتيجة امتحان
  static Map<String, dynamic>? getLastExamResult() {
    final history = getExamHistory();
    if (history.isEmpty) return null;
    return history.first;
  }

  /// إضافة سؤال إلى المفضلة
  static Future<void> addFavorite(int questionId) async {
    AppLogger.functionStart('addFavorite', source: 'HiveService');
    AppLogger.info('Adding question $questionId to favorites',
        source: 'HiveService');
    final progress = getUserProgress() ?? {};

    final favoritesRaw = progress[_favoritesKey];
    List<int> favorites;
    if (favoritesRaw == null) {
      favorites = [];
    } else if (favoritesRaw is List) {
      favorites = favoritesRaw
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
    } else {
      favorites = [];
    }

    if (!favorites.contains(questionId)) {
      favorites.add(questionId);
      progress[_favoritesKey] = favorites;
      await saveUserProgress(progress);
      AppLogger.event('Question added to favorites',
          source: 'HiveService', data: {'questionId': questionId});
    }
    AppLogger.functionEnd('addFavorite', source: 'HiveService');
  }

  /// إزالة سؤال من المفضلة
  static Future<void> removeFavorite(int questionId) async {
    AppLogger.functionStart('removeFavorite', source: 'HiveService');
    AppLogger.info('Removing question $questionId from favorites',
        source: 'HiveService');
    final progress = getUserProgress() ?? {};

    final favoritesRaw = progress[_favoritesKey];
    List<int> favorites;
    if (favoritesRaw == null) {
      favorites = [];
    } else if (favoritesRaw is List) {
      favorites = favoritesRaw
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
    } else {
      favorites = [];
    }

    favorites.remove(questionId);
    progress[_favoritesKey] = favorites;
    await saveUserProgress(progress);
    AppLogger.event('Question removed from favorites',
        source: 'HiveService', data: {'questionId': questionId});
    AppLogger.functionEnd('removeFavorite', source: 'HiveService');
  }

  /// التحقق من كون السؤال في المفضلة
  static bool isFavorite(int questionId) {
    final progress = getUserProgress();
    if (progress == null) return false;

    final favoritesRaw = progress[_favoritesKey];
    if (favoritesRaw == null) return false;

    if (favoritesRaw is List) {
      final favorites = favoritesRaw
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
      return favorites.contains(questionId);
    }

    return false;
  }

  /// جلب قائمة المفضلة
  static List<int> getFavorites() {
    AppLogger.functionStart('getFavorites', source: 'HiveService');
    final progress = getUserProgress();
    if (progress == null) {
      AppLogger.warn('No progress data found', source: 'HiveService');
      return [];
    }

    final favoritesRaw = progress[_favoritesKey];
    if (favoritesRaw == null) {
      AppLogger.info('No favorites found', source: 'HiveService');
      return [];
    }

    if (favoritesRaw is List) {
      final favorites = favoritesRaw
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
      AppLogger.functionEnd('getFavorites',
          source: 'HiveService', result: favorites.length);
      return favorites;
    }

    AppLogger.warn('Favorites is not a List', source: 'HiveService');
    return [];
  }

  // نظام تجميع ذكي لوقت الدراسة
  static int _pendingStudySeconds = 0;
  static DateTime? _lastFlushTime;
  static Timer? _autoFlushTimer;
  static const int _minSaveIntervalSeconds = 30; // الحد الأدنى بين الحفظ (30 ثانية)
  static const int _autoFlushIntervalSeconds = 60; // الحفظ التلقائي كل دقيقة

  /// إضافة وقت دراسة (مع تجميع ذكي)
  static Future<void> addStudyTime(int seconds) async {
    if (seconds < 10) return; // Ignore sessions less than 10 seconds

    final now = DateTime.now();
    
    // إضافة الوقت إلى المجمع
    _pendingStudySeconds += seconds;

    // إذا مرت فترة كافية منذ آخر حفظ، احفظ فوراً
    if (_lastFlushTime == null || 
        now.difference(_lastFlushTime!).inSeconds >= _minSaveIntervalSeconds) {
      await _flushStudyTime();
    } else {
      // جدولة الحفظ التلقائي بعد فترة
      _scheduleAutoFlush();
    }
  }

  /// حفظ الوقت المجمع في Hive
  static Future<void> _flushStudyTime() async {
    if (_pendingStudySeconds < 10) {
      _pendingStudySeconds = 0;
      return;
    }

    final secondsToSave = _pendingStudySeconds;
    _pendingStudySeconds = 0;
    _lastFlushTime = DateTime.now();

    final progress = getUserProgress() ?? {};

    // Update total study time
    final totalSeconds =
        (progress[_totalStudySecondsKey] as int? ?? 0) + secondsToSave;
    progress[_totalStudySecondsKey] = totalSeconds;

    // Update daily study time
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dailyStudyRaw = progress[_dailyStudySecondsKey];
    Map<String, dynamic> dailyStudy;
    if (dailyStudyRaw == null || dailyStudyRaw is! Map) {
      dailyStudy = {};
    } else {
      dailyStudy = Map<String, dynamic>.from(
          (dailyStudyRaw).map((key, value) => MapEntry(key.toString(), value)));
    }
    final todaySeconds = (dailyStudy[dateKey] as int? ?? 0) + secondsToSave;
    dailyStudy[dateKey] = todaySeconds;
    progress[_dailyStudySecondsKey] = dailyStudy;

    await saveUserProgress(progress);

    AppLogger.event('Study time added', source: 'HiveService', data: {
      'seconds': secondsToSave,
      'todayTotal': todaySeconds,
      'overallTotal': totalSeconds,
    });
  }

  /// جدولة الحفظ التلقائي
  static void _scheduleAutoFlush() {
    // إلغاء أي جدولة سابقة
    _autoFlushTimer?.cancel();
    
    // جدولة جديدة
    _autoFlushTimer = Timer(const Duration(seconds: _autoFlushIntervalSeconds), () {
      // التحقق من أن الوقت لم يتم حفظه بالفعل
      if (_pendingStudySeconds > 0 && 
          (_lastFlushTime == null || 
           DateTime.now().difference(_lastFlushTime!).inSeconds >= _minSaveIntervalSeconds)) {
        _flushStudyTime();
      }
      _autoFlushTimer = null;
    });
  }

  /// إجبار الحفظ الفوري (يستخدم عند إغلاق التطبيق)
  static Future<void> forceFlushStudyTime() async {
    if (_pendingStudySeconds > 0) {
      await _flushStudyTime();
    }
  }

  /// جلب وقت الدراسة اليوم (بالدقائق)
  static int getStudyTimeToday() {
    final progress = getUserProgress();
    if (progress == null) return 0;

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dailyStudyRaw = progress[_dailyStudySecondsKey];
    if (dailyStudyRaw == null || dailyStudyRaw is! Map) return 0;

    final dailyStudy = Map<String, dynamic>.from(
        (dailyStudyRaw).map((key, value) => MapEntry(key.toString(), value)));
    final todaySeconds = dailyStudy[dateKey] as int? ?? 0;
    return (todaySeconds / 60).round();
  }

  /// جلب إجمالي وقت الدراسة (بالدقائق)
  static int getTotalStudyTime() {
    final progress = getUserProgress();
    if (progress == null) return 0;

    final totalSeconds = progress[_totalStudySecondsKey] as int? ?? 0;
    return (totalSeconds / 60).round();
  }

  /// تسجيل استخدام AI Tutor (يتم استدعاؤه عند كل استخدام)
  static Future<void> recordAiTutorUsage() async {
    final progress = getUserProgress() ?? {};
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final usageRaw = progress[_aiTutorDailyUsageKey];
    Map<String, dynamic> usage;
    if (usageRaw == null || usageRaw is! Map) {
      usage = {};
    } else {
      usage = Map<String, dynamic>.from(
          (usageRaw).map((key, value) => MapEntry(key.toString(), value)));
    }

    final todayCount = (usage[dateKey] as int? ?? 0) + 1;
    usage[dateKey] = todayCount;
    progress[_aiTutorDailyUsageKey] = usage;

    await saveUserProgress(progress);

    AppLogger.event('AI Tutor usage recorded', source: 'HiveService', data: {
      'date': dateKey,
      'count': todayCount,
    });
  }

  /// جلب عدد استخدامات AI Tutor اليوم
  static int getAiTutorUsageToday() {
    final progress = getUserProgress();
    if (progress == null) return 0;

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final usageRaw = progress[_aiTutorDailyUsageKey];
    if (usageRaw == null || usageRaw is! Map) return 0;

    final usage = Map<String, dynamic>.from(
        (usageRaw).map((key, value) => MapEntry(key.toString(), value)));

    return usage[dateKey] as int? ?? 0;
  }

  /// التحقق من إمكانية استخدام AI Tutor (3 مرات في اليوم للمستخدمين المجانيين)
  /// Returns: true إذا كان يمكن الاستخدام، false إذا تم تجاوز الحد
  static bool canUseAiTutor({required bool isPro}) {
    // المستخدمون Pro يمكنهم استخدام AI Tutor بدون حدود
    if (isPro) return true;

    // المستخدمون المجانيون: 3 مرات في اليوم
    final usageToday = getAiTutorUsageToday();
    return usageToday < 3;
  }

  /// جلب عدد الاستخدامات المتبقية اليوم
  static int getRemainingAiTutorUsesToday({required bool isPro}) {
    if (isPro) return -1; // -1 يعني غير محدود
    final usageToday = getAiTutorUsageToday();
    return (3 - usageToday).clamp(0, 3);
  }

  /// حذف جميع البيانات من القرص (Factory Reset)
  static Future<void> deleteFromDisk() async {
    await _settingsBox?.close();
    await _progressBox?.close();
    await Hive.deleteBoxFromDisk(_settingsBoxName);
    await Hive.deleteBoxFromDisk(_progressBoxName);
    // إعادة تهيئة الصناديق
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _progressBox = await Hive.openBox(_progressBoxName);
  }

  // ============================================
  // 🎯 POINTS SYSTEM / نظام النقاط
  // ============================================

  /// جلب إجمالي النقاط
  static int getTotalPoints() {
    return _progressBox?.get(_totalPointsKey, defaultValue: 0) as int? ?? 0;
  }

  /// إضافة نقاط
  /// [points] عدد النقاط المراد إضافتها
  /// [source] مصدر النقاط (daily_challenge, exam, review, etc.)
  /// [details] تفاصيل إضافية (اختياري)
  static Future<int> addPoints({
    required int points,
    required String source,
    Map<String, dynamic>? details,
  }) async {
    if (points <= 0) return getTotalPoints();

    AppLogger.functionStart('addPoints', source: 'HiveService');
    
    final currentPoints = getTotalPoints();
    final newTotal = currentPoints + points;
    
    await _progressBox?.put(_totalPointsKey, newTotal);
    
    // حفظ سجل النقاط
    final history = getPointsHistory();
    history.insert(0, {
      'points': points,
      'total': newTotal,
      'source': source,
      'details': details ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // الاحتفاظ بآخر 100 سجل فقط
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    await _progressBox?.put(_pointsHistoryKey, history);
    
    AppLogger.event('Points added', source: 'HiveService', data: {
      'points': points,
      'total': newTotal,
      'source': source,
    });
    
    AppLogger.functionEnd('addPoints', source: 'HiveService', result: newTotal);
    return newTotal;
  }

  /// جلب سجل النقاط
  static List<Map<String, dynamic>> getPointsHistory() {
    final history = _progressBox?.get(_pointsHistoryKey);
    if (history == null) return [];
    
    if (history is List) {
      return history.cast<Map<String, dynamic>>().toList();
    }
    
    return [];
  }

  /// جلب النقاط حسب المصدر
  static int getPointsBySource(String source) {
    final history = getPointsHistory();
    return history
        .where((entry) => entry['source'] == source)
        .fold(0, (sum, entry) => sum + (entry['points'] as int? ?? 0));
  }

  /// إعادة تعيين النقاط (للتطوير/الاختبار)
  static Future<void> resetPoints() async {
    await _progressBox?.delete(_totalPointsKey);
    await _progressBox?.delete(_pointsHistoryKey);
    AppLogger.event('Points reset', source: 'HiveService');
  }
}
