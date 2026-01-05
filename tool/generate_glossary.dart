import 'dart:convert';
import 'dart:io';

/// Script to extract political/legal terms from questions.json and generate enriched glossary.json
/// 
/// Usage: dart tool/generate_glossary.dart

void main() async {
  print('🚀 Starting Glossary Generation...\n');

  // Read existing glossary for baseline terms
  final existingGlossaryFile = File('assets/data/glossary.json');
  final existingTerms = <String, Map<String, dynamic>>{};
  
  if (await existingGlossaryFile.exists()) {
    final existingContent = await existingGlossaryFile.readAsString();
    final existingList = json.decode(existingContent) as List<dynamic>;
    for (final term in existingList) {
      final termMap = term as Map<String, dynamic>;
      existingTerms[termMap['term'] as String] = termMap;
    }
    print('📚 Loaded ${existingTerms.length} existing terms from glossary.json');
  }

  // Read questions.json (main file with all questions)
  final questionsFile = File('assets/data/questions.json');
  if (!await questionsFile.exists()) {
    print('❌ Error: questions.json not found!');
    print('   Looking for: ${questionsFile.absolute.path}');
    exit(1);
  }

  print('📖 Reading questions.json...');
  final questionsContent = await questionsFile.readAsString();
  final questions = json.decode(questionsContent) as List<dynamic>;
  print('✅ Loaded ${questions.length} questions from questions.json\n');

  // Political/Legal keywords to extract (B1/C1 level)
  final keywordsToExtract = {
    // From existing glossary
    'Souveränität', 'Opposition', 'Grundgesetz', 'Demokratie', 'Bundestag',
    'Bundesrat', 'Bundeskanzler', 'Bundespräsident', 'Föderalismus', 'Rechtsstaat',
    'Gewaltenteilung', 'Wahl', 'Wahlrecht', 'Parteien', 'Koalition', 'Mehrheit',
    'Grundrechte', 'Meinungsfreiheit', 'Pressefreiheit', 'Religionsfreiheit',
    'Gleichberechtigung', 'Sozialstaat', 'Asylrecht', 'Bürgerpflichten', 'Steuern',
    'Verfassungsschutz', 'Kommunen', 'Bundesländer', 'Petition', 'Volksabstimmung',
    'Europäische Union', 'Menschenwürde', 'Integration', 'Toleranz', 'Solidarität',
    
    // Additional important terms
    'Legislative', 'Exekutive', 'Judikative', 'Verfassung', 'Parlament',
    'Abgeordnete', 'Regierung', 'Staatsoberhaupt', 'Repräsentation', 'Ernennung',
    'Gesetzgebung', 'Justiz', 'Freiheit', 'Menschenrechte', 'Diskriminierung',
    'Flüchtlinge', 'Schutz', 'Gemeinschaft', 'Hilfe', 'Selbstverwaltung',
    'Lokalpolitik', 'Regionen', 'Mitbestimmung', 'Bürgerrecht', 'Stimme',
    'Abstimmung', 'Volk', 'Wahlen', 'Politik', 'Programme', 'Entscheidung',
    'Ethik', 'Gesellschaft', 'Zusammenleben', 'Migration', 'Respekt', 'Vielfalt',
  };

  final extractedTerms = <String, Map<String, dynamic>>{};
  int termId = 1;

  // Process each question
  for (final questionData in questions) {
    final question = questionData as Map<String, dynamic>;
    final questionId = question['id'] as int;
    final questionText = question['question'] as Map<String, dynamic>;
    final questionTextDe = (questionText['de'] as String? ?? '').toLowerCase();
    
    // Check for keywords in question text
    for (final keyword in keywordsToExtract) {
      if (questionTextDe.contains(keyword.toLowerCase())) {
        if (!extractedTerms.containsKey(keyword)) {
          // Create new term entry
          final definition = _generateDefinition(keyword, questionText);
          final example = _generateExample(keyword, questionText);
          
          extractedTerms[keyword] = {
            'id': termId++,
            'term': keyword,
            'category': _getCategory(keyword),
            'definition': definition,
            'example': example,
            'related_question_id': questionId,
            'keywords': _getRelatedKeywords(keyword),
          };
        } else {
          // Add additional related question ID if not already present
          final existing = extractedTerms[keyword]!;
          final relatedIds = existing['related_question_ids'] as List<dynamic>? ?? [];
          if (!relatedIds.contains(questionId)) {
            relatedIds.add(questionId);
            existing['related_question_ids'] = relatedIds;
          }
        }
      }
    }
  }

  // Merge with existing terms (preserve existing definitions if better)
  for (final existingTerm in existingTerms.entries) {
    if (!extractedTerms.containsKey(existingTerm.key)) {
      // Add existing term with new structure
      final termMap = Map<String, dynamic>.from(existingTerm.value);
      termMap['id'] = termId++;
      termMap['category'] = termMap['category'] ?? _getCategory(existingTerm.key);
      termMap['example'] = termMap['example'] ?? {};
      termMap['related_question_id'] = termMap['related_question_id'];
      extractedTerms[existingTerm.key] = termMap;
    } else {
      // Merge: prefer existing definition if it exists
      final existingDef = existingTerm.value['definition'] as Map<String, dynamic>?;
      if (existingDef != null && existingDef.isNotEmpty) {
        extractedTerms[existingTerm.key]!['definition'] = existingDef;
      }
    }
  }

  // Convert to list and sort
  final termsList = extractedTerms.values.toList();
  termsList.sort((a, b) => (a['term'] as String).compareTo(b['term'] as String));

  // Write to file
  final outputFile = File('assets/data/glossary.json');
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(termsList),
  );

  print('✅ Generated ${termsList.length} terms in glossary.json');
  print('📝 File saved to: ${outputFile.absolute.path}\n');
  
  // Print summary
  print('📊 Summary:');
  print('   - New terms extracted: ${extractedTerms.length - existingTerms.length}');
  print('   - Total terms: ${termsList.length}');
}

Map<String, String> _generateDefinition(String term, Map<String, dynamic> questionText) {
  // Use existing definitions from glossary.json if available, otherwise generate simple ones
  // Simple definitions based on term
  final simpleDefs = {
    'Legislative': {
      'de': 'Die gesetzgebende Gewalt (Parlament).',
      'ar': 'السلطة التشريعية (البرلمان).',
      'en': 'The legislative power (Parliament).',
      'tr': 'Yasama yetkisi (Parlamento).',
      'uk': 'Законодавча влада (Парламент).',
      'ru': 'Законодательная власть (Парламент).',
    },
    'Exekutive': {
      'de': 'Die ausführende Gewalt (Regierung).',
      'ar': 'السلطة التنفيذية (الحكومة).',
      'en': 'The executive power (Government).',
      'tr': 'Yürütme yetkisi (Hükümet).',
      'uk': 'Виконавча влада (Уряд).',
      'ru': 'Исполнительная власть (Правительство).',
    },
    'Judikative': {
      'de': 'Die rechtsprechende Gewalt (Gerichte).',
      'ar': 'السلطة القضائية (المحاكم).',
      'en': 'The judicial power (Courts).',
      'tr': 'Yargı yetkisi (Mahkemeler).',
      'uk': 'Судова влада (Суд).',
      'ru': 'Судебная власть (Суды).',
    },
  };

  if (simpleDefs.containsKey(term)) {
    return Map<String, String>.from(simpleDefs[term]!);
  }

  // Fallback: extract from question context
  final questionDe = questionText['de'] as String? ?? '';
  final questionAr = questionText['ar'] as String? ?? '';
  final questionEn = questionText['en'] as String? ?? '';
  final questionTr = questionText['tr'] as String? ?? '';
  final questionUk = questionText['uk'] as String? ?? '';
  final questionRu = questionText['ru'] as String? ?? '';

  return {
    'de': questionDe.isNotEmpty ? 'Erscheint im Kontext: ${questionDe.substring(0, questionDe.length > 100 ? 100 : questionDe.length)}...' : 'Definition für $term',
    'ar': questionAr.isNotEmpty ? 'يظهر في السياق: ${questionAr.substring(0, questionAr.length > 100 ? 100 : questionAr.length)}...' : 'تعريف لـ $term',
    'en': questionEn.isNotEmpty ? 'Appears in context: ${questionEn.substring(0, questionEn.length > 100 ? 100 : questionEn.length)}...' : 'Definition for $term',
    'tr': questionTr.isNotEmpty ? 'Bağlamda görünür: ${questionTr.substring(0, questionTr.length > 100 ? 100 : questionTr.length)}...' : '$term için tanım',
    'uk': questionUk.isNotEmpty ? 'З\'являється в контексті: ${questionUk.substring(0, questionUk.length > 100 ? 100 : questionUk.length)}...' : 'Визначення для $term',
    'ru': questionRu.isNotEmpty ? 'Появляется в контексте: ${questionRu.substring(0, questionRu.length > 100 ? 100 : questionRu.length)}...' : 'Определение для $term',
  };
}

Map<String, String> _generateExample(String term, Map<String, dynamic> questionText) {
  final questionDe = questionText['de'] as String? ?? '';
  final questionAr = questionText['ar'] as String? ?? '';
  final questionEn = questionText['en'] as String? ?? '';
  final questionTr = questionText['tr'] as String? ?? '';
  final questionUk = questionText['uk'] as String? ?? '';
  final questionRu = questionText['ru'] as String? ?? '';

  return {
    'de': questionDe.isNotEmpty ? questionDe : '',
    'ar': questionAr.isNotEmpty ? questionAr : '',
    'en': questionEn.isNotEmpty ? questionEn : '',
    'tr': questionTr.isNotEmpty ? questionTr : '',
    'uk': questionUk.isNotEmpty ? questionUk : '',
    'ru': questionRu.isNotEmpty ? questionRu : '',
  };
}

String _getCategory(String term) {
  final categories = {
    'Legislative': 'Law',
    'Exekutive': 'Law',
    'Judikative': 'Law',
    'Rechtsstaat': 'Law',
    'Gewaltenteilung': 'Law',
    'Grundgesetz': 'Law',
    'Verfassung': 'Law',
    'Bundestag': 'Politics',
    'Bundesrat': 'Politics',
    'Bundeskanzler': 'Politics',
    'Bundespräsident': 'Politics',
    'Demokratie': 'Politics',
    'Wahl': 'Politics',
    'Wahlrecht': 'Politics',
    'Parteien': 'Politics',
    'Koalition': 'Politics',
    'Mehrheit': 'Politics',
    'Opposition': 'Politics',
    'Grundrechte': 'Rights',
    'Meinungsfreiheit': 'Rights',
    'Pressefreiheit': 'Rights',
    'Religionsfreiheit': 'Rights',
    'Gleichberechtigung': 'Rights',
    'Asylrecht': 'Rights',
    'Föderalismus': 'State',
    'Bundesländer': 'State',
    'Kommunen': 'State',
    'Sozialstaat': 'State',
    'Bürgerpflichten': 'State',
    'Steuern': 'State',
    'Souveränität': 'State',
    'Menschenwürde': 'Ethics',
    'Integration': 'Society',
    'Toleranz': 'Society',
    'Solidarität': 'Society',
  };

  return categories[term] ?? 'General';
}

List<String> _getRelatedKeywords(String term) {
  final keywordMap = {
    'Legislative': ['Legislative', 'Parlament', 'Gesetze'],
    'Exekutive': ['Exekutive', 'Regierung', 'Kanzler'],
    'Judikative': ['Judikative', 'Gerichte', 'Justiz'],
    'Rechtsstaat': ['Rechtsstaat', 'Gesetz', 'Justiz', 'Grundrechte'],
    'Gewaltenteilung': ['Gewaltenteilung', 'Legislative', 'Exekutive', 'Judikative'],
    'Bundestag': ['Bundestag', 'Parlament', 'Gesetze', 'Abgeordnete'],
    'Bundesrat': ['Bundesrat', 'Bundesländer', 'Mitwirkung', 'Gesetzgebung'],
    'Demokratie': ['Demokratie', 'Volk', 'Wahlen', 'Mitbestimmung'],
    'Wahl': ['Wahl', 'Stimmrecht', 'Demokratie', 'Abstimmung'],
    'Grundrechte': ['Grundrechte', 'Freiheit', 'Menschenrechte', 'Verfassung'],
  };

  return keywordMap[term] ?? [term];
}

