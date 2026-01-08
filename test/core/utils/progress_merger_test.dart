import 'package:flutter_test/flutter_test.dart';
import 'package:politik_test/core/utils/progress_merger.dart';

void main() {
  group('ProgressMerger', () {
    test('merge: union of answered_questions', () {
      // Local has questions 1, 2, 3
      final local = {
        'answers': {
          '1': {'answerId': 'A', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
          '2': {'answerId': 'B', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
          '3': {'answerId': 'C', 'isCorrect': false, 'timestamp': '2024-01-01T00:00:00Z'},
        },
      };

      // Cloud has questions 2, 4, 5
      final cloud = {
        'answered_questions': [2, 4, 5],
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      // Should have union: 1, 2, 3, 4, 5
      final answers = merged['answers'] as Map<String, dynamic>;
      expect(answers.keys.length, 5);
      expect(answers.containsKey('1'), true);
      expect(answers.containsKey('2'), true);
      expect(answers.containsKey('3'), true);
      expect(answers.containsKey('4'), true);
      expect(answers.containsKey('5'), true);

      // Local answers should preserve their details
      expect(answers['1']?['answerId'], 'A');
      expect(answers['2']?['answerId'], 'B');
      expect(answers['3']?['answerId'], 'C');
    });

    test('merge: union of exams_passed', () {
      // Local has exams 100, 200
      final local = {
        'exam_history': [
          {'id': 100, 'date': '2024-01-01T00:00:00Z', 'isPassed': true, 'scorePercentage': 80},
          {'id': 200, 'date': '2024-01-02T00:00:00Z', 'isPassed': true, 'scorePercentage': 90},
        ],
      };

      // Cloud has exams 200, 300
      final cloud = {
        'exams_passed': [200, 300],
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      // Should have union: 100, 200, 300
      final examHistory = merged['exam_history'] as List<Map<String, dynamic>>;
      expect(examHistory.length, 3);

      final examIds = examHistory.map((e) => e['id'] as int).toList();
      expect(examIds.contains(100), true);
      expect(examIds.contains(200), true);
      expect(examIds.contains(300), true);

      // Local exam details should be preserved
      final exam100 = examHistory.firstWhere((e) => e['id'] == 100);
      expect(exam100['scorePercentage'], 80);
    });

    test('merge: reset-progress conflict resolution - local reset wins', () {
      // Local has a newer reset timestamp
      final local = {
        'answers': {},
        'exam_history': [],
        'last_reset_timestamp': '2024-01-10T00:00:00Z',
      };

      // Cloud has old progress
      final cloud = {
        'answered_questions': [1, 2, 3],
        'exams_passed': [100, 200],
        'last_reset_timestamp': '2024-01-01T00:00:00Z',
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      // Local reset should win - empty progress
      final answers = merged['answers'] as Map<String, dynamic>;
      final examHistory = merged['exam_history'] as List<Map<String, dynamic>>;
      
      expect(answers.isEmpty, true);
      expect(examHistory.isEmpty, true);
    });

    test('merge: reset-progress conflict resolution - cloud reset wins', () {
      // Local has old progress
      final local = {
        'answers': {
          '1': {'answerId': 'A', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
        },
        'exam_history': [
          {'id': 100, 'date': '2024-01-01T00:00:00Z', 'isPassed': true},
        ],
        'last_reset_timestamp': '2024-01-01T00:00:00Z',
      };

      // Cloud has a newer reset timestamp
      final cloud = {
        'answered_questions': [],
        'exams_passed': [],
        'last_reset_timestamp': '2024-01-10T00:00:00Z',
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      // Cloud reset should win - empty progress
      final answers = merged['answers'] as Map<String, dynamic>;
      final examHistory = merged['exam_history'] as List<Map<String, dynamic>>;
      
      expect(answers.isEmpty, true);
      expect(examHistory.isEmpty, true);
    });

    test('merge: handles null cloud data', () {
      final local = {
        'answers': {
          '1': {'answerId': 'A', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
        },
        'exam_history': [
          {'id': 100, 'date': '2024-01-01T00:00:00Z', 'isPassed': true},
        ],
      };

      final merged = ProgressMerger.merge(local: local, cloud: null);

      // Should return local as-is
      expect(merged['answers'], local['answers']);
      expect(merged['exam_history'], local['exam_history']);
    });

    test('merge: handles empty cloud data', () {
      final local = {
        'answers': {
          '1': {'answerId': 'A', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
        },
        'exam_history': [
          {'id': 100, 'date': '2024-01-01T00:00:00Z', 'isPassed': true},
        ],
      };

      final merged = ProgressMerger.merge(local: local, cloud: {});

      // Should return local as-is
      expect(merged['answers'], local['answers']);
      expect(merged['exam_history'], local['exam_history']);
    });

    test('merge: handles JSON string format in cloud data', () {
      final local = {
        'answers': {
          '1': {'answerId': 'A', 'isCorrect': true, 'timestamp': '2024-01-01T00:00:00Z'},
        },
      };

      final cloud = {
        'answered_questions': '[2, 3, 4]', // JSON string
        'exams_passed': '[200, 300]', // JSON string
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      final answers = merged['answers'] as Map<String, dynamic>;
      expect(answers.keys.length, 4); // 1, 2, 3, 4

      final examHistory = merged['exam_history'] as List<Map<String, dynamic>>;
      expect(examHistory.length, 2); // 200, 300
    });

    test('merge: preserves local answer details when merging', () {
      final local = {
        'answers': {
          '1': {
            'answerId': 'A',
            'isCorrect': true,
            'timestamp': '2024-01-01T00:00:00Z',
            'customField': 'localValue',
          },
        },
      };

      final cloud = {
        'answered_questions': [1, 2],
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      final answers = merged['answers'] as Map<String, dynamic>;
      final answer1 = answers['1'] as Map<String, dynamic>;
      
      // Local details should be preserved
      expect(answer1['answerId'], 'A');
      expect(answer1['customField'], 'localValue');
    });

    test('merge: exam history sorted by date (most recent first)', () {
      final local = {
        'exam_history': [
          {'id': 100, 'date': '2024-01-01T00:00:00Z', 'isPassed': true},
          {'id': 200, 'date': '2024-01-03T00:00:00Z', 'isPassed': true},
        ],
      };

      final cloud = {
        'exams_passed': [300],
      };

      final merged = ProgressMerger.merge(local: local, cloud: cloud);

      final examHistory = merged['exam_history'] as List<Map<String, dynamic>>;
      
      // Should be sorted by date descending (most recent first)
      // Cloud exam (300) will have current date, so should be first
      expect(examHistory.isNotEmpty, true);
      // The first exam should be the most recent
      expect(examHistory.first['id'] == 300 || examHistory.first['id'] == 200, true);
    });
  });
}

