import 'package:delivo/core/database/app_database_provider.dart';
import 'package:delivo/core/logging/app_logger_provider.dart';
import 'package:delivo/features/triage/data/repositories/sqflite_photo_decision_repository.dart';
import 'package:delivo/features/triage/domain/repositories/photo_decision_repository.dart';
import 'package:delivo/features/triage/presentation/services/triage_thumbnail_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoDecisionRepositoryProvider =
    Provider<PhotoDecisionRepository>((ref) {
  final repository = SqflitePhotoDecisionRepository(
    database: ref.watch(appDatabaseProvider),
    logger: ref.watch(appLoggerProvider),
  );

  ref.onDispose(repository.close);

  return repository;
});

final photoDecisionRevisionProvider = StreamProvider<int>((ref) async* {
  final repository = ref.watch(photoDecisionRepositoryProvider);

  var revision = 0;
  yield revision;

  await for (final _ in repository.changes) {
    revision++;
    yield revision;
  }
});

final triageThumbnailCacheProvider =
    Provider<TriageThumbnailCache>((ref) {
  final cache = TriageThumbnailCache(maxEntries: 5);

  ref.onDispose(cache.clear);

  return cache;
});
