import 'package:dartz/dartz.dart';
import '../entities/question.dart';

abstract class QuestionRepository {
  /// Get general questions (300 questions)
  Future<Either<String, List<Question>>> getGeneralQuestions();
  
  /// Get state-specific questions for a given state code
  Future<Either<String, List<Question>>> getStateQuestions(String stateCode);
  
  /// Get all questions (general + state-specific) for a given state
  Future<Either<String, List<Question>>> getAllQuestions(String? stateCode);
  
  /// Generate exam questions: 30 general + 3 state-specific = 33 total
  /// 
  /// [stateCode] - Optional state code (e.g., "BE", "BY"). If null or empty,
  /// returns 33 random general questions.
  /// 
  /// Returns a list of exactly 33 questions (or fewer if not enough available).
  /// Questions are shuffled randomly.
  Future<Either<String, List<Question>>> generateExam(String? stateCode);
  
  /// Legacy method for backward compatibility
  @Deprecated('Use getGeneralQuestions() instead')
  Future<Either<String, List<Question>>> getQuestions() => getGeneralQuestions();
}
