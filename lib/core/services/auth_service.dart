import 'package:supabase_flutter/supabase_flutter.dart';
import '../debug/app_logger.dart';

/// -----------------------------------------------------------------
/// 🔐 AUTH SERVICE / AUTHENTIFIZIERUNGSSERVICE / خدمة المصادقة
/// -----------------------------------------------------------------
/// Handles user authentication and profile verification.
/// Relies on Supabase Trigger to automatically create profiles.
/// -----------------------------------------------------------------
class AuthService {
  /// Sign in silently (anonymous authentication)
  /// 
  /// Attempts to sign in anonymously if no session exists.
  /// After sign-in, verifies that the profile was created by the Trigger.
  /// Includes retry mechanism to wait for Trigger to fire.
  /// 
  /// Returns true if authentication and profile verification succeed.
  static Future<bool> signInSilently() async {
    AppLogger.functionStart('signInSilently', source: 'AuthService');

    try {
      final supabase = Supabase.instance.client;
      
      // Check if session already exists
      var session = supabase.auth.currentSession;
      
      if (session == null) {
        // Sign in anonymously
        AppLogger.info('No existing session. Signing in anonymously...', source: 'AuthService');
        
        try {
          final authResponse = await supabase.auth.signInAnonymously();
          session = authResponse.session;
          
          if (session == null) {
            AppLogger.warn('Anonymous sign-in failed: No session returned', source: 'AuthService');
            AppLogger.functionEnd('signInSilently', source: 'AuthService');
            return false;
          }
          
          AppLogger.info('Anonymous authentication successful', source: 'AuthService');
          AppLogger.info('Auth User ID: ${session.user.id}', source: 'AuthService');
        } catch (e) {
          // Check if anonymous auth is disabled
          if (e.toString().contains('anonymous_provider_disabled') || 
              e.toString().contains('Anonymous sign-ins are disabled')) {
            AppLogger.error(
              'CRITICAL: Anonymous authentication is DISABLED in Supabase. '
              'Please enable it in Supabase Dashboard: Authentication → Providers → Anonymous',
              source: 'AuthService',
              error: e,
            );
          } else {
            AppLogger.error(
              'Failed to sign in anonymously',
              source: 'AuthService',
              error: e,
            );
          }
          AppLogger.functionEnd('signInSilently', source: 'AuthService');
          return false;
        }
      } else {
        AppLogger.info('Existing session found', source: 'AuthService');
        AppLogger.info('Auth User ID: ${session.user.id}', source: 'AuthService');
      }

      final userId = session.user.id;
      
      // Verify profile exists (Trigger should have created it)
      // Retry mechanism: Wait for Trigger to fire
      bool profileExists = false;
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 500);
      
      while (!profileExists && retryCount < maxRetries) {
        try {
          // Try to fetch the profile from 'profiles' table
          // Note: The table name might be 'user_profiles' or 'profiles' - adjust as needed
          final profileResponse = await supabase
              .from('user_profiles')
              .select('user_id')
              .eq('user_id', userId)
              .maybeSingle();
          
          if (profileResponse != null) {
            profileExists = true;
            AppLogger.info('Profile verified successfully (attempt ${retryCount + 1})', source: 'AuthService');
            break;
          }
          
          // Profile not found yet - wait and retry
          if (retryCount < maxRetries - 1) {
            AppLogger.info('Profile not found yet. Waiting for Trigger... (attempt ${retryCount + 1}/$maxRetries)', source: 'AuthService');
            await Future.delayed(retryDelay);
          }
          
          retryCount++;
        } catch (e) {
          AppLogger.warn('Error checking profile (attempt ${retryCount + 1}): $e', source: 'AuthService');
          if (retryCount < maxRetries - 1) {
            await Future.delayed(retryDelay);
          }
          retryCount++;
        }
      }
      
      // If profile still doesn't exist after retries, do manual fallback insert
      if (!profileExists) {
        AppLogger.warn('Profile not found after $maxRetries retries. Trigger may have failed. Attempting manual fallback...', source: 'AuthService');
        
        try {
          // Manual fallback: Create profile manually as safety net
          await supabase
              .from('user_profiles')
              .insert({
                'user_id': userId,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
          
          AppLogger.info('Manual profile creation successful (fallback)', source: 'AuthService');
          profileExists = true;
        } catch (fallbackError) {
          AppLogger.error(
            'Critical: Profile creation failed. Both Trigger and manual fallback failed.',
            source: 'AuthService',
            error: fallbackError,
          );
          AppLogger.functionEnd('signInSilently', source: 'AuthService');
          return false;
        }
      }
      
      AppLogger.event('Authentication and profile verification successful', source: 'AuthService');
      AppLogger.functionEnd('signInSilently', source: 'AuthService');
      return true;
      
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to sign in silently. App will work in offline mode.',
        source: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.functionEnd('signInSilently', source: 'AuthService');
      return false;
    }
  }
  
  /// Get current user ID
  /// 
  /// Returns the current authenticated user's ID, or null if not authenticated.
  static String? getCurrentUserId() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session?.user.id;
    } catch (e) {
      AppLogger.warn('Failed to get current user ID: $e', source: 'AuthService');
      return null;
    }
  }
  
  /// Check if user is authenticated
  /// 
  /// Returns true if a valid session exists.
  static bool isAuthenticated() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
}

