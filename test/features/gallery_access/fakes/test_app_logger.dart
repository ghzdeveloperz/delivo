import 'package:delivo/core/logging/app_logger.dart';

final class TestAppLogger implements AppLogger {
  final List<String> messages = <String>[];

  @override
  void debug(String message) {
    messages.add(message);
  }

  @override
  void info(String message) {
    messages.add(message);
  }

  @override
  void warning(String message) {
    messages.add(message);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    messages.add(message);
  }
}
