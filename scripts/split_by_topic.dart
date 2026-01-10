import 'dart:io';
import 'dart:convert';

void main() async {
  // Path to the input file
  final inputFile = File('assets/data/questions_general.json');
  
  if (!await inputFile.exists()) {
    stdout.writeln('Error: File not found: ${inputFile.path}');
    exit(1);
  }

  stdout.writeln('Reading ${inputFile.path}...');
  
  // Read and parse JSON
  final jsonString = await inputFile.readAsString();
  final List<dynamic> questions = jsonDecode(jsonString);
  
  stdout.writeln('Found ${questions.length} questions\n');
  
  // Group questions by topic
  final Map<String, List<dynamic>> groupedQuestions = {};
  
  for (var question in questions) {
    final topic = question['topic'] as String?;
    
    if (topic == null || topic.isEmpty) {
      // Questions without topic go to "mix"
      groupedQuestions.putIfAbsent('mix', () => []).add(question);
    } else {
      groupedQuestions.putIfAbsent(topic, () => []).add(question);
    }
  }
  
  // Define output file names
  final topicFiles = {
    'rights': 'questions_rights.json',
    'system': 'questions_system.json',
    'europe': 'questions_europe.json',
    'history': 'questions_history.json',
    'society': 'questions_society.json',
    'welfare': 'questions_welfare.json',
    'mix': 'questions_mix.json',
  };
  
  // Create output directory if it doesn't exist
  final outputDir = Directory('assets/data');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  // Write each topic group to its own file
  stdout.writeln('Generating topic files...\n');
  
  for (var entry in groupedQuestions.entries) {
    final topic = entry.key;
    final topicQuestions = entry.value;
    final fileName = topicFiles[topic] ?? 'questions_$topic.json';
    final outputFile = File('${outputDir.path}/$fileName');
    
    // Sort questions by ID for consistency
    topicQuestions.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    
    // Write JSON with pretty formatting (2 spaces indentation)
    const jsonEncoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(jsonEncoder.convert(topicQuestions));
    
    stdout.writeln('✓ ${fileName.padRight(25)} : ${topicQuestions.length.toString().padLeft(3)} questions');
  }

  // Print summary
  stdout.writeln('\n${'=' * 50}');
  stdout.writeln('Summary:');
  stdout.writeln('=' * 50);
  
  int total = 0;
  for (var entry in groupedQuestions.entries) {
    final topic = entry.key;
    final count = entry.value.length;
    total += count;
    final percentage = (count / questions.length * 100).toStringAsFixed(1);
    stdout.writeln('${topic.padRight(15)} : ${count.toString().padLeft(3)} questions ($percentage%)');
  }
  
  stdout.writeln('-' * 50);
  stdout.writeln('${'Total'.padRight(15)} : ${total.toString().padLeft(3)} questions');
  stdout.writeln('=' * 50);
  
  if (total != questions.length) {
    stdout.writeln('\n⚠ Warning: Total count mismatch!');
    stdout.writeln('   Expected: ${questions.length}');
    stdout.writeln('   Found: $total');
  } else {
    stdout.writeln('\n✓ All questions processed successfully!');
  }
}

