import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import 'question_provider.dart';

/// Provider لإنشاء Quick Practice Mode (15 سؤال عشوائي)
/// Uses general questions only for quick practice
final quickPracticeQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final generalQuestions = await ref.watch(generalQuestionsProvider.future);
  
  // اختيار 15 سؤال عشوائي من الأسئلة العامة
  final shuffled = List<Question>.from(generalQuestions);
  shuffled.shuffle(Random());
  
  return shuffled.take(15).toList();
});

