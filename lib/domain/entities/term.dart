import 'package:equatable/equatable.dart';

/// كيان المصطلح في القاموس - يدعم 6 لغات
class Term extends Equatable {
  final int? id;
  final String term;
  final String? category;
  final Map<String, String> definition; // de, ar, en, tr, uk, ru
  final Map<String, String>? example; // de, ar, en, tr, uk, ru
  final int? relatedQuestionId;
  final List<int>? relatedQuestionIds;
  final List<String> keywords;

  const Term({
    this.id,
    required this.term,
    this.category,
    required this.definition,
    this.example,
    this.relatedQuestionId,
    this.relatedQuestionIds,
    required this.keywords,
  });

  /// الحصول على التعريف باللغة المطلوبة، مع fallback إلى الألمانية
  String getDefinition(String langCode) {
    return definition[langCode] ?? definition['de'] ?? '';
  }

  /// الحصول على مقتطف قصير من التعريف
  String getDefinitionSnippet(String langCode, {int maxLength = 60}) {
    final def = getDefinition(langCode);
    if (def.length <= maxLength) return def;
    return '${def.substring(0, maxLength)}...';
  }

  /// الحصول على مثال باللغة المطلوبة
  String getExample(String langCode) {
    if (example == null || example!.isEmpty) return '';
    return example![langCode] ?? example!['de'] ?? '';
  }

  /// الحصول على جميع معرفات الأسئلة المرتبطة
  List<int> getAllRelatedQuestionIds() {
    final ids = <int>[];
    if (relatedQuestionId != null) {
      ids.add(relatedQuestionId!);
    }
    if (relatedQuestionIds != null) {
      ids.addAll(relatedQuestionIds!);
    }
    return ids.toSet().toList(); // Remove duplicates
  }

  @override
  List<Object?> get props => [id, term, category, definition, example, relatedQuestionId, relatedQuestionIds, keywords];
}

