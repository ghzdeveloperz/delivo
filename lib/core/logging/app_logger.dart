import 'package:flutter/foundation.dart';

enum AppLogLevel { debug, info, warning, error }

abstract interface class AppLogger {
  void debug(String message);

  void info(String message);

  void warning(String message);

  void error(String message, {Object? error, StackTrace? stackTrace});
}

final class DebugAppLogger implements AppLogger {
  const DebugAppLogger();

  @override
  void debug(String message) {
    _write(AppLogLevel.debug, message);
  }

  @override
  void info(String message) {
    _write(AppLogLevel.info, message);
  }

  @override
  void warning(String message) {
    _write(AppLogLevel.warning, message);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) {
      return;
    }

    _write(
      AppLogLevel.error,
      error == null ? message : '$message | ${error.runtimeType}',
    );

    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
    }
  }

  void _write(AppLogLevel level, String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[${level.name.toUpperCase()}] $message');
  }
}
