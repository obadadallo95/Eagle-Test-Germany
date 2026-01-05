import 'package:dartz/dartz.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/entities/question.dart';
import '../datasources/local_datasource.dart';

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
  Future<Either<String, List<Question>>> getQuestions() => getGeneralQuestions();
}
