import 'dart:convert';

/// ProgressMerger - Intelligent data merging utility for cross-device progress sync
/// 
/// This class provides pure, unit-testable functions for merging local and cloud progress data.
/// It handles:
/// - Union of answered_questions (set of question IDs)
/// - Union of exams_passed (unique exam IDs)
/// - Conflict resolution for progress resets
/// 
/// All methods are static and pure (no side effects, no DB/Hive calls).

class ProgressMerger {
  /// Merge local and cloud progress data intelligently
  /// 
  /// Parameters:
  /// - local: Map containing local progress from Hive
  ///   Expected keys: 'answers' (Map<questionId, answerData>), 'exam_history' (List)
  /// - cloud: Map containing cloud progress from Supabase
  ///   Expected keys: 'answered_questions' (List<int> or JSON), 'exams_passed' (List<int> or JSON),
  ///                  'last_reset_timestamp' (String ISO8601, optional)
  /// 
  /// Returns: Merged progress Map ready to be saved back to Hive
  static Map<String, dynamic> merge({
    required Map<String, dynamic> local,
    Map<String, dynamic>? cloud,
  }) {
    // If no cloud data, return local as-is
    if (cloud == null || cloud.isEmpty) {
      return Map<String, dynamic>.from(local);
    }

    // Handle reset conflict: If local has a newer reset timestamp, prefer local state
    final localResetTimestamp = _parseTimestamp(local['last_reset_timestamp'] as String?);
    final cloudResetTimestamp = _parseTimestamp(cloud['last_reset_timestamp'] as String?);
    
    if (localResetTimestamp != null && 
        cloudResetTimestamp != null && 
        localResetTimestamp.isAfter(cloudResetTimestamp)) {
      // Local reset is newer - return local state (reset wins)
      return Map<String, dynamic>.from(local);
    }

    // Start with local as base
    final merged = Map<String, dynamic>.from(local);

    // Merge answered_questions (union of question IDs)
    final mergedAnswers = _mergeAnswers(
      localAnswers: local['answers'] as Map<dynamic, dynamic>?,
      cloudAnsweredQuestions: cloud['answered_questions'],
    );
    merged['answers'] = mergedAnswers;

    // Merge exam_history (union of unique exam IDs)
    final mergedExamHistory = _mergeExamHistory(
      localExamHistory: local['exam_history'] as List<dynamic>?,
      cloudExamsPassed: cloud['exams_passed'],
    );
    merged['exam_history'] = mergedExamHistory;

    // Update last_sync_timestamp to most recent
    final localSyncTime = _parseTimestamp(local['last_sync_at'] as String?);
    final cloudSyncTime = _parseTimestamp(cloud['last_sync_at'] as String?);
    if (cloudSyncTime != null && 
        (localSyncTime == null || cloudSyncTime.isAfter(localSyncTime))) {
      merged['last_sync_at'] = cloud['last_sync_at'];
    }

    return merged;
  }

  /// Merge answered questions from local and cloud
  /// 
  /// Local format: Map<questionId (String), {answerId, isCorrect, timestamp}>
  /// Cloud format: List<int> of question IDs, or JSON string, or null
  /// 
  /// Returns: Merged answers Map with union of all question IDs
  static Map<String, dynamic> _mergeAnswers({
    Map<dynamic, dynamic>? localAnswers,
    dynamic cloudAnsweredQuestions,
  }) {
    final merged = <String, dynamic>{};

    // Start with local answers
    if (localAnswers != null) {
      localAnswers.forEach((key, value) {
        final questionId = key.toString();
        if (value is Map) {
          merged[questionId] = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      });
    }

    // Add cloud answered questions (if they exist and are in correct format)
    final cloudQuestionIds = _parseQuestionIds(cloudAnsweredQuestions);
    for (final questionId in cloudQuestionIds) {
      final questionIdStr = questionId.toString();
      // Only add if not already in local (local takes precedence for answer details)
      if (!merged.containsKey(questionIdStr)) {
        // Create a minimal answer entry for cloud questions
        merged[questionIdStr] = {
          'isCorrect': true, // Assume correct if in answered_questions
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    }

    return merged;
  }

  /// Merge exam history from local and cloud
  /// 
  /// Local format: List<Map> with exam details including 'id' field
  /// Cloud format: List<int> of exam IDs, or JSON string, or null
  /// 
  /// Returns: Merged exam history List with unique exam IDs
  static List<Map<String, dynamic>> _mergeExamHistory({
    List<dynamic>? localExamHistory,
    dynamic cloudExamsPassed,
  }) {
    final merged = <Map<String, dynamic>>[];
    final seenExamIds = <int>{};

    // Start with local exam history
    if (localExamHistory != null) {
      for (final exam in localExamHistory) {
        if (exam is Map) {
          final examMap = Map<String, dynamic>.from(
            exam.map((key, value) => MapEntry(key.toString(), value)),
          );
          final examId = _extractExamId(examMap);
          if (examId != null && !seenExamIds.contains(examId)) {
            merged.add(examMap);
            seenExamIds.add(examId);
          }
        }
      }
    }

    // Add cloud exam IDs (if they exist and are not already in local)
    final cloudExamIds = _parseExamIds(cloudExamsPassed);
    for (final examId in cloudExamIds) {
      if (!seenExamIds.contains(examId)) {
        // Create a minimal exam entry for cloud exams
        merged.add({
          'id': examId,
          'date': DateTime.now().toIso8601String(),
          'isPassed': true,
          'scorePercentage': 100, // Default for cloud exams
        });
        seenExamIds.add(examId);
      }
    }

    // Sort by date (most recent first) or by ID (descending)
    merged.sort((a, b) {
      final dateA = _parseTimestamp(a['date'] as String?);
      final dateB = _parseTimestamp(b['date'] as String?);
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA); // Descending
      }
      final idA = _extractExamId(a) ?? 0;
      final idB = _extractExamId(b) ?? 0;
      return idB.compareTo(idA); // Descending
    });

    return merged;
  }

  /// Parse question IDs from various cloud formats
  static List<int> _parseQuestionIds(dynamic data) {
    if (data == null) return [];
    
    if (data is List) {
      return data
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
    }
    
    if (data is String) {
      try {
        // Try parsing as JSON
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return decoded
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList();
        }
      } catch (e) {
        // Not valid JSON, return empty
      }
    }
    
    return [];
  }

  /// Parse exam IDs from various cloud formats
  static List<int> _parseExamIds(dynamic data) {
    if (data == null) return [];
    
    if (data is List) {
      return data
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
    }
    
    if (data is String) {
      try {
        // Try parsing as JSON
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return decoded
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList();
        }
      } catch (e) {
        // Not valid JSON, return empty
      }
    }
    
    return [];
  }

  /// Extract exam ID from exam map
  static int? _extractExamId(Map<String, dynamic> exam) {
    final id = exam['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  /// Parse ISO8601 timestamp string to DateTime
  static DateTime? _parseTimestamp(String? timestampStr) {
    if (timestampStr == null || timestampStr.isEmpty) return null;
    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }
}

