import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/question.dart';

// part 'question_model.g.dart';

// @JsonSerializable(explicitToJson: true)
class QuestionModel extends Question {
  @JsonKey(name: 'category_id')
  final String categoryIdModel;
  
  @JsonKey(name: 'question')
  final Map<String, String> questionTextModel;
  
  @JsonKey(name: 'correct_answer')
  final String correctAnswerIdModel;
  
  final List<AnswerModel> answersModel;

  const QuestionModel({
    required super.id,
    required this.categoryIdModel,
    required this.questionTextModel,
    required this.answersModel,
    required this.correctAnswerIdModel,
    String? stateCodeModel,
    String? imageModel,
    String? topicModel,
  }) : super(
         categoryId: categoryIdModel,
         questionText: questionTextModel,
         answers: answersModel,
         correctAnswerId: correctAnswerIdModel,
         stateCode: stateCodeModel,
         image: imageModel,
         topic: topicModel,
       );

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
     // Manual mapping to handle nested structure cleanly if needed, 
     // but part files are better.
     // Since I cannot run build_runner easily right now, I will implement manual parsing 
     // to ensure it works immediately without generating files.
     
     // Null-safe parsing with defaults
     final id = json['id'] as int? ?? 0;
     final categoryId = json['category_id']?.toString() ?? 'general';
     
     // Handle question text map - may be null or empty
     Map<String, String> questionText = {};
     if (json['question'] != null && json['question'] is Map) {
       try {
         questionText = Map<String, String>.from(
           (json['question'] as Map).map((key, value) => 
             MapEntry(key.toString(), value?.toString() ?? '')
           )
         );
       } catch (e) {
         questionText = {'de': '', 'ar': ''};
       }
     }
     
     // Handle answers list - may be null or empty
     List<AnswerModel> answers = [];
     if (json['answers'] != null && json['answers'] is List) {
       try {
         answers = (json['answers'] as List<dynamic>)
             .map((e) {
               try {
                 return AnswerModel.fromJson(e as Map<String, dynamic>);
               } catch (e) {
                 return null;
               }
             })
             .whereType<AnswerModel>()
             .toList();
       } catch (e) {
         answers = [];
       }
     }
     
     // Handle correct_answer - default to 'A' if null
     final correctAnswer = json['correct_answer']?.toString() ?? 'A';
     
     // Handle optional fields
     final stateCode = json['state_code']?.toString();
     final image = json['image']?.toString();
     final topic = json['topic']?.toString();
     
     return QuestionModel(
       id: id,
       categoryIdModel: categoryId,
       questionTextModel: questionText,
       answersModel: answers,
       correctAnswerIdModel: correctAnswer,
       stateCodeModel: stateCode,
       imageModel: image,
       topicModel: topic,
     );
  }
}

class AnswerModel extends Answer {
  const AnswerModel({required super.id, required super.text});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    // Null-safe parsing with defaults
    final id = json['id']?.toString() ?? 'A';
    
    // Handle text map - may be null or empty
    Map<String, String> textMap = {};
    if (json['text'] != null && json['text'] is Map) {
      try {
        textMap = Map<String, String>.from(
          (json['text'] as Map).map((key, value) => 
            MapEntry(key.toString(), value?.toString() ?? '')
          )
        );
      } catch (e) {
        textMap = {'de': '', 'ar': ''};
      }
    }
    
    return AnswerModel(
      id: id,
      text: textMap,
    );
  }
}
