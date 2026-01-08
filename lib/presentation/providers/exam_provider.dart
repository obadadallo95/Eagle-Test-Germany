import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../core/storage/user_preferences_service.dart';
import 'question_provider.dart';

/// Provider for generating exam questions (30 general + 3 state-specific = 33 total)
/// 
/// Official Exam Structure:
/// - 30 General Questions (randomly selected from main pool)
/// - 3 State-Specific Questions (selected based on user's chosen Bundesland)
/// 
/// Uses the QuestionRepository.generateExam() method for clean separation of concerns.
final examQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  // Get user's selected state from preferences
  final selectedState = await UserPreferencesService.getSelectedState();
  
  // Use repository method to generate exam
  final repository = ref.watch(questionRepositoryProvider);
  final result = await repository.generateExam(selectedState);
  
  return result.fold(
    (failure) {
      // Fallback: if generation fails, try legacy method
      return _generateExamLegacy(ref, selectedState);
    },
    (questions) => questions,
  );
});

/// Legacy fallback method (kept for backward compatibility)
/// This method is used if the repository method fails
Future<List<Question>> _generateExamLegacy(
  Ref ref,
  String? selectedState,
) async {
  // Load general questions (300 questions)
  final generalQuestions = await ref.watch(generalQuestionsProvider.future);
  
  if (selectedState == null || selectedState.isEmpty) {
    // If no state selected, return 33 random general questions
    final shuffled = List<Question>.from(generalQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(33).toList();
  }

  // Step A: Get 30 random general questions
  final shuffledGeneral = List<Question>.from(generalQuestions);
  shuffledGeneral.shuffle(Random());
  final selectedGeneral = shuffledGeneral.take(30).toList();

  // Step B: Get 3 state-specific questions for selected state
  final stateQuestions = await ref.watch(stateQuestionsProvider(selectedState).future);
  
  if (stateQuestions.isEmpty) {
    // Fallback: if no state questions available, use general questions only
    final shuffled = List<Question>.from(generalQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(33).toList();
  }
  
  final shuffledState = List<Question>.from(stateQuestions);
  shuffledState.shuffle(Random());
  final selectedStateQuestions = shuffledState.take(3).toList();

  // Step C: Combine into single list of 33 questions
  final examQuestions = [...selectedGeneral, ...selectedStateQuestions];
  
  // Step D: Shuffle the final list
  examQuestions.shuffle(Random());

  return examQuestions;
}

