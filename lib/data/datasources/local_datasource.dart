import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/debug/app_logger.dart';
import '../models/question_model.dart';
import '../../domain/entities/question.dart';

abstract class LocalDataSource {
  /// Load general questions (300 questions)
  Future<List<Question>> getGeneralQuestions();
  
  /// Load state-specific questions for a given state code
  /// Returns empty list if file doesn't exist (graceful fallback)
  Future<List<Question>> getStateQuestions(String stateCode);
  
  /// Legacy method for backward compatibility
  @Deprecated('Use getGeneralQuestions() instead')
  Future<List<Question>> getQuestions() => getGeneralQuestions();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _statesPath = 'assets/data/states/';
  
  // List of topic files to load
  static const List<String> _topicFiles = [
    'assets/data/questions_general.json',
    'assets/data/questions_rights.json',
    'assets/data/questions_system.json',
    'assets/data/questions_europe.json',
    'assets/data/questions_history.json',
    'assets/data/questions_society.json',
    'assets/data/questions_welfare.json',
  ];
  
  @override
  Future<List<Question>> getGeneralQuestions() async {
    final List<Question> allQuestions = [];
    
    // Load all topic files
    for (final filePath in _topicFiles) {
      try {
        final String response = await rootBundle.loadString(filePath);
        final List<dynamic> data = json.decode(response);
        
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final question = QuestionModel.fromJson(item);
              allQuestions.add(question);
            }
          } catch (e) {
            final questionId = (item is Map && item['id'] != null) ? item['id'] : 'unknown';
            AppLogger.warn('Skipping Question ID $questionId from $filePath: $e', source: 'LocalDataSource');
            continue;
          }
        }
      } catch (e) {
        // Graceful fallback: log error but continue loading other files
        AppLogger.error('Failed to load $filePath', source: 'LocalDataSource', error: e);
        continue;
      }
    }
    
    // Fallback: if no questions loaded, try old path for backward compatibility
    if (allQuestions.isEmpty) {
      try {
        final String response = await rootBundle.loadString('assets/data/questions_general.json');
        final List<dynamic> data = json.decode(response);
        
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final question = QuestionModel.fromJson(item);
              // Filter only general questions (stateCode == null)
              if (question.stateCode == null) {
                allQuestions.add(question);
              }
            }
          } catch (e2) {
            final questionId = (item is Map && item['id'] != null) ? item['id'] : 'unknown';
            AppLogger.warn('Skipping Question ID $questionId: $e2', source: 'LocalDataSource');
            continue;
          }
        }
      } catch (e2) {
        // Last fallback: try old questions.json
        try {
          final String response = await rootBundle.loadString('assets/data/questions.json');
          final List<dynamic> data = json.decode(response);
          
          for (var item in data) {
            try {
              if (item is Map<String, dynamic>) {
                final question = QuestionModel.fromJson(item);
                if (question.stateCode == null) {
                  allQuestions.add(question);
                }
              }
            } catch (e3) {
              continue;
            }
          }
        } catch (e3) {
          throw Exception('Failed to load general questions from all sources: $e3');
        }
      }
    }
    
    return allQuestions;
  }
  
  @override
  Future<List<Question>> getStateQuestions(String stateCode) async {
    try {
      // Convert state code to lowercase filename (e.g., 'HE' -> 'hessen.json')
      final fileName = _getStateFileName(stateCode);
      final filePath = '$_statesPath$fileName';
      
      final String response = await rootBundle.loadString(filePath);
      final List<dynamic> data = json.decode(response);
      
      final List<Question> questions = [];
      for (var item in data) {
        try {
          if (item is Map<String, dynamic>) {
            final question = QuestionModel.fromJson(item);
            questions.add(question);
          }
        } catch (e) {
          final questionId = (item is Map && item['id'] != null) ? item['id'] : 'unknown';
          AppLogger.warn('Skipping Question ID $questionId: $e', source: 'LocalDataSource');
          continue;
        }
      }
      
      return questions;
    } catch (e) {
      // Graceful fallback: return empty list if state file doesn't exist
      // This allows the app to continue working with general questions only
      AppLogger.error('Failed to load state questions for $stateCode', source: 'LocalDataSource', error: e);
      return [];
    }
  }
  
  /// Convert state code to filename
  /// Maps state codes (e.g., 'HE', 'BY') to lowercase filenames (e.g., 'hessen.json', 'bayern.json')
  String _getStateFileName(String stateCode) {
    // Map of state codes to filenames
    final stateFileMap = {
      'BW': 'baden-wuerttemberg.json',
      'BY': 'bayern.json',
      'BE': 'berlin.json',
      'BB': 'brandenburg.json',
      'HB': 'bremen.json',
      'HH': 'hamburg.json',
      'HE': 'hessen.json',
      'MV': 'mecklenburg-vorpommern.json',
      'NI': 'niedersachsen.json',
      'NW': 'nordrhein-westfalen.json',
      'RP': 'rheinland-pfalz.json',
      'SL': 'saarland.json',
      'SN': 'sachsen.json',
      'ST': 'sachsen-anhalt.json',
      'SH': 'schleswig-holstein.json',
      'TH': 'thueringen.json',
    };
    
    return stateFileMap[stateCode.toUpperCase()] ?? '${stateCode.toLowerCase()}.json';
  }
  
  @override
  Future<List<Question>> getQuestions() => getGeneralQuestions();
}
