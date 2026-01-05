import '../entities/daily_plan.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/srs_service.dart';
import '../../core/storage/user_preferences_service.dart';

/// Use case for generating a smart daily study plan
/// 
/// This is a pure Dart class with no UI dependencies.
/// It generates a personalized daily plan based on:
/// - Weak questions (SRS difficulty < 2, exam mistakes)
/// - SRS due questions
/// - Exam date proximity
/// - User activity level
class SmartDailyPlanGenerator {
  // ============================================
  // CONSTANTS (Tunable)
  // ============================================
  static const int _maxQuestionsPerDay = 7;
  static const int _minQuestionsPerDay = 3;
  static const int _inactiveDaysThreshold = 3; // If inactive > 3 days, simplify plan
  static const int _examDateUrgencyDays = 14; // If exam < 14 days, prioritize high-risk

  /// Generate a daily study plan
  /// 
  /// Returns a [DailyPlan] with question IDs and explanation.
  /// This method is deterministic: same inputs → same outputs.
  static Future<DailyPlan> generate() async {
    // Fetch required data
    final progress = HiveService.getUserProgress();
    final examHistory = HiveService.getExamHistory();
    final examDate = await UserPreferencesService.getExamDate();
    final lastStudyDate = await UserPreferencesService.getLastStudyDate();
    final selectedState = await UserPreferencesService.getSelectedState();
    
    // Get all question IDs (we'll need to get this from somewhere)
    // For now, we'll extract from user progress
    final allQuestionIds = _getAllQuestionIds(progress);
    
    if (allQuestionIds.isEmpty) {
      return DailyPlan.empty();
    }

    // Check user activity level
    final daysSinceLastStudy = lastStudyDate != null
        ? DateTime.now().difference(lastStudyDate).inDays
        : 999;
    
    final isInactive = daysSinceLastStudy > _inactiveDaysThreshold;
    final isExamUrgent = examDate != null &&
        examDate.difference(DateTime.now()).inDays < _examDateUrgencyDays;

    // Identify weak questions
    final weakQuestions = _identifyWeakQuestions(
      allQuestionIds: allQuestionIds,
      progress: progress,
      examHistory: examHistory,
    );

    // Get SRS due questions
    final srsDueQuestions = SrsService.getDueQuestions(allQuestionIds);

    // Get state-specific questions (if state selected)
    final stateQuestions = selectedState != null
        ? _getStateQuestions(allQuestionIds, selectedState, progress)
        : <int>[];

    // Generate plan based on priority
    final plan = _buildPlan(
      weakQuestions: weakQuestions,
      srsDueQuestions: srsDueQuestions,
      stateQuestions: stateQuestions,
      allQuestionIds: allQuestionIds,
      isInactive: isInactive,
      isExamUrgent: isExamUrgent,
      examDate: examDate,
    );

    return plan;
  }

  /// Get all question IDs
  /// 
  /// Note: For MVP, we use a heuristic approach:
  /// - General questions: IDs 1-300 (standard range)
  /// - State questions: IDs 20000+ (heuristic based on data structure)
  /// - Plus any questions the user has already answered
  /// 
  /// TODO: In production, inject QuestionRepository to get actual question IDs.
  static List<int> _getAllQuestionIds(Map<String, dynamic>? progress) {
    final questionIds = <int>{};
    
    // Add general questions (1-300)
    for (int i = 1; i <= 300; i++) {
      questionIds.add(i);
    }
    
    // Add state questions (20000+ range, heuristic)
    // In production, this should filter by actual state_code
    for (int i = 20001; i <= 20160; i++) {
      questionIds.add(i);
    }
    
    // Add any questions user has already answered (to ensure we don't miss any)
    if (progress != null) {
      final answers = progress['answers'] as Map<String, dynamic>?;
      if (answers != null) {
        for (final key in answers.keys) {
          final questionId = int.tryParse(key);
          if (questionId != null) {
            questionIds.add(questionId);
          }
        }
      }
    }
    
    return questionIds.toList()..sort();
  }

  /// Identify weak questions based on SRS and exam mistakes
  static List<int> _identifyWeakQuestions({
    required List<int> allQuestionIds,
    required Map<String, dynamic>? progress,
    required List<Map<String, dynamic>> examHistory,
  }) {
    final weakQuestions = <int>{};

    // 1. Questions with low SRS difficulty (0 or 1 = New or Hard)
    for (final questionId in allQuestionIds) {
      final difficulty = SrsService.getDifficultyLevel(questionId);
      if (difficulty < 2) {
        weakQuestions.add(questionId);
      }
    }

    // 2. Questions answered incorrectly in recent exams
    final recentExams = examHistory.take(3).toList();
    for (final exam in recentExams) {
      final questionDetails = exam['questionDetails'] as List<dynamic>?;
      if (questionDetails != null) {
        for (final detail in questionDetails) {
          if (detail is Map) {
            final isCorrect = detail['isCorrect'] as bool? ?? true;
            final questionId = detail['questionId'] as int?;
            if (!isCorrect && questionId != null) {
              weakQuestions.add(questionId);
            }
          }
        }
      }
    }

    // 3. Questions never answered correctly
    if (progress != null) {
      final answers = progress['answers'] as Map<String, dynamic>?;
      if (answers != null) {
        for (final entry in answers.entries) {
          final questionId = int.tryParse(entry.key);
          if (questionId != null) {
            final answerData = entry.value;
            if (answerData is Map) {
              final isCorrect = answerData['isCorrect'] as bool? ?? false;
              if (!isCorrect) {
                weakQuestions.add(questionId);
              }
            }
          }
        }
      }
    }

    return weakQuestions.toList();
  }

  /// Get state-specific questions (simplified heuristic)
  static List<int> _getStateQuestions(
    List<int> allQuestionIds,
    String selectedState,
    Map<String, dynamic>? progress,
  ) {
    // For now, we'll use a heuristic: questions with IDs in a certain range
    // In production, this should filter by actual state_code
    // This is acceptable for MVP since state questions are a small subset
    
    final stateQuestions = <int>[];
    final answers = progress?['answers'] as Map<String, dynamic>?;
    
    if (answers != null) {
      for (final entry in answers.entries) {
        final questionId = int.tryParse(entry.key);
        if (questionId != null && questionId >= 20000) {
          // Heuristic: state questions typically have IDs >= 20000
          stateQuestions.add(questionId);
        }
      }
    }
    
    return stateQuestions;
  }

  /// Build the daily plan based on priorities
  static DailyPlan _buildPlan({
    required List<int> weakQuestions,
    required List<int> srsDueQuestions,
    required List<int> stateQuestions,
    required List<int> allQuestionIds,
    required bool isInactive,
    required bool isExamUrgent,
    required DateTime? examDate,
  }) {
    final selectedQuestions = <int>[];
    final explanations = <String>[];
    int weakCount = 0;
    int srsCount = 0;
    int stateCount = 0;

    // Determine target question count
    int targetCount = isInactive 
        ? _minQuestionsPerDay  // Simplify for inactive users
        : _maxQuestionsPerDay;

    // Priority 1: If exam is urgent, focus on weak questions
    if (isExamUrgent && weakQuestions.isNotEmpty) {
      final urgentWeak = weakQuestions.take(4).toList();
      selectedQuestions.addAll(urgentWeak);
      weakCount = urgentWeak.length;
      explanations.add('$weakCount high-priority questions');
    } else {
      // Priority 1: SRS due questions (must review)
      if (srsDueQuestions.isNotEmpty) {
        final srsCountToAdd = isInactive ? 2 : 3;
        final srsSelected = srsDueQuestions.take(srsCountToAdd).toList();
        selectedQuestions.addAll(srsSelected);
        srsCount = srsSelected.length;
        if (srsCount > 0) {
          explanations.add('$srsCount SRS reviews (due today)');
        }
      }

      // Priority 2: Weak questions
      if (weakQuestions.isNotEmpty && selectedQuestions.length < targetCount) {
        final remaining = targetCount - selectedQuestions.length;
        final weakSelected = weakQuestions
            .where((id) => !selectedQuestions.contains(id))
            .take(remaining)
            .toList();
        selectedQuestions.addAll(weakSelected);
        weakCount = weakSelected.length;
        if (weakCount > 0) {
          // Try to identify topic (simplified)
          explanations.add('$weakCount weak questions');
        }
      }
    }

    // Priority 3: State-specific questions (if state selected and space available)
    if (stateQuestions.isNotEmpty && 
        selectedQuestions.length < targetCount &&
        !isInactive) {
      final remaining = targetCount - selectedQuestions.length;
      final stateSelected = stateQuestions
          .where((id) => !selectedQuestions.contains(id))
          .take(remaining)
          .toList();
      selectedQuestions.addAll(stateSelected);
      stateCount = stateSelected.length;
      if (stateCount > 0) {
        explanations.add('$stateCount state-specific question${stateCount > 1 ? 's' : ''}');
      }
    }

    // If still not enough, add new questions (never seen)
    if (selectedQuestions.length < _minQuestionsPerDay) {
      final newQuestions = allQuestionIds
          .where((id) => !selectedQuestions.contains(id))
          .take(_minQuestionsPerDay - selectedQuestions.length)
          .toList();
      selectedQuestions.addAll(newQuestions);
      if (newQuestions.isNotEmpty) {
        explanations.add('${newQuestions.length} new question${newQuestions.length > 1 ? 's' : ''}');
      }
    }

    // Limit to max
    final finalQuestions = selectedQuestions.take(_maxQuestionsPerDay).toList();

    // Build explanation
    String explanation;
    if (finalQuestions.isEmpty) {
      explanation = 'Start by exploring questions in Study Mode.';
    } else if (isExamUrgent) {
      explanation = "Today's Focus: ${explanations.join(', ')}. Exam is approaching—focus on high-priority areas.";
    } else if (isInactive) {
      explanation = "Today's Focus: ${explanations.join(', ')}. Welcome back! Let's ease back into studying.";
    } else {
      explanation = "Today's Focus: ${explanations.join(', ')}.";
    }

    // Determine plan type
    String planType;
    if (isExamUrgent) {
      planType = 'exam_prep';
    } else if (weakCount > srsCount) {
      planType = 'weakness_focus';
    } else if (srsCount > 0) {
      planType = 'srs_review';
    } else {
      planType = 'balanced';
    }

    // Estimate time (1-2 min per question)
    final estimatedMinutes = finalQuestions.length * 2;

    return DailyPlan(
      questionIds: finalQuestions,
      explanation: explanation,
      estimatedMinutes: estimatedMinutes.clamp(5, 20),
      planType: planType,
    );
  }
}

