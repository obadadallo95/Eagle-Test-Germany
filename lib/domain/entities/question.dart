import 'package:equatable/equatable.dart';

class Answer extends Equatable {
  final String id; // 'A', 'B', 'C', 'D'
  final Map<String, String> text;

  const Answer({required this.id, required this.text});

  String getText(String langCode) => text[langCode] ?? text['de']!;

  @override
  List<Object?> get props => [id, text];
}

class Question extends Equatable {
  final int id;
  final String categoryId;
  final Map<String, String> questionText;
  final List<Answer> answers;
  final String correctAnswerId;
  final String? audioPath;
  final String? stateCode; // e.g., 'SN' for Sachsen, 'BY' for Bayern. null = General Question
  final String? image; // مسار الصورة المرتبطة بالسؤال
  final String? topic; // e.g., 'system', 'rights', 'history', 'society', 'europe', 'welfare'

  const Question({
    required this.id,
    required this.categoryId,
    required this.questionText,
    required this.answers,
    required this.correctAnswerId,
    this.audioPath,
    this.stateCode,
    this.image,
    this.topic,
  });

  // Method to get text based on current app language
  String getText(String langCode) {
    return questionText[langCode] ?? questionText['de']!;
  }

  @override
  List<Object?> get props => [id, categoryId, questionText, answers, correctAnswerId, audioPath, stateCode, image, topic];
}
