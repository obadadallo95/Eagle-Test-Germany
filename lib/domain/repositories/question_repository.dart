import 'package:dartz/dartz.dart';
import '../entities/question.dart';

abstract class QuestionRepository {
  /// Get general questions (300 questions)
  Future<Either<String, List<Question>>> getGeneralQuestions();
  
  /// Get state-specific questions for a given state code
  Future<Either<String, List<Question>>> getStateQuestions(String stateCode);
  
  /// Get all questions (general + state-specific) for a given state
  Future<Either<String, List<Question>>> getAllQuestions(String? stateCode);
  
  /// Legacy method for backward compatibility
  @Deprecated('Use getGeneralQuestions() instead')
  Future<Either<String, List<Question>>> getQuestions() => getGeneralQuestions();
}
