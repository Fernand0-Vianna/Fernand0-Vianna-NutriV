import 'package:flutter/foundation.dart';

class ErrorTrackingService {
  static final ErrorTrackingService _instance =
      ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();

  final List<Map<String, dynamic>> _errors = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    FlutterError.onError = _handleFlutterError;

    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('ErrorTrackingService initialized');
    }
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final error = {
      'timestamp': DateTime.now().toIso8601String(),
      'exception': details.exception.toString(),
      'stack': details.stack.toString(),
      'library': details.library ?? 'unknown',
    };

    _errors.insert(0, error);

    if (_errors.length > 50) {
      _errors.removeLast();
    }

    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    } else {
      _logError(error);
    }
  }

  void recordError(dynamic error, [StackTrace? stack]) {
    final errorData = {
      'timestamp': DateTime.now().toIso8601String(),
      'exception': error.toString(),
      'stack': stack?.toString() ?? 'No stack trace',
    };

    _errors.insert(0, errorData);

    if (_errors.length > 50) {
      _errors.removeLast();
    }

    if (kDebugMode) {
      debugPrint('Error recorded: $error');
    } else {
      _logError(errorData);
    }
  }

  void _logError(Map<String, dynamic> error) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════');
      debugPrint('ERROR CAPTURED:');
      debugPrint('Timestamp: ${error['timestamp']}');
      debugPrint('Exception: ${error['exception']}');
      debugPrint('Stack: ${error['stack']}');
      debugPrint('═══════════════════════════');
    }
  }

  List<Map<String, dynamic>> getErrors() => List.unmodifiable(_errors);

  void clearErrors() {
    _errors.clear();
    if (kDebugMode) {
      debugPrint('Errors cleared');
    }
  }

  int get errorCount => _errors.length;

  bool get hasCrashes => _errors.isNotEmpty;
}
