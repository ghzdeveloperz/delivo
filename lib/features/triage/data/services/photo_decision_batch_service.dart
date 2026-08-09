
import 'package:delivo/core/database/app_database.dart';
import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/core/logging/app_logger.dart';
import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:sqflite/sqflite.dart';

final class PhotoDecisionBatchService {
  PhotoDecisionBatchService({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  Future<Result<void>> clearDecisions(
    Iterable<String> assetIds,
  ) async {
    final ids = assetIds.toSet();

    if (ids.isEmpty) {
      return const Success(null);
    }

    try {
      final db = await _database.database;

      await db.transaction((txn) async {
        for (final assetId in ids) {
          await txn.delete(
            'photo_decisions',
            where: 'asset_id = ?',
            whereArgs: <Object?>[assetId],
          );
        }
      });

      return const Success(null);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to clear photo decisions in batch.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  Future<Result<void>> replaceDecision({
    required Iterable<PhotoDecisionRecord> records,
    required PhotoDecision decision,
    String? folderId,
  }) async {
    final items = records.toList(growable: false);

    if (items.isEmpty) {
      return const Success(null);
    }

    if (decision == PhotoDecision.organized &&
        folderId == null) {
      return const Failure(UnexpectedFailure());
    }

    try {
      final db = await _database.database;
      final now = DateTime.now();

      await db.transaction((txn) async {
        for (final record in items) {
          await txn.insert(
            'photo_decisions',
            <String, Object?>{
              'asset_id': record.assetId,
              'decision': decision.index,
              'folder_id':
                  decision == PhotoDecision.organized
                      ? folderId
                      : null,
              'decided_at': now.millisecondsSinceEpoch,
              'asset_created_at':
                  record.assetCreatedAt?.millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        if (decision == PhotoDecision.organized &&
            folderId != null) {
          await txn.update(
            'photo_folders',
            <String, Object?>{
              'updated_at': now.millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: <Object?>[folderId],
          );
        }
      });

      return const Success(null);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to replace photo decisions in batch.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }
}
