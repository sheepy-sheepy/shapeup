import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, data: error, stackTrace: stackTrace);
  }

  void _log(String level, String message,
      {Object? data, StackTrace? stackTrace}) {
    final text = '[$level] $message${data != null ? ' | $data' : ''}';
    if (kDebugMode) {
      debugPrint(text);
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    developer.log(
      text,
      name: 'shapeup',
      error: data is Error || data is Exception ? data : null,
      stackTrace: stackTrace,
    );
  }
}
