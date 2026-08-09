
import 'package:delivo/core/database/app_database_provider.dart';
import 'package:delivo/core/logging/app_logger_provider.dart';
import 'package:delivo/features/triage/data/services/photo_decision_batch_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoDecisionBatchServiceProvider =
    Provider<PhotoDecisionBatchService>((ref) {
  return PhotoDecisionBatchService(
    database: ref.watch(appDatabaseProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
