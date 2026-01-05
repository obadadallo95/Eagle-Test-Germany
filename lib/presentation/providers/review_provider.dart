import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../core/storage/srs_service.dart';
import 'question_provider.dart';

/// Provider لجلب الأسئلة المستحقة للمراجعة (SRS)
/// Uses the new distributed file structure (general + state questions)
final reviewQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final allQuestions = await ref.watch(questionsProvider.future);
  final allQuestionIds = allQuestions.map((q) => q.id).toList();
  
  // جلب الأسئلة المستحقة للمراجعة
  final dueQuestionIds = SrsService.getDueQuestions(allQuestionIds);
  
  // إرجاع الأسئلة المستحقة فقط
  return allQuestions.where((q) => dueQuestionIds.contains(q.id)).toList();
});

