import '../../domain/entities/term.dart';

/// نموذج بيانات القاموس - يدعم 6 لغات
class GlossaryModel {
  static Term fromJson(Map<String, dynamic> json) {
    // قراءة التعريفات من كائن definition
    final definitionJson = json['definition'] as Map<String, dynamic>;
    final definition = Map<String, String>.from(
      definitionJson.map((key, value) => MapEntry(key, value as String)),
    );

    // قراءة الأمثلة (قد تكون موجودة أو لا)
    final exampleJson = json['example'] as Map<String, dynamic>?;
    final example = exampleJson != null
        ? Map<String, String>.from(
            exampleJson.map((key, value) => MapEntry(key, value as String)),
          )
        : null;

    // قراءة الكلمات المفتاحية (قد تكون موجودة أو لا)
    final keywordsJson = json['keywords'] as List<dynamic>?;
    final keywords = keywordsJson != null
        ? keywordsJson.map((e) => e as String).toList()
        : <String>[];

    // قراءة معرفات الأسئلة المرتبطة
    final relatedQuestionIdsJson = json['related_question_ids'] as List<dynamic>?;
    final relatedQuestionIds = relatedQuestionIdsJson?.map((e) => e as int).toList();

    return Term(
      id: json['id'] as int?,
      term: json['term'] as String,
      category: json['category'] as String?,
      definition: definition,
      example: example,
      relatedQuestionId: json['related_question_id'] as int?,
      relatedQuestionIds: relatedQuestionIds,
      keywords: keywords,
    );
  }

  static List<Term> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }
}

