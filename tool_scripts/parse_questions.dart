import 'dart:io';
import 'dart:convert';

void main() {
  final files = [
    'assets/data/raw_questions_1.txt',
    'assets/data/raw_questions_2.txt',
    'assets/data/raw_questions_3.txt',
    'assets/data/raw_questions_4.txt',
  ];

  List<Map<String, dynamic>> allQuestions = [];

  for (var file in files) {
    print("Processing $file...");
    final content = File(file).readAsStringSync();
    allQuestions.addAll(parseContent(content));
  }

  // Save to JSON
  final jsonContent = json.encode(allQuestions);
  File('assets/data/questions.json').writeAsStringSync(jsonContent);
  print('Successfully saved ${allQuestions.length} questions to assets/data/questions.json');
}

List<Map<String, dynamic>> parseContent(String content) {
  List<Map<String, dynamic>> questions = [];
  final lines = content.split('\n');
  
  Map<String, dynamic>? currentQuestion;
  String? currentAnswerId;
  String parsingState = 'IDLE'; // IDLE, QUESTION_AR, ANSWERS

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i].trim();
    if (line.isEmpty) continue;

    // Detect New Question: "1 – ..." or "145 - ..."
    final idMatch = RegExp(r'^(\d+)\s*[-–]\s*(.+)').firstMatch(line);
    
    if (idMatch != null) {
      // Save previous if exists
      if (currentQuestion != null) {
        questions.add(currentQuestion);
      }
      
      currentQuestion = {
        'id': int.parse(idMatch.group(1)!),
        'category_id': 'general',
        'question': {
          'de': idMatch.group(2)!.trim(),
          'ar': ''
        },
        'answers': <Map<String, dynamic>>[],
        'correct_answer': ''
      };
      parsingState = 'QUESTION_AR';
      continue;
    }

    // Detect Answer Option: "A: ..."
    final answerMatch = RegExp(r'^([A-D]):\s*(.+)').firstMatch(line);
    if (answerMatch != null && currentQuestion != null) {
      parsingState = 'ANSWERS';
      String id = answerMatch.group(1)!;
      String text = answerMatch.group(2)!.trim();
      
      // Check for checkmark
      if (text.contains('✓')) {
        text = text.replaceAll('✓', '').trim();
        currentQuestion['correct_answer'] = id;
      }
      
      List<dynamic> answers = currentQuestion['answers'];
      answers.add({
        'id': id,
        'text': {
          'de': text,
          'ar': ''
        }
      });
      currentAnswerId = id;
      continue;
    }

    // If not new question query or Answer start, it's either:
    // 1. Arabic Question Text (if state == QUESTION_AR)
    // 2. Arabic Answer Text (if state == ANSWERS)
    // 3. Continuation of German text (unlikely given format)

    if (currentQuestion != null) {
       if (parsingState == 'QUESTION_AR') {
         // Append to AR question
         String currentAr = currentQuestion['question']['ar'];
         currentQuestion['question']['ar'] = currentAr.isEmpty ? line : "$currentAr\n$line";
       } else if (parsingState == 'ANSWERS' && currentAnswerId != null) {
         // Append to current Answer's AR text
         List<dynamic> answers = currentQuestion['answers'];
         var answer = answers.firstWhere((a) => a['id'] == currentAnswerId);
         String currentAr = answer['text']['ar'];
         answer['text']['ar'] = currentAr.isEmpty ? line : "$currentAr\n$line";
       }
    }
  }

  // Add last
  if (currentQuestion != null) {
    questions.add(currentQuestion);
  }

  return questions;
}
