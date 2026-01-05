import '../entities/exam_readiness.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/srs_service.dart';
import '../../core/storage/user_preferences_service.dart';

/// Use case for calculating Exam Readiness Index
/// 
/// This is a pure Dart class with no UI dependencies.
/// It calculates readiness based on:
/// - Question Mastery (40%)
/// - Recent Exam Performance (30%)
/// - Study Consistency (20%)
/// - State-Specific Questions (10%)
class ExamReadinessCalculator {
  // ============================================
  // WEIGHTS (Tunable constants)
  // ============================================
  static const double _weightMastery = 0.40; // 40%
  static const double _weightExam = 0.30; // 30%
  static const double _weightConsistency = 0.20; // 20%
  static const double _weightState = 0.10; // 10%

  // ============================================
  // THRESHOLDS
  // ============================================
  static const int _masteryDifficultyLevel = 2; // Good or Easy (>= 2)
  static const int _passingScoreThreshold = 50; // 50% to pass
  static const int _inactivityPenaltyDays = 7; // Penalize if inactive > 7 days
  static const double _inactiveMaxReadiness = 70.0; // Cap at 70% if inactive
  static const int _recentExamsCount = 3; // Use last 3 exams

  /// Calculate the overall exam readiness index
  /// 
  /// Returns an [ExamReadiness] object with overall score and breakdown.
  /// This method is deterministic: same inputs → same outputs.
  static Future<ExamReadiness> calculate() async {
    // Fetch all required data
    final progress = HiveService.getUserProgress();
    final examHistory = HiveService.getExamHistory();
    final streak = await UserPreferencesService.getCurrentStreak();
    final lastStudyDate = await UserPreferencesService.getLastStudyDate();
    final selectedState = await UserPreferencesService.getSelectedState();

    // Calculate individual component scores
    final masteryScore = _calculateMasteryScore(progress);
    final examScore = _calculateExamScore(examHistory);
    final consistencyScore = _calculateConsistencyScore(
      streak: streak,
      lastStudyDate: lastStudyDate,
      progress: progress,
    );
    final stateScore = _calculateStateScore(progress, selectedState);

    // Calculate weighted average
    // If user has no exams yet, redistribute exam weight to mastery
    final hasExams = examHistory.isNotEmpty;
    final effectiveMasteryWeight = hasExams 
        ? _weightMastery 
        : _weightMastery + _weightExam; // Redistribute exam weight to mastery
    final effectiveExamWeight = hasExams ? _weightExam : 0.0;
    
    double overallScore = (
      masteryScore * effectiveMasteryWeight +
      examScore * effectiveExamWeight +
      consistencyScore * _weightConsistency +
      stateScore * _weightState
    );

    // Apply inactivity penalty
    if (lastStudyDate != null) {
      final daysSinceLastStudy = DateTime.now().difference(lastStudyDate).inDays;
      if (daysSinceLastStudy > _inactivityPenaltyDays) {
        overallScore = overallScore.clamp(0.0, _inactiveMaxReadiness);
      }
    }

    // Clamp final score to 0-100
    overallScore = overallScore.clamp(0.0, 100.0);

    return ExamReadiness(
      overallScore: overallScore,
      masteryScore: masteryScore,
      examScore: examScore,
      consistencyScore: consistencyScore,
      stateScore: stateScore,
    );
  }

  /// Calculate Question Mastery Score (0-100)
  /// 
  /// Based on:
  /// - Percentage of questions answered correctly
  /// - Questions with difficultyLevel >= 2 count as "mastered"
  /// - New or hard questions reduce readiness
  /// 
  /// Note: This calculates mastery based on answered questions only.
  /// For a more accurate score, we'd need total question count (310),
  /// but for now we use answered questions as the denominator.
  static double _calculateMasteryScore(Map<String, dynamic>? progress) {
    if (progress == null) return 0.0;

    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null || answers.isEmpty) return 0.0;

    int totalAnswered = 0;
    int masteredQuestions = 0;
    int correctAnswers = 0;

    // Count answered questions and mastery
    answers.forEach((questionIdStr, answerData) {
      if (answerData is! Map) return;

      totalAnswered++;
      
      // Check if answer was correct
      final isCorrect = answerData['isCorrect'] as bool? ?? false;
      if (isCorrect) {
        correctAnswers++;
      }

      // Check SRS difficulty level
      final questionId = int.tryParse(questionIdStr);
      if (questionId != null) {
        final difficultyLevel = SrsService.getDifficultyLevel(questionId);
        if (difficultyLevel >= _masteryDifficultyLevel) {
          masteredQuestions++;
        }
      }
    });

    if (totalAnswered == 0) return 0.0;

    // Calculate mastery as average of:
    // 1. Percentage of correct answers (50% weight)
    // 2. Percentage of mastered questions (50% weight)
    final correctnessRatio = correctAnswers / totalAnswered;
    final masteryRatio = masteredQuestions / totalAnswered;
    
    final masteryScore = ((correctnessRatio * 0.5) + (masteryRatio * 0.5)) * 100.0;
    
    return masteryScore.clamp(0.0, 100.0);
  }

  /// Calculate Recent Exam Performance Score (0-100)
  /// 
  /// Based on:
  /// - Last 3 exam simulations (if available)
  /// - Passing score >= 50% is considered a pass
  /// - Weight recent exams more than older ones
  static double _calculateExamScore(List<Map<String, dynamic>> examHistory) {
    if (examHistory.isEmpty) {
      // No exams yet - return 0 (weight will be redistributed to mastery)
      return 0.0;
    }

    // Take last N exams
    final recentExams = examHistory.take(_recentExamsCount).toList();
    
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    // Weight more recent exams higher
    for (int i = 0; i < recentExams.length; i++) {
      final exam = recentExams[i];
      final scorePercentage = exam['scorePercentage'] as int? ?? 0;
      final isPassed = exam['isPassed'] as bool? ?? false;
      
      // Calculate exam score: pass (>= threshold) = 100, fail = actual percentage
      final examScore = (isPassed && scorePercentage >= _passingScoreThreshold) 
          ? 100.0 
          : scorePercentage.toDouble();
      
      // Weight: most recent = highest weight (linear decay)
      final weight = (recentExams.length - i).toDouble();
      
      weightedSum += examScore * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return 0.0;

    final averageScore = weightedSum / totalWeight;
    return averageScore.clamp(0.0, 100.0);
  }

  /// Calculate Study Consistency Score (0-100)
  /// 
  /// Based on:
  /// - Current study streak
  /// - Study sessions in last 7 days
  /// - Penalize long inactivity (> 7 days)
  static double _calculateConsistencyScore({
    required int streak,
    required DateTime? lastStudyDate,
    required Map<String, dynamic>? progress,
  }) {
    if (lastStudyDate == null) return 0.0;

    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate).inDays;

    // Penalize inactivity
    if (daysSinceLastStudy > _inactivityPenaltyDays) {
      return 0.0;
    }

    // Calculate study sessions in last 7 days
    final studySessionsLast7Days = _countStudySessionsLast7Days(progress);

    // Score components:
    // 1. Streak score (0-50 points): max at 30 days
    final streakScore = (streak / 30.0 * 50.0).clamp(0.0, 50.0);

    // 2. Recent activity score (0-50 points): max at 7 sessions in 7 days
    final activityScore = (studySessionsLast7Days / 7.0 * 50.0).clamp(0.0, 50.0);

    final consistencyScore = streakScore + activityScore;
    return consistencyScore.clamp(0.0, 100.0);
  }

  /// Count study sessions in the last 7 days
  static int _countStudySessionsLast7Days(Map<String, dynamic>? progress) {
    if (progress == null) return 0;

    final dailyStudy = progress['daily_study_seconds'] as Map<String, dynamic>?;
    if (dailyStudy == null) return 0;

    final now = DateTime.now();
    int sessionCount = 0;

    // Check last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final seconds = dailyStudy[dateKey] as int? ?? 0;
      if (seconds > 0) {
        sessionCount++;
      }
    }

    return sessionCount;
  }

  /// Calculate State-Specific Questions Score (0-100)
  /// 
  /// Based on:
  /// - Mastery of selected Bundesland questions
  /// - If no state selected, return neutral score (50%)
  /// 
  /// **Note:** This implementation uses a simplified heuristic since we don't have
  /// direct access to question entities in the use case layer. For a production-ready
  /// implementation, inject a question repository to filter by state_code.
  /// 
  /// Current heuristic: Uses overall mastery as a proxy for state-specific mastery.
  /// This is acceptable for MVP since state questions are only 10% weight.
  static double _calculateStateScore(
    Map<String, dynamic>? progress,
    String? selectedState,
  ) {
    if (selectedState == null || selectedState.isEmpty) {
      // No state selected - return neutral score (neither helps nor hurts)
      return 50.0;
    }

    if (progress == null) return 0.0;

    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers == null || answers.isEmpty) return 0.0;

    // Simplified approach: Use overall mastery as proxy for state-specific mastery
    // This assumes that if user has good overall mastery, they likely have
    // good state-specific mastery too (since state questions are part of the pool)
    // 
    // TODO: Enhance to filter by actual state_code when question repository
    // is accessible. This would require:
    // 1. Injecting QuestionRepository into the use case
    // 2. Filtering questions by stateCode == selectedState
    // 3. Calculating mastery only for those filtered questions
    
    int totalStateAnswers = 0;
    int masteredStateAnswers = 0;

    answers.forEach((questionIdStr, answerData) {
      if (answerData is! Map) return;

      final isCorrect = answerData['isCorrect'] as bool? ?? false;
      final questionId = int.tryParse(questionIdStr);
      
      if (questionId != null) {
        final difficultyLevel = SrsService.getDifficultyLevel(questionId);
        
        // Heuristic: Assume questions with IDs in a certain range might be state-specific
        // In production, this should check question.stateCode == selectedState
        // For now, we use a sampling approach: check every Nth question
        // This gives us a rough estimate without needing question entities
        if (questionId % 10 == 0) { // Sample ~10% of questions
          totalStateAnswers++;
          if (difficultyLevel >= _masteryDifficultyLevel && isCorrect) {
            masteredStateAnswers++;
          }
        }
      }
    });

    if (totalStateAnswers == 0) {
      // No state questions identified in sample - use overall mastery as fallback
      // This is a reasonable approximation for MVP
      final overallMastery = _calculateMasteryScore(progress);
      return overallMastery * 0.8; // Slightly penalize (80% of overall)
    }

    final stateScore = (masteredStateAnswers / totalStateAnswers) * 100.0;
    return stateScore.clamp(0.0, 100.0);
  }
}

