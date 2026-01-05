import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';

/// Extension لتسهيل مراقبة Riverpod Providers
extension ProviderLoggerExtension<T> on ProviderListenable<T> {
  /// مراقبة تغييرات Provider مع AppLogger
  void logChanges(WidgetRef ref, String providerName) {
    ref.listen<T>(this, (previous, next) {
      AppLogger.provider(providerName, action: 'changed', value: next);
      
      if (previous != null) {
        AppLogger.log('Previous: $previous → New: $next', source: providerName);
      }
    });
  }
}

/// Helper function لمراقبة Provider refresh
void logProviderRefresh<T>(WidgetRef ref, ProviderBase<T> provider, String providerName) {
  ref.listen<T>(provider, (previous, next) {
    AppLogger.provider(providerName, action: 'refreshed', value: next);
  });
}

