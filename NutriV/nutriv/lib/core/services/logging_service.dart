import 'package:flutter/foundation.dart';

class LoggingService {
  LoggingService._();

  static void info(String tag, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$tag] [$timestamp] $message');
    }
  }

  static void error(String tag, String operation, dynamic error) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$tag] [$timestamp] ❌ $operation error: $error');
    }
  }

  static void warn(String tag, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$tag] [$timestamp] ⚠️ $message');
    }
  }

  static void auth(String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[Auth] [$timestamp] 🔐 $message');
    }
  }
}
