import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../exceptions/app_exceptions.dart';
import '../debug/app_logger.dart';

/// -----------------------------------------------------------------
/// 🎛️ REMOTE CONFIG SERVICE / FERNKONFIGURATIONSSERVICE / خدمة الإعدادات البعيدة
/// -----------------------------------------------------------------
/// Handles remote configuration checks: maintenance mode and version requirements.
/// -----------------------------------------------------------------
class RemoteConfigService {
  /// Check app status from remote configuration
  /// 
  /// Fetches app_config from Supabase and performs:
  /// 1. Maintenance mode check
  /// 2. Version compatibility check
  /// 
  /// Throws:
  /// - MaintenanceException if maintenance_mode is true
  /// - ForceUpdateException if app version < min_supported_version
  /// 
  /// Returns normally if all checks pass.
  static Future<void> checkAppStatus() async {
    AppLogger.functionStart('checkAppStatus', source: 'RemoteConfigService');

    // Check if Supabase is available
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session == null) {
        AppLogger.warn('No Supabase session. Skipping remote config check. App will work in offline mode.', source: 'RemoteConfigService');
        AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
        return; // Allow app to continue in offline mode
      }
    } catch (e) {
      AppLogger.warn('Supabase not initialized. Skipping remote config check: $e', source: 'RemoteConfigService');
      AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
      return; // Allow app to continue in offline mode
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Fetch app_config (should be a single row)
      AppLogger.info('Fetching app_config from Supabase...', source: 'RemoteConfigService');
      
      final response = await supabase
          .from('app_config')
          .select()
          .limit(1)
          .single();
      
      if (response.isEmpty) {
        AppLogger.warn('app_config table is empty. Skipping checks.', source: 'RemoteConfigService');
        AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
        return; // No config = allow app to continue
      }

      final config = response;
      
      AppLogger.info('App config fetched: $config', source: 'RemoteConfigService');

      // Check 1: Maintenance Mode
      final maintenanceMode = config['maintenance_mode'] as bool? ?? false;
      if (maintenanceMode) {
        final maintenanceMessage = config['maintenance_message'] as String? ?? 
            'The app is currently under maintenance. Please try again later.';
        
        AppLogger.warn('App is in maintenance mode: $maintenanceMessage', source: 'RemoteConfigService');
        AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
        throw MaintenanceException(maintenanceMessage);
      }

      // Check 2: Version Compatibility
      final minSupportedVersion = config['min_supported_version'] as String?;
      if (minSupportedVersion != null && minSupportedVersion.isNotEmpty) {
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        
        AppLogger.info('Version check: current=$currentVersion, min=$minSupportedVersion', source: 'RemoteConfigService');
        
        if (_isVersionBelowMinimum(currentVersion, minSupportedVersion)) {
          AppLogger.warn('App version $currentVersion is below minimum $minSupportedVersion. Force update required.', source: 'RemoteConfigService');
          AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
          throw ForceUpdateException(
            minSupportedVersion: minSupportedVersion,
            currentVersion: currentVersion,
          );
        }
      }

      AppLogger.event('App status check passed', source: 'RemoteConfigService');
      AppLogger.functionEnd('checkAppStatus', source: 'RemoteConfigService');
    } catch (e) {
      // Re-throw MaintenanceException and ForceUpdateException
      if (e is MaintenanceException || e is ForceUpdateException) {
        rethrow;
      }
      
      // For other errors (network, etc.), log and allow app to continue
      AppLogger.error(
        'Failed to check app status. App will continue normally.',
        source: 'RemoteConfigService',
        error: e,
      );
      // Don't rethrow - allow app to continue in offline mode
    }
  }

  /// Compare version strings (e.g., "1.0.3" vs "1.0.2")
  /// Returns true if currentVersion < minVersion
  static bool _isVersionBelowMinimum(String currentVersion, String minVersion) {
    try {
      final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final minParts = minVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      
      // Pad with zeros to ensure same length
      while (currentParts.length < minParts.length) {
        currentParts.add(0);
      }
      while (minParts.length < currentParts.length) {
        minParts.add(0);
      }
      
      // Compare version parts
      for (int i = 0; i < currentParts.length; i++) {
        if (currentParts[i] < minParts[i]) {
          return true;
        } else if (currentParts[i] > minParts[i]) {
          return false;
        }
      }
      
      return false; // Versions are equal
    } catch (e) {
      AppLogger.warn('Failed to compare versions. Assuming version is OK: $e', source: 'RemoteConfigService');
      return false; // On error, assume version is OK
    }
  }
}

