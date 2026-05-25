import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLoggerProvider = Provider<AppLogger>((ref) => const AppLogger());

class AppLogger {
  const AppLogger();

  void info(String message, {Object? data}) {
    _log('INFO', message, data: data);
  }

  void warning(String message, {Object? data}) {
    _log('WARN', message, data: data);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, data: error, stackTrace: stackTrace);
  }

  void _log(String level, String message, {Object? data, StackTrace? stackTrace}) {
    final text = '[$level] $message${data != null ? ' | $data' : ''}';
    if (kDebugMode) {
      debugPrint(text);
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    developer.log(
      text,
      name: 'nutrition_app',
      error: data is Error || data is Exception ? data : null,
      stackTrace: stackTrace,
    );
  }
}
