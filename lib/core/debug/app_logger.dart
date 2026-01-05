import 'package:flutter/foundation.dart';

/// نظام AppLogger الموحد لمراقبة جميع العمليات في التطبيق
/// 
/// يوفر نظام logging منظم وموحد مع:
/// - Timestamps تلقائية
/// - Source tracking (من أين جاء الـ log)
/// - Error tracking مع StackTrace
/// - Toggle للتفعيل/الإلغاء
class AppLogger {
  static bool enabled = true; // يمكن تعطيله من مكان واحد
  
  // ANSI colors للـ terminal (اختياري)
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';
  static const String _blue = '\x1B[34m';

  /// Log عادي (معلومات عامة)
  static void log(String message, {String? source}) {
    if (!enabled) return;
    _printLog('LOG', message, source, _cyan);
  }

  /// معلومات (Info)
  static void info(String message, {String? source}) {
    if (!enabled) return;
    _printLog('INFO', message, source, _blue);
  }

  /// تحذير (Warning)
  static void warn(String message, {String? source}) {
    if (!enabled) return;
    _printLog('WARN', message, source, _yellow);
  }

  /// خطأ (Error)
  static void error(String message, {String? source, Object? error, StackTrace? stackTrace}) {
    if (!enabled) return;
    _printLog('ERROR', message, source, _red);
    
    if (error != null) {
      debugPrint('$_red  ┃ Error: ${error.toString()}$_reset');
    }
    
    if (stackTrace != null) {
      debugPrint('$_red  ┃ StackTrace:$_reset');
      debugPrint('$_red${stackTrace.toString()}$_reset');
    }
  }

  /// حدث (Event) - لمراقبة الأحداث المهمة
  static void event(String eventName, {String? source, Map<String, dynamic>? data}) {
    if (!enabled) return;
    final message = data != null 
        ? '$eventName | Data: $data'
        : eventName;
    _printLog('EVENT', message, source, _green);
  }

  /// Provider Event - لمراقبة Riverpod Providers
  static void provider(String providerName, {String? action, dynamic value}) {
    if (!enabled) return;
    final message = action != null
        ? '$providerName → $action'
        : providerName;
    
    if (value != null) {
      final valueStr = value.toString();
      final truncatedValue = valueStr.length > 100 
          ? '${valueStr.substring(0, 100)}...' 
          : valueStr;
      _printLog('PROVIDER', '$message | Value: $truncatedValue', null, _magenta);
    } else {
      _printLog('PROVIDER', message, null, _magenta);
    }
  }

  /// Function Start - بداية دالة
  static void functionStart(String functionName, {String? source}) {
    if (!enabled) return;
    _printLog('FUNC', '→ $functionName()', source, _cyan);
  }

  /// Function End - نهاية دالة
  static void functionEnd(String functionName, {String? source, dynamic result}) {
    if (!enabled) return;
    final message = result != null
        ? '← $functionName() → $result'
        : '← $functionName()';
    _printLog('FUNC', message, source, _cyan);
  }

  /// Helper method لطباعة الـ log بشكل منظم
  static void _printLog(String level, String message, String? source, String color) {
    final sourceStr = source != null ? ' | $source' : '';
    
    debugPrint(_reset);
    debugPrint('$color┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$_reset');
    debugPrint('$color┃ [APPLOG] $level$sourceStr$_reset');
    debugPrint('$color┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$_reset');
    debugPrint('$color┃ $message$_reset');
    debugPrint('$color┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$_reset');
    debugPrint(_reset);
  }

  /// Performance tracking - لقياس الأداء
  static void performance(String operation, Duration duration, {String? source}) {
    if (!enabled) return;
    final ms = duration.inMilliseconds;
    final color = ms > 1000 ? _red : (ms > 500 ? _yellow : _green);
    _printLog('PERF', '$operation took ${ms}ms', source, color);
  }
}

