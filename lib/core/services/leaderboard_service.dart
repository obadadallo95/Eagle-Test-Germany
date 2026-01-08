import 'package:supabase_flutter/supabase_flutter.dart';
import '../debug/app_logger.dart';

/// -----------------------------------------------------------------
/// 🏆 LEADERBOARD SERVICE / RANGLISTE SERVICE / خدمة لوحة المتصدرين
/// -----------------------------------------------------------------
/// Handles fetching leaderboard data from Supabase.
/// Displays top students based on questions learned.
/// -----------------------------------------------------------------
class LeaderboardService {
  /// Check if Supabase is available
  static bool get isAvailable {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }

  /// Get top students from Supabase
  /// 
  /// Fetches the top 5 users based on questions_learned from user_progress table.
  /// Joins with user_profiles to get display name and avatar.
  /// 
  /// Returns a list of maps with:
  /// - 'rank': int (1, 2, 3, ...)
  /// - 'user_id': String
  /// - 'name': String? (from user_profiles)
  /// - 'avatar_url': String? (from user_profiles)
  /// - 'questions_learned': int
  /// - 'exams_passed': int
  /// - 'readiness_score': double
  static Future<List<Map<String, dynamic>>> getTopStudents() async {
    AppLogger.functionStart('getTopStudents', source: 'LeaderboardService');

    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Returning empty leaderboard.', source: 'LeaderboardService');
      return [];
    }

    final supabase = Supabase.instance.client;

    try {
      // Get current user ID for highlighting
      final session = supabase.auth.currentSession;
      final currentUserId = session?.user.id;

      // Step 1: Get top users from user_progress (simple query, no join)
      final progressResponse = await supabase
          .from('user_progress')
          .select('user_id, questions_learned, exams_passed, readiness_score')
          .order('questions_learned', ascending: false)
          .limit(5);

      AppLogger.info('Fetched ${progressResponse.length} top students', source: 'LeaderboardService');

      if (progressResponse.isEmpty) {
        AppLogger.functionEnd('getTopStudents', source: 'LeaderboardService');
        return [];
      }

      // Step 2: Get user IDs to fetch profiles
      final userIds = progressResponse
          .map((item) => item['user_id'] as String?)
          .whereType<String>()
          .toList();

      // Step 3: Fetch profiles for these users (separate query)
      Map<String, Map<String, dynamic>> profilesMap = {};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await supabase
              .from('user_profiles')
              .select('user_id, name, avatar_url')
              .inFilter('user_id', userIds);
          
          for (final profile in profilesResponse) {
            final id = profile['user_id'] as String?;
            if (id != null) {
              profilesMap[id] = profile;
            }
          }
        } catch (e) {
          // If profiles fetch fails, continue without profiles
          AppLogger.warn('Failed to fetch profiles for leaderboard: $e', source: 'LeaderboardService');
        }
      }

      // Step 4: Transform the response
      final List<Map<String, dynamic>> leaderboard = [];
      
      for (int i = 0; i < progressResponse.length; i++) {
        final item = progressResponse[i];
        final userId = item['user_id'] as String? ?? '';
        
        // Get profile data from map
        final profileData = profilesMap[userId];
        String? name;
        String? avatarUrl;
        
        if (profileData != null) {
          name = profileData['name'] as String?;
          avatarUrl = profileData['avatar_url'] as String?;
        }
        
        // Use name from profile, or fallback to "Guest User"
        final displayName = name?.isNotEmpty == true 
            ? name 
            : 'Guest User';

        leaderboard.add({
          'rank': i + 1,
          'user_id': userId,
          'name': displayName,
          'avatar_url': avatarUrl,
          'questions_learned': item['questions_learned'] as int? ?? 0,
          'exams_passed': item['exams_passed'] as int? ?? 0,
          'readiness_score': (item['readiness_score'] as num?)?.toDouble() ?? 0.0,
          'is_current_user': userId == currentUserId,
        });
      }

      AppLogger.event(
        'Leaderboard fetched successfully',
        source: 'LeaderboardService',
        data: {'count': leaderboard.length},
      );

      AppLogger.functionEnd('getTopStudents', source: 'LeaderboardService');
      return leaderboard;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch leaderboard. Returning empty list.',
        source: 'LeaderboardService',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get current user's rank
  /// 
  /// Returns the rank of the current user based on questions_learned.
  /// Returns null if user is not found or not authenticated.
  static Future<int?> getCurrentUserRank() async {
    AppLogger.functionStart('getCurrentUserRank', source: 'LeaderboardService');

    if (!isAvailable) {
      AppLogger.warn('Supabase not available. Cannot get user rank.', source: 'LeaderboardService');
      return null;
    }

    final supabase = Supabase.instance.client;

    try {
      final session = supabase.auth.currentSession;
      final currentUserId = session?.user.id;

      if (currentUserId == null) {
        AppLogger.warn('No authenticated user. Cannot get rank.', source: 'LeaderboardService');
        return null;
      }

      // Get current user's questions_learned
      final userProgress = await supabase
          .from('user_progress')
          .select('questions_learned')
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (userProgress == null) {
        AppLogger.warn('User progress not found. Cannot calculate rank.', source: 'LeaderboardService');
        return null;
      }

      final userQuestionsLearned = userProgress['questions_learned'] as int? ?? 0;

      // Count how many users have more questions learned
      final countResponse = await supabase
          .from('user_progress')
          .select('user_id')
          .gt('questions_learned', userQuestionsLearned);

      // Rank is count + 1
      final rank = countResponse.length + 1;

      AppLogger.info('Current user rank: $rank', source: 'LeaderboardService');
      AppLogger.functionEnd('getCurrentUserRank', source: 'LeaderboardService');
      return rank;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get current user rank.',
        source: 'LeaderboardService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

