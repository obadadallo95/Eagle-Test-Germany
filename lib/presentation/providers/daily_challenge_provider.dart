import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import 'question_provider.dart';
import '../../core/storage/hive_service.dart';

/// Provider لإنشاء التحدي اليومي (10 أسئلة عشوائية)
/// Daily Challenge Provider - Generates 10 random questions for daily challenge
final dailyChallengeProvider = FutureProvider<List<Question>>((ref) async {
  // جلب جميع الأسئلة العامة
  final allQuestions = await ref.watch(generalQuestionsProvider.future);
  
  if (allQuestions.isEmpty) {
    return [];
  }
  
  // إنشاء نسخة من القائمة وخلطها
  final shuffled = List<Question>.from(allQuestions);
  shuffled.shuffle(Random());
  
  // اختيار 10 أسئلة عشوائية
  return shuffled.take(10).toList();
});

/// Provider لحفظ نتيجة التحدي اليومي
/// Saves daily challenge result to Hive
final dailyChallengeResultProvider = StateNotifierProvider<DailyChallengeResultNotifier, DailyChallengeResult?>((ref) {
  return DailyChallengeResultNotifier();
});

class DailyChallengeResult {
  final DateTime date;
  final int score; // النقاط (0-100)
  final int correctAnswers; // عدد الإجابات الصحيحة
  final int totalQuestions; // إجمالي الأسئلة
  final int timeSeconds; // الوقت المستغرق بالثواني

  DailyChallengeResult({
    required this.date,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSeconds': timeSeconds,
    };
  }

  factory DailyChallengeResult.fromMap(Map<String, dynamic> map) {
    return DailyChallengeResult(
      date: DateTime.parse(map['date']),
      score: map['score'] as int,
      correctAnswers: map['correctAnswers'] as int,
      totalQuestions: map['totalQuestions'] as int,
      timeSeconds: map['timeSeconds'] as int,
    );
  }
}

class DailyChallengeResultNotifier extends StateNotifier<DailyChallengeResult?> {
  DailyChallengeResultNotifier() : super(null);

  /// حفظ نتيجة التحدي اليومي
  Future<void> saveResult({
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int timeSeconds,
  }) async {
    final result = DailyChallengeResult(
      date: DateTime.now(),
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      timeSeconds: timeSeconds,
    );

    state = result;
    
    // حفظ في Hive
    await _saveToHive(result);
  }

  Future<void> _saveToHive(DailyChallengeResult result) async {
    try {
      final progress = HiveService.getUserProgress() ?? {};
      final dailyChallengesRaw = progress['daily_challenges'];
      List<dynamic> dailyChallenges;
      
      if (dailyChallengesRaw == null) {
        dailyChallenges = [];
      } else if (dailyChallengesRaw is List) {
        dailyChallenges = List<dynamic>.from(dailyChallengesRaw);
      } else {
        dailyChallenges = [];
      }
      
      // إضافة النتيجة الجديدة
      dailyChallenges.add(result.toMap());
      
      // الاحتفاظ بآخر 30 تحدياً فقط
      if (dailyChallenges.length > 30) {
        dailyChallenges.removeRange(0, dailyChallenges.length - 30);
      }
      
      progress['daily_challenges'] = dailyChallenges;
      await HiveService.saveUserProgress(progress);
    } catch (e) {
      // في حالة الخطأ، لا نفعل شيئاً (النتيجة محفوظة في state)
    }
  }

  /// جلب آخر نتيجة للتحدي اليومي
  DailyChallengeResult? getLastResult() {
    try {
      final progress = HiveService.getUserProgress();
      if (progress == null) return null;
      
      final dailyChallengesRaw = progress['daily_challenges'];
      if (dailyChallengesRaw == null || dailyChallengesRaw is! List) {
        return null;
      }
      
      final dailyChallenges = List<dynamic>.from(dailyChallengesRaw);
      if (dailyChallenges.isEmpty) {
        return null;
      }
      
      // جلب آخر نتيجة
      final lastResultMap = dailyChallenges.last;
      if (lastResultMap is Map) {
        return DailyChallengeResult.fromMap(
          Map<String, dynamic>.from(lastResultMap.map(
            (key, value) => MapEntry(key.toString(), value),
          )),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// التحقق من إكمال التحدي اليوم
  bool hasCompletedToday() {
    final lastResult = getLastResult();
    if (lastResult == null) {
      return false;
    }
    
    final today = DateTime.now();
    final lastDate = lastResult.date;
    
    // التحقق من أن آخر تحدٍ كان اليوم
    return today.year == lastDate.year &&
           today.month == lastDate.month &&
           today.day == lastDate.day;
  }
}

