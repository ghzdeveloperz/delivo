import 'package:delivo/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLoggerProvider = Provider<AppLogger>((ref) => const DebugAppLogger());
