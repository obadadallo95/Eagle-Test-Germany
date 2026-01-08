/// -----------------------------------------------------------------
/// ⚠️ APP EXCEPTIONS / ANWENDUNGSAUSNAHMEN / استثناءات التطبيق
/// -----------------------------------------------------------------
/// Custom exceptions for app status checks (maintenance, force update).
/// -----------------------------------------------------------------
library;

/// Exception thrown when app is in maintenance mode
class MaintenanceException implements Exception {
  final String message;
  
  MaintenanceException(this.message);
  
  @override
  String toString() => 'MaintenanceException: $message';
}

/// Exception thrown when app version is too old and must be updated
class ForceUpdateException implements Exception {
  final String minSupportedVersion;
  final String currentVersion;
  
  ForceUpdateException({
    required this.minSupportedVersion,
    required this.currentVersion,
  });
  
  @override
  String toString() => 'ForceUpdateException: Current version $currentVersion is below minimum $minSupportedVersion';
}

