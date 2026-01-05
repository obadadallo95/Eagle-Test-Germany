import 'package:hive_flutter/hive_flutter.dart';
import '../debug/app_logger.dart';

/// خدمة Spaced Repetition System (SRS)
class SrsService {
  static const String _srsBoxName = 'srs_data';
  static Box? _srsBox;

  /// تهيئة صندوق SRS
  static Future<void> init() async {
    _srsBox = await Hive.openBox(_srsBoxName);
  }

  /// حفظ بيانات SRS لسؤال معين
  static Future<void> saveSrsData(int questionId, {
    required DateTime? nextReviewDate,
    required int difficultyLevel,
  }) async {
    await _srsBox?.put('q_$questionId', {
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'difficultyLevel': difficultyLevel,
    });
  }

  /// جلب بيانات SRS لسؤال معين
  static Map<String, dynamic>? getSrsData(int questionId) {
    final data = _srsBox?.get('q_$questionId');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// تحديث SRS بناءً على الإجابة
  /// difficultyLevel: 0=New, 1=Hard, 2=Good, 3=Easy
  static Future<void> updateSrsAfterAnswer(int questionId, bool isCorrect) async {
    AppLogger.functionStart('updateSrsAfterAnswer', source: 'SrsService');
    AppLogger.info('Updating SRS: questionId=$questionId, isCorrect=$isCorrect', source: 'SrsService');
    
    final now = DateTime.now();
    DateTime? nextReviewDate;
    int difficultyLevel;

    if (isCorrect) {
      // إذا كانت الإجابة صحيحة
      final currentData = getSrsData(questionId);
      final currentLevel = currentData?['difficultyLevel'] as int? ?? 0;
      
      // زيادة مستوى الصعوبة (تصبح أسهل)
      difficultyLevel = (currentLevel + 1).clamp(0, 3);
      
      // حساب تاريخ المراجعة التالي (يزيد بشكل أسي)
      final daysToAdd = _calculateDaysForLevel(difficultyLevel);
      nextReviewDate = now.add(Duration(days: daysToAdd));
      
      AppLogger.event('SRS updated (correct)', source: 'SrsService', data: {
        'questionId': questionId,
        'oldLevel': currentLevel,
        'newLevel': difficultyLevel,
        'nextReview': nextReviewDate.toIso8601String(),
      });
    } else {
      // إذا كانت الإجابة خاطئة - مراجعة بعد 10 دقائق
      difficultyLevel = 1; // Hard
      nextReviewDate = now.add(const Duration(minutes: 10));
      
      AppLogger.event('SRS updated (wrong)', source: 'SrsService', data: {
        'questionId': questionId,
        'level': difficultyLevel,
        'nextReview': nextReviewDate.toIso8601String(),
      });
    }

    await saveSrsData(questionId, 
      nextReviewDate: nextReviewDate,
      difficultyLevel: difficultyLevel,
    );
    
    AppLogger.functionEnd('updateSrsAfterAnswer', source: 'SrsService');
  }

  /// حساب الأيام بناءً على مستوى الصعوبة
  static int _calculateDaysForLevel(int level) {
    switch (level) {
      case 0: return 0; // New
      case 1: return 1; // Hard - مراجعة بعد يوم
      case 2: return 3; // Good - مراجعة بعد 3 أيام
      case 3: return 7; // Easy - مراجعة بعد أسبوع
      default: return 1;
    }
  }

  /// جلب الأسئلة المستحقة للمراجعة
  static List<int> getDueQuestions(List<int> allQuestionIds) {
    final now = DateTime.now();
    final dueQuestions = <int>[];

    for (final questionId in allQuestionIds) {
      final srsData = getSrsData(questionId);
      if (srsData == null) {
        // سؤال جديد - يحتاج مراجعة
        dueQuestions.add(questionId);
        continue;
      }

      final nextReviewDateStr = srsData['nextReviewDate'] as String?;
      if (nextReviewDateStr != null) {
        try {
          final nextReviewDate = DateTime.parse(nextReviewDateStr);
          if (now.isAfter(nextReviewDate) || now.isAtSameMomentAs(nextReviewDate)) {
            dueQuestions.add(questionId);
          }
        } catch (e) {
          // تاريخ غير صحيح - إضافة للمراجعة
          dueQuestions.add(questionId);
        }
      } else {
        // لا يوجد تاريخ - سؤال جديد
        dueQuestions.add(questionId);
      }
    }

    return dueQuestions;
  }

  /// جلب مستوى الصعوبة لسؤال معين
  static int getDifficultyLevel(int questionId) {
    final srsData = getSrsData(questionId);
    return srsData?['difficultyLevel'] as int? ?? 0; // 0 = New
  }
}

