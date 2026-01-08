import 'package:dartz/dartz.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/entities/question.dart';
import '../datasources/local_datasource.dart';
import '../../core/debug/app_logger.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final LocalDataSource localDataSource;

  QuestionRepositoryImpl(this.localDataSource);

  @override
  Future<Either<String, List<Question>>> getGeneralQuestions() async {
    try {
      final questions = await localDataSource.getGeneralQuestions();
      return Right(questions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Question>>> getStateQuestions(String stateCode) async {
    try {
      final questions = await localDataSource.getStateQuestions(stateCode);
      return Right(questions);
    } catch (e) {
      // Return empty list instead of error for graceful fallback
      return const Right([]);
    }
  }

  @override
  Future<Either<String, List<Question>>> getAllQuestions(String? stateCode) async {
    try {
      final generalQuestions = await localDataSource.getGeneralQuestions();
      
      if (stateCode == null || stateCode.isEmpty) {
        return Right(generalQuestions);
      }
      
      final stateQuestions = await localDataSource.getStateQuestions(stateCode);
      final allQuestions = [...generalQuestions, ...stateQuestions];
      
      return Right(allQuestions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Question>>> generateExam(String? stateCode) async {
    AppLogger.functionStart('generateExam', source: 'QuestionRepository');
    AppLogger.info('Generating exam with stateCode: ${stateCode ?? "null"}', source: 'QuestionRepository');
    
    try {
      // Step A: Fetch ALL general questions and shuffle them
      final allGeneralQuestions = await localDataSource.getGeneralQuestions();
      
      if (allGeneralQuestions.isEmpty) {
        AppLogger.error('No general questions available', source: 'QuestionRepository');
        return const Left('No general questions available');
      }
      
      AppLogger.info('Loaded ${allGeneralQuestions.length} general questions', source: 'QuestionRepository');
      
      // Shuffle and pick first 30
      final shuffledGeneral = List<Question>.from(allGeneralQuestions);
      shuffledGeneral.shuffle();
      final selectedGeneral = shuffledGeneral.take(30).toList();
      
      AppLogger.info('Selected 30 general questions', source: 'QuestionRepository');
      
      // Step B: If stateCode is provided, fetch state questions
      List<Question> selectedStateQuestions = [];
      if (stateCode != null && stateCode.isNotEmpty) {
        try {
          AppLogger.info('Attempting to load state questions for: $stateCode', source: 'QuestionRepository');
          final stateQuestions = await localDataSource.getStateQuestions(stateCode);
          
          if (stateQuestions.isNotEmpty) {
            // Shuffle and pick first 3
            final shuffledState = List<Question>.from(stateQuestions);
            shuffledState.shuffle();
            selectedStateQuestions = shuffledState.take(3).toList();
            AppLogger.info('Successfully loaded ${selectedStateQuestions.length} state-specific questions', source: 'QuestionRepository');
          } else {
            AppLogger.warn('State questions file exists but is empty for: $stateCode', source: 'QuestionRepository');
          }
        } catch (e, stackTrace) {
          // Graceful fallback: if state questions fail, continue with general only
          // This ensures the app never crashes even if a state file is corrupt
          AppLogger.error(
            'Failed to load state questions for $stateCode. Falling back to general questions only.',
            source: 'QuestionRepository',
            error: e,
            stackTrace: stackTrace,
          );
        }
      } else {
        AppLogger.info('No state code provided, using general questions only', source: 'QuestionRepository');
      }
      
      // Step C: Combine into single list of 33 questions
      final examQuestions = <Question>[];
      examQuestions.addAll(selectedGeneral);
      examQuestions.addAll(selectedStateQuestions);
      
      // If we don't have 33 questions (e.g., state questions missing),
      // fill with additional general questions
      if (examQuestions.length < 33 && allGeneralQuestions.length >= 33) {
        final remaining = 33 - examQuestions.length;
        final additionalGeneral = shuffledGeneral
            .where((q) => !examQuestions.any((eq) => eq.id == q.id))
            .take(remaining)
            .toList();
        examQuestions.addAll(additionalGeneral);
        AppLogger.info('Added $remaining additional general questions to reach 33 total', source: 'QuestionRepository');
      }
      
      // Step D: Shuffle the final list
      examQuestions.shuffle();
      
      AppLogger.event(
        'Exam generated successfully',
        source: 'QuestionRepository',
        data: {
          'totalQuestions': examQuestions.length,
          'generalQuestions': selectedGeneral.length,
          'stateQuestions': selectedStateQuestions.length,
          'stateCode': stateCode ?? 'none',
        },
      );
      
      AppLogger.functionEnd('generateExam', source: 'QuestionRepository');
      return Right(examQuestions);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to generate exam',
        source: 'QuestionRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('Failed to generate exam: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Question>>> getQuestions() => getGeneralQuestions();
}
