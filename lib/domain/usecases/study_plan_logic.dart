import '../../core/storage/user_preferences_service.dart';
import '../../core/storage/hive_service.dart';

/// منطق خطة الدراسة الذكية
class StudyPlanLogic {
  static const int totalQuestions = 310; // 300 عام + 10 خاصة بالولاية

  /// حساب الهدف اليومي بناءً على الأيام المتبقية
  static Future<int> calculateDailyGoal() async {
    final daysLeft = await UserPreferencesService.getDaysUntilExam();
    if (daysLeft == null || daysLeft <= 0) {
      return 0; // الامتحان قريب جداً أو انتهى
    }

    // جلب عدد الأسئلة التي تمت الإجابة عليها بشكل صحيح
    final progress = HiveService.getUserProgress();
    final answeredCorrectly = _countCorrectAnswers(progress);

    // الصيغة: (إجمالي الأسئلة - الإجابات الصحيحة) / الأيام المتبقية
    final remainingQuestions = totalQuestions - answeredCorrectly;
    final dailyGoal = (remainingQuestions / daysLeft).ceil();

    // الحد الأدنى: سؤال واحد على الأقل، الحد الأقصى: 50 سؤال
    return dailyGoal.clamp(1, 50);
  }

  /// حساب عدد الأسئلة التي تمت الإجابة عليها بشكل صحيح
  static int _countCorrectAnswers(Map<String, dynamic>? progress) {
    if (progress == null) return 0;

    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null) return 0;

    int correctCount = 0;
    answers.forEach((key, value) {
      if (value is Map && value['isCorrect'] == true) {
        correctCount++;
      }
    });

    return correctCount;
  }

  /// حساب عدد الأسئلة التي تمت دراستها اليوم
  static Future<int> getTodayStudiedCount() async {
    final progress = HiveService.getUserProgress();
    if (progress == null) return 0;

    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null) return 0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int todayCount = 0;
    answers.forEach((key, value) {
      if (value is Map && value['timestamp'] != null) {
        try {
          final timestamp = DateTime.parse(value['timestamp'] as String);
          if (timestamp.isAfter(todayStart) || timestamp.isAtSameMomentAs(todayStart)) {
            todayCount++;
          }
        } catch (e) {
          // تجاهل التواريخ غير الصحيحة
        }
      }
    });

    return todayCount;
  }

  /// حساب نسبة الإنجاز اليومي
  static Future<double> getTodayProgress() async {
    final dailyGoal = await calculateDailyGoal();
    if (dailyGoal == 0) return 0.0;

    final todayStudied = await getTodayStudiedCount();
    return (todayStudied / dailyGoal).clamp(0.0, 1.0);
  }
}

