import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../core/storage/user_preferences_service.dart';
import 'question_provider.dart';

/// Provider لإنشاء امتحان مخصص (30 عام + 3 خاصة بالولاية)
/// Uses distributed data files: loads general questions and state-specific questions separately
final examQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final selectedState = await UserPreferencesService.getSelectedState();
  
  // Load general questions (300 questions)
  final generalQuestions = await ref.watch(generalQuestionsProvider.future);
  
  if (selectedState == null || selectedState.isEmpty) {
    // إذا لم يتم اختيار ولاية، نرجع 33 سؤال عشوائي عام
    final shuffled = List<Question>.from(generalQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(33).toList();
  }

  // جلب 30 سؤال عام عشوائي
  final shuffledGeneral = List<Question>.from(generalQuestions);
  shuffledGeneral.shuffle(Random());
  final selectedGeneral = shuffledGeneral.take(30).toList();

  // جلب 3 أسئلة خاصة بالولاية المختارة
  final stateQuestions = await ref.watch(stateQuestionsProvider(selectedState).future);
  
  if (stateQuestions.isEmpty) {
    // Fallback: إذا لم توجد أسئلة خاصة بالولاية، استخدم أسئلة عامة فقط
    final shuffled = List<Question>.from(generalQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(33).toList();
  }
  
  final shuffledState = List<Question>.from(stateQuestions);
  shuffledState.shuffle(Random());
  final selectedStateQuestions = shuffledState.take(3).toList();

  // دمج القوائم وخلطها
  final examQuestions = [...selectedGeneral, ...selectedStateQuestions];
  examQuestions.shuffle(Random());

  return examQuestions;
});

