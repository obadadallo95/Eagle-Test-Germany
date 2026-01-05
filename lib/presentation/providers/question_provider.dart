import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../core/storage/user_preferences_service.dart';

// Simple dependency injection via providers
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSourceImpl();
});

final questionRepositoryProvider = Provider((ref) {
  return QuestionRepositoryImpl(ref.watch(localDataSourceProvider));
});

/// Provider for general questions only (300 questions)
final generalQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  final result = await repository.getGeneralQuestions();
  
  return result.fold(
    (failure) => throw Exception(failure),
    (questions) => questions,
  );
});

/// Provider for state-specific questions
final stateQuestionsProvider = FutureProvider.family<List<Question>, String?>((ref, stateCode) async {
  if (stateCode == null || stateCode.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(questionRepositoryProvider);
  final result = await repository.getStateQuestions(stateCode);
  
  return result.fold(
    (failure) => [], // Return empty list on error (graceful fallback)
    (questions) => questions,
  );
});

/// Provider for all questions (general + state-specific) based on user's selected state
final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  final selectedState = await UserPreferencesService.getSelectedState();
  final result = await repository.getAllQuestions(selectedState);
  
  return result.fold(
    (failure) => throw Exception(failure),
    (questions) => questions,
  );
});

/// Legacy provider for backward compatibility
@Deprecated('Use generalQuestionsProvider or questionsProvider instead')
final allQuestionsProvider = questionsProvider;
