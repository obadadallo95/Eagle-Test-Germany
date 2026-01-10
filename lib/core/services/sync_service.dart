import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../core/storage/hive_service.dart';
import '../../core/storage/user_preferences_service.dart';
import '../../domain/usecases/exam_readiness_calculator.dart';
import '../debug/app_logger.dart';
import '../utils/progress_merger.dart';
import 'subscription_service.dart';

/// -----------------------------------------------------------------
/// 🔄 SYNC SERVICE / SYNCHRONISIERUNGSSERVICE / خدمة المزامنة
/// -----------------------------------------------------------------
/// Handles synchronization of user progress to Supabase cloud database.
/// This service syncs: questions learned, exams passed, and readiness score.
/// -----------------------------------------------------------------
class SyncService {
  /// Check if Supabase is initialized and available
  static bool get isAvailable {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }

  /// Create or update user profile in Supabase
  /// 
  /// Creates a record in `public.user_profiles` table after anonymous sign-in.
  /// This ensures ALL users (free and pro) are tracked in the database for B2B monitoring.
  /// 
  /// This method will retry up to 3 times if it fails, ensuring reliable user registration.
  static Future<void> createUserProfile({int retryCount = 0, int maxRetries = 3}) async {
    AppLogger.functionStart('createUserProfile', source: 'SyncService');
    AppLogger.info('Creating user profile (attempt ${retryCount + 1}/$maxRetries)', source: 'SyncService');

    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Will retry later.', source: 'SyncService');
      // Retry after a delay if Supabase becomes available
      if (retryCount < maxRetries) {
        Future.delayed(Duration(seconds: (retryCount + 1) * 5), () {
          createUserProfile(retryCount: retryCount + 1, maxRetries: maxRetries);
        });
      }
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      // Get current user ID from Supabase Auth
      String? userId;
      try {
        final session = supabase.auth.currentSession;
        userId = session?.user.id;
      } catch (e) {
        AppLogger.warn('Failed to get user ID from Supabase: $e', source: 'SyncService');
        // Retry if we can't get user ID
        if (retryCount < maxRetries) {
          Future.delayed(Duration(seconds: (retryCount + 1) * 5), () {
            createUserProfile(retryCount: retryCount + 1, maxRetries: maxRetries);
          });
        }
        return;
      }

      if (userId == null || userId.isEmpty) {
        AppLogger.warn('No user ID available. User may not be authenticated. Will retry.', source: 'SyncService');
        // Retry if no user ID
        if (retryCount < maxRetries) {
          Future.delayed(Duration(seconds: (retryCount + 1) * 5), () {
            createUserProfile(retryCount: retryCount + 1, maxRetries: maxRetries);
          });
        }
        return;
      }

      // Check if profile already exists
      // Note: Profile should be created by Supabase Trigger automatically
      // This method now only serves as a safety net/verification
      final existingProfile = await supabase
          .from('user_profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingProfile != null) {
        AppLogger.info('User profile already exists for user: $userId (created by Trigger)', source: 'SyncService');
        
        // Update profile with name if user allows sync
        final allowNameSync = await UserPreferencesService.getAllowNameSync();
        if (allowNameSync) {
          final userName = await UserPreferencesService.getUserName();
          if (userName != null && userName.isNotEmpty) {
            try {
              await supabase
                  .from('user_profiles')
                  .update({
                    'name': userName,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('user_id', userId);
              AppLogger.info('Updated profile name for user: $userId', source: 'SyncService');
            } catch (e) {
              AppLogger.warn('Failed to update profile name: $e', source: 'SyncService');
            }
          }
        }
        
        AppLogger.functionEnd('createUserProfile', source: 'SyncService');
        return;
      }

      // Profile doesn't exist - Trigger may have failed
      // This is a fallback safety net (should rarely be needed)
      AppLogger.warn('Profile not found. Trigger may have failed. Creating profile manually (fallback)...', source: 'SyncService');
      
      // Get user name from local storage (if user allows sync)
      final allowNameSync = await UserPreferencesService.getAllowNameSync();
      String? userName;
      
      if (allowNameSync) {
        userName = await UserPreferencesService.getUserName();
      }
      
      // Create new user profile manually (fallback)
      final profileData = {
        'user_id': userId,
        if (userName != null && userName.isNotEmpty) 'name': userName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase
            .from('user_profiles')
            .insert(profileData);
        
        AppLogger.info('Manual profile creation successful (fallback)', source: 'SyncService');
      } catch (insertError) {
        // Check if table doesn't exist
        if (insertError.toString().contains('Could not find the table') ||
            insertError.toString().contains('PGRST205')) {
          AppLogger.error(
            'CRITICAL: Table user_profiles does not exist in Supabase! '
            'Please run the SQL migration to create the table. '
            'See: supabase_migrations/create_user_profiles_table.sql',
            source: 'SyncService',
            error: insertError,
          );
          rethrow; // Re-throw so caller knows table is missing
        }
        rethrow;
      }

      AppLogger.event(
        'User profile created successfully',
        source: 'SyncService',
        data: {'user_id': userId, 'retryCount': retryCount},
      );

      AppLogger.functionEnd('createUserProfile', source: 'SyncService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create user profile (attempt ${retryCount + 1}/$maxRetries). Will retry if attempts remaining.',
        source: 'SyncService',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Retry on error
      if (retryCount < maxRetries) {
        final delaySeconds = (retryCount + 1) * 5; // Exponential backoff: 5s, 10s, 15s
        AppLogger.info('Retrying user profile creation in $delaySeconds seconds...', source: 'SyncService');
        Future.delayed(Duration(seconds: delaySeconds), () {
          createUserProfile(retryCount: retryCount + 1, maxRetries: maxRetries);
        });
      } else {
        AppLogger.error(
          'Failed to create user profile after $maxRetries attempts. App will continue in offline mode.',
          source: 'SyncService',
        );
      }
      // Don't rethrow - allow app to continue working offline
    }
  }

  /// Verify that user profile exists in Supabase
  /// 
  /// Returns true if profile exists, false otherwise.
  /// This method should be called after createUserProfile() to ensure the profile was actually created.
  static Future<bool> verifyUserProfileExists() async {
    AppLogger.functionStart('verifyUserProfileExists', source: 'SyncService');
    
    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Cannot verify profile.', source: 'SyncService');
      AppLogger.functionEnd('verifyUserProfileExists', source: 'SyncService', result: false);
      return false;
    }
    
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final userId = session?.user.id;
      
      if (userId == null || userId.isEmpty) {
        AppLogger.warn('No user ID available for verification', source: 'SyncService');
        AppLogger.functionEnd('verifyUserProfileExists', source: 'SyncService', result: false);
        return false;
      }
      
      final profile = await supabase
          .from('user_profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      
      final exists = profile != null;
      AppLogger.info(
        'Profile verification: ${exists ? "EXISTS" : "NOT FOUND"} for user: $userId',
        source: 'SyncService',
      );
      AppLogger.functionEnd('verifyUserProfileExists', source: 'SyncService', result: exists);
      return exists;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to verify user profile',
        source: 'SyncService',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.functionEnd('verifyUserProfileExists', source: 'SyncService', result: false);
      return false;
    }
  }

  /// Convert Hive progress format to Supabase format
  /// 
  /// Extracts question IDs and exam IDs from Hive structure
  static Map<String, dynamic> _convertHiveToSupabaseFormat(Map<String, dynamic>? hiveProgress) {
    if (hiveProgress == null) {
      return {
        'answered_questions': <int>[],
        'exams_passed_ids': <int>[],
      };
    }

    // Extract answered question IDs
    final answers = hiveProgress['answers'] as Map<dynamic, dynamic>? ?? {};
    final answeredQuestionIds = <int>[];
    answers.forEach((key, value) {
      if (value is Map) {
        final valueMap = Map<String, dynamic>.from(
          value.map((k, v) => MapEntry(k.toString(), v)),
        );
        // Only include correctly answered questions
        if (valueMap['isCorrect'] == true) {
          final questionId = int.tryParse(key.toString());
          if (questionId != null && questionId > 0) {
            answeredQuestionIds.add(questionId);
          }
        }
      }
    });

    // Extract exam IDs
    final examHistory = hiveProgress['exam_history'] as List<dynamic>? ?? [];
    final examIds = <int>[];
    for (final exam in examHistory) {
      if (exam is Map) {
        final examMap = Map<String, dynamic>.from(
          exam.map((key, value) => MapEntry(key.toString(), value)),
        );
        final isPassed = examMap['isPassed'] as bool? ?? false;
        final scorePercentage = examMap['scorePercentage'] as int? ?? 0;
        
        // Include if passed or score >= 50%
        if (isPassed || scorePercentage >= 50) {
          final examId = examMap['id'];
          if (examId is int) {
            examIds.add(examId);
          } else if (examId is String) {
            final parsedId = int.tryParse(examId);
            if (parsedId != null) {
              examIds.add(parsedId);
            }
          }
        }
      }
    }

    return {
      'answered_questions': answeredQuestionIds,
      'exams_passed_ids': examIds,
      'last_reset_timestamp': hiveProgress['last_reset_timestamp'] as String?,
      'last_sync_at': hiveProgress['last_sync_at'] as String?,
    };
  }

  /// Convert Supabase format back to Hive format
  /// 
  /// Merges cloud data with existing local data
  static Map<String, dynamic> _applyMergedProgressToHive({
    required Map<String, dynamic> localProgress,
    required Map<String, dynamic> mergedProgress,
  }) {
    final result = Map<String, dynamic>.from(localProgress);

    // Update answers from merged progress
    // Convert Hive's _Map<dynamic, dynamic> to Map<String, dynamic>
    final answersRaw = mergedProgress['answers'];
    Map<String, dynamic> mergedAnswers = {};
    if (answersRaw != null && answersRaw is Map) {
      mergedAnswers = Map<String, dynamic>.from(
        answersRaw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    result['answers'] = mergedAnswers;

    // Update exam history from merged progress
    // Convert Hive's List<dynamic> to List<Map<String, dynamic>>
    final examHistoryRaw = mergedProgress['exam_history'];
    List<Map<String, dynamic>> mergedExamHistory = [];
    if (examHistoryRaw != null && examHistoryRaw is List) {
      mergedExamHistory = examHistoryRaw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList();
    }
    result['exam_history'] = mergedExamHistory;

    // Update sync timestamp
    if (mergedProgress['last_sync_at'] != null) {
      result['last_sync_at'] = mergedProgress['last_sync_at'];
    }

    return result;
  }

  /// Sync user progress to Supabase cloud database
  /// 
  /// Gathers data from:
  /// - HiveService: questions learned, exams passed
  /// - ExamReadinessCalculator: readiness score
  /// - Supabase Auth: current user ID
  /// - RevenueCat Customer ID: for shared progress (Pro feature)
  /// 
  /// For Pro users: Progress is shared across up to 3 devices via revenuecat_customer_id
  /// For Free users: Progress is device-specific via user_id
  /// 
  /// Uses intelligent merging via ProgressMerger for Pro users.
  /// Performs an upsert on the `public.user_progress` table.
  /// Handles errors gracefully - does not crash if offline or if sync fails.
  static Future<void> syncProgressToCloud() async {
    AppLogger.functionStart('syncProgressToCloud', source: 'SyncService');

    // Check if Supabase is available
    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Skipping sync.', source: 'SyncService');
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      // Step 1: Gather Data
      AppLogger.info('Gathering user progress data...', source: 'SyncService');

      // Get local progress from Hive
      final progress = HiveService.getUserProgress();

      // Get readiness score from ExamReadinessCalculator
      final readiness = await ExamReadinessCalculator.calculate();
      final readinessScore = readiness.overallScore;

      // Get current user ID from Supabase Auth
      String? userId;
      try {
        final session = supabase.auth.currentSession;
        userId = session?.user.id;
      } catch (e) {
        AppLogger.warn('Failed to get user ID from Supabase: $e', source: 'SyncService');
        // If no user ID, we can't sync - return early
        AppLogger.functionEnd('syncProgressToCloud', source: 'SyncService');
        return;
      }

      if (userId == null || userId.isEmpty) {
        AppLogger.warn('No user ID available. User may not be authenticated. Skipping sync.', source: 'SyncService');
        AppLogger.functionEnd('syncProgressToCloud', source: 'SyncService');
        return;
      }

      // Step 2: Check Pro status FIRST - Only Pro users can sync to cloud
      final isPro = await SubscriptionService.isProUser();
      
      if (!isPro) {
        // Free users: Do not sync to cloud (feature only for Pro subscription)
        AppLogger.info('Free user detected. Cloud sync is disabled (Pro feature only).', 
            source: 'SyncService');
        AppLogger.functionEnd('syncProgressToCloud', source: 'SyncService');
        return;
      }

      // Pro user: Get RevenueCat Customer ID for shared progress
      String? revenuecatCustomerId;
      try {
        final profile = await supabase
            .from('user_profiles')
            .select('revenuecat_customer_id')
            .eq('user_id', userId)
            .maybeSingle();
        
        revenuecatCustomerId = profile?['revenuecat_customer_id'] as String?;
        if (revenuecatCustomerId != null && revenuecatCustomerId.isNotEmpty) {
          AppLogger.info('Pro user detected. Progress will be shared via revenuecat_customer_id: $revenuecatCustomerId', 
              source: 'SyncService');
        } else {
          AppLogger.warn('Pro user but no revenuecat_customer_id found. Cannot enable shared progress.', 
              source: 'SyncService');
          // Even if no revenuecat_customer_id, we still sync (but device-specific)
        }
      } catch (e) {
        AppLogger.warn('Failed to get RevenueCat customer ID: $e', source: 'SyncService');
      }

      // Step 3: Get local progress
      final localProgress = progress ?? {};

      // Step 4: Fetch cloud progress (only for Pro users with revenuecat_customer_id)
      Map<String, dynamic>? cloudProgress;
      if (revenuecatCustomerId != null && revenuecatCustomerId.isNotEmpty) {
        // Pro user with revenuecat_customer_id: Fetch shared progress
        AppLogger.info('Fetching shared progress for Pro user...', source: 'SyncService');
        cloudProgress = await supabase
            .from('user_progress')
            .select('answered_questions, exams_passed_ids, last_reset_timestamp, last_sync_at')
            .eq('revenuecat_customer_id', revenuecatCustomerId)
            .order('last_sync_at', ascending: false)
            .limit(1)
            .maybeSingle();
      } else {
        // Pro user without revenuecat_customer_id: Fetch device-specific progress
        AppLogger.info('Fetching device-specific progress for Pro user (no revenuecat_customer_id)...', source: 'SyncService');
        cloudProgress = await supabase
            .from('user_progress')
            .select('answered_questions, exams_passed_ids, last_reset_timestamp, last_sync_at')
            .eq('user_id', userId)
            .maybeSingle();
      }

      // Step 5: Parse cloud progress (JSONB from Supabase may be string or already parsed)
      Map<String, dynamic>? cloudDataForMerge;
      if (cloudProgress != null) {
        // Parse JSONB fields if they're strings
        dynamic answeredQuestions = cloudProgress['answered_questions'];
        if (answeredQuestions is String) {
          try {
            answeredQuestions = jsonDecode(answeredQuestions);
          } catch (e) {
            AppLogger.warn('Failed to parse answered_questions JSON: $e', source: 'SyncService');
            answeredQuestions = [];
          }
        }

        dynamic examsPassedIds = cloudProgress['exams_passed_ids'];
        if (examsPassedIds is String) {
          try {
            examsPassedIds = jsonDecode(examsPassedIds);
          } catch (e) {
            AppLogger.warn('Failed to parse exams_passed_ids JSON: $e', source: 'SyncService');
            examsPassedIds = [];
          }
        }

        cloudDataForMerge = {
          'answered_questions': answeredQuestions,
          'exams_passed': examsPassedIds,
          'last_reset_timestamp': cloudProgress['last_reset_timestamp'] as String?,
          'last_sync_at': cloudProgress['last_sync_at'] as String?,
        };
      }

      // Step 6: Merge local and cloud progress using ProgressMerger
      final mergedProgress = ProgressMerger.merge(
        local: localProgress,
        cloud: cloudDataForMerge,
      );

      // Step 7: Apply merged progress back to local Hive
      final updatedLocalProgress = _applyMergedProgressToHive(
        localProgress: localProgress,
        mergedProgress: mergedProgress,
      );
      await HiveService.saveUserProgress(updatedLocalProgress);
      AppLogger.info('Merged progress saved to local Hive', source: 'SyncService');

      // Step 8: Convert merged progress back to Supabase format for upload
      final mergedSupabaseFormat = _convertHiveToSupabaseFormat(mergedProgress);
      
      // Calculate counts from merged data
      // Safely convert answers from Hive format
      final answersRaw = mergedProgress['answers'];
      Map<String, dynamic> mergedAnswers = {};
      if (answersRaw != null && answersRaw is Map) {
        mergedAnswers = Map<String, dynamic>.from(
          answersRaw.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
      
      final mergedQuestionsLearned = mergedAnswers.values
          .where((v) {
            if (v is Map) {
              return v['isCorrect'] == true;
            }
            return false;
          })
          .length;
      
      // Safely convert exam history from Hive format
      final examHistoryRaw = mergedProgress['exam_history'];
      List<Map<String, dynamic>> mergedExamHistory = [];
      if (examHistoryRaw != null && examHistoryRaw is List) {
        mergedExamHistory = examHistoryRaw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList();
      }
      final mergedExamsPassed = mergedExamHistory.length;

      // Step 9: Prepare sync data for Supabase
      final now = DateTime.now().toIso8601String();
      // Convert readiness_score to integer (0-100) as database expects integer
      final readinessScoreInt = readinessScore.round().clamp(0, 100);
      
      final syncData = {
        'user_id': userId,
        'questions_learned': mergedQuestionsLearned,
        'exams_passed': mergedExamsPassed,
        'readiness_score': readinessScoreInt, // Convert to integer
        'answered_questions': jsonEncode(mergedSupabaseFormat['answered_questions']),
        'exams_passed_ids': jsonEncode(mergedSupabaseFormat['exams_passed_ids']),
        'last_sync_at': now,
        'last_active_at': now, // Update device activity timestamp
        if (mergedSupabaseFormat['last_reset_timestamp'] != null)
          'last_reset_timestamp': mergedSupabaseFormat['last_reset_timestamp'],
        if (revenuecatCustomerId != null && revenuecatCustomerId.isNotEmpty)
          'revenuecat_customer_id': revenuecatCustomerId,
      };

      AppLogger.info('Attempting to upsert merged data to Supabase...', source: 'SyncService');
      AppLogger.info('Merged: questions=$mergedQuestionsLearned, exams=$mergedExamsPassed', source: 'SyncService');

      // Step 10: Upsert to Supabase (only Pro users reach here)
      // Note: RLS policies only allow users to update their own records (auth.uid() = user_id)
      // For shared progress across devices, we only upsert the current device's record
      // Other devices will sync when they connect and fetch the latest progress
      try {
        await supabase
            .from('user_progress')
            .upsert(syncData, onConflict: 'user_id');
        
        AppLogger.info('Progress upserted successfully to Supabase', source: 'SyncService');
      } catch (e) {
        // Check if it's an RLS policy error
        if (e.toString().contains('row-level security') || 
            e.toString().contains('42501') ||
            e.toString().contains('violates row-level security policy')) {
          AppLogger.error(
            'RLS Policy Error: User may not be authenticated or RLS policies are not configured correctly. '
            'Please ensure: 1) User is authenticated, 2) RLS policies are set up for user_progress table.',
            source: 'SyncService',
            error: e,
          );
        } else {
          rethrow; // Re-throw if it's a different error
        }
      }

      AppLogger.event(
        'Progress synced successfully',
        source: 'SyncService',
        data: {
          'questions_learned': mergedQuestionsLearned,
          'exams_passed': mergedExamsPassed,
          'is_shared': revenuecatCustomerId != null && revenuecatCustomerId.isNotEmpty,
          'is_pro': true, // Only Pro users reach here
        },
      );

      AppLogger.functionEnd('syncProgressToCloud', source: 'SyncService');
    } catch (e, stackTrace) {
      // Graceful error handling - do not crash if sync fails
      AppLogger.error(
        'Failed to sync progress to cloud. App will continue in offline mode.',
        source: 'SyncService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - allow app to continue working offline
    }
  }

  /// Restore progress from cloud and merge with local
  /// 
  /// **Pro Feature Only**: This method only works for Pro subscribers.
  /// Free users cannot restore progress from cloud.
  /// 
  /// For Pro users: Restores shared progress from revenuecat_customer_id
  /// 
  /// Uses ProgressMerger to intelligently merge cloud and local data.
  /// Saves merged result back to Hive.
  /// 
  /// Returns true if progress was restored and merged, false otherwise
  static Future<bool> restoreProgressFromCloud() async {
    AppLogger.functionStart('restoreProgressFromCloud', source: 'SyncService');

    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Cannot restore progress.', source: 'SyncService');
      return false;
    }

    final supabase = Supabase.instance.client;

    try {
      final session = supabase.auth.currentSession;
      final userId = session?.user.id;

      if (userId == null || userId.isEmpty) {
        AppLogger.warn('No user ID available. Cannot restore progress.', source: 'SyncService');
        return false;
      }

      // Check Pro status FIRST - Only Pro users can restore from cloud
      final isPro = await SubscriptionService.isProUser();
      
      if (!isPro) {
        // Free users: Cannot restore from cloud (Pro feature only)
        AppLogger.info('Free user detected. Progress restore is disabled (Pro feature only).', 
            source: 'SyncService');
        AppLogger.functionEnd('restoreProgressFromCloud', source: 'SyncService', result: false);
        return false;
      }
      String? revenuecatCustomerId;
      
      if (isPro) {
        try {
          final profile = await supabase
              .from('user_profiles')
              .select('revenuecat_customer_id')
              .eq('user_id', userId)
              .maybeSingle();
          
          revenuecatCustomerId = profile?['revenuecat_customer_id'] as String?;
        } catch (e) {
          AppLogger.warn('Failed to get RevenueCat customer ID: $e', source: 'SyncService');
        }
      }

      // Fetch cloud progress (only Pro users reach here)
      Map<String, dynamic>? cloudProgress;
      if (revenuecatCustomerId != null && revenuecatCustomerId.isNotEmpty) {
        // Pro user with revenuecat_customer_id: Get shared progress
        AppLogger.info('Restoring shared progress for Pro user: $revenuecatCustomerId', source: 'SyncService');
        
        cloudProgress = await supabase
            .from('user_progress')
            .select('answered_questions, exams_passed_ids, last_reset_timestamp, last_sync_at')
            .eq('revenuecat_customer_id', revenuecatCustomerId)
            .order('last_sync_at', ascending: false)
            .limit(1)
            .maybeSingle();
      } else {
        // Pro user without revenuecat_customer_id: Get device-specific progress
        AppLogger.info('Restoring device-specific progress for Pro user (no revenuecat_customer_id): $userId', source: 'SyncService');
        
        cloudProgress = await supabase
            .from('user_progress')
            .select('answered_questions, exams_passed_ids, last_reset_timestamp, last_sync_at')
            .eq('user_id', userId)
            .maybeSingle();
      }

      if (cloudProgress == null) {
        AppLogger.info('No cloud progress found to restore', source: 'SyncService');
        AppLogger.functionEnd('restoreProgressFromCloud', source: 'SyncService', result: false);
        return false;
      }

      // Parse JSONB fields if they're strings
      dynamic answeredQuestions = cloudProgress['answered_questions'];
      if (answeredQuestions is String) {
        try {
          answeredQuestions = jsonDecode(answeredQuestions);
        } catch (e) {
          AppLogger.warn('Failed to parse answered_questions JSON: $e', source: 'SyncService');
          answeredQuestions = [];
        }
      }

      dynamic examsPassedIds = cloudProgress['exams_passed_ids'];
      if (examsPassedIds is String) {
        try {
          examsPassedIds = jsonDecode(examsPassedIds);
        } catch (e) {
          AppLogger.warn('Failed to parse exams_passed_ids JSON: $e', source: 'SyncService');
          examsPassedIds = [];
        }
      }

      // Get local progress
      final localProgress = HiveService.getUserProgress() ?? {};

      // Merge using ProgressMerger
      final mergedProgress = ProgressMerger.merge(
        local: localProgress,
        cloud: {
          'answered_questions': answeredQuestions,
          'exams_passed': examsPassedIds,
          'last_reset_timestamp': cloudProgress['last_reset_timestamp'] as String?,
          'last_sync_at': cloudProgress['last_sync_at'] as String?,
        },
      );

      // Apply merged progress to Hive
      final updatedLocalProgress = _applyMergedProgressToHive(
        localProgress: localProgress,
        mergedProgress: mergedProgress,
      );
      await HiveService.saveUserProgress(updatedLocalProgress);

      AppLogger.info('Progress restored and merged successfully', source: 'SyncService');
      AppLogger.functionEnd('restoreProgressFromCloud', source: 'SyncService', result: true);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore progress from cloud',
        source: 'SyncService',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.functionEnd('restoreProgressFromCloud', source: 'SyncService', result: false);
      return false;
    }
  }
}

