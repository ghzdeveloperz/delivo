import 'dart:async';

import 'package:delivo/core/database/app_database.dart';
import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/core/logging/app_logger.dart';
import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/domain/repositories/photo_decision_repository.dart';
import 'package:sqflite/sqflite.dart';

final class SqflitePhotoDecisionRepository
    implements PhotoDecisionRepository {
  SqflitePhotoDecisionRepository({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  static const String _table = 'photo_decisions';

  final AppDatabase _database;
  final AppLogger _logger;

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changesController.stream;

  @override
  Future<Result<PhotoDecisionRecord?>> getDecision(
    String assetId,
  ) async {
    try {
      final db = await _database.database;
      final rows = await db.query(
        _table,
        where: 'asset_id = ?',
        whereArgs: <Object?>[assetId],
        limit: 1,
      );

      if (rows.isEmpty) {
        return const Success(null);
      }

      return Success(_fromMap(rows.first));
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load photo decision.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> saveDecision(
    PhotoDecisionRecord decision,
  ) async {
    try {
      final db = await _database.database;

      await db.transaction((txn) async {
        await txn.insert(
          _table,
          _toMap(decision),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to persist photo decision.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> removeDecision(String assetId) async {
    try {
      final db = await _database.database;

      await db.transaction((txn) async {
        await txn.delete(
          _table,
          where: 'asset_id = ?',
          whereArgs: <Object?>[assetId],
        );
      });

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to remove photo decision.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<Set<String>>> getReviewedAssetIds() async {
    try {
      final db = await _database.database;
      final rows = await db.query(
        _table,
        columns: const <String>['asset_id'],
      );

      return Success(
        rows.map((row) => row['asset_id']! as String).toSet(),
      );
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load reviewed asset ids.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<List<PhotoDecisionRecord>>> getByDecision(
    PhotoDecision decision,
  ) async {
    try {
      final db = await _database.database;
      final rows = await db.query(
        _table,
        where: 'decision = ?',
        whereArgs: <Object?>[decision.index],
        orderBy: 'COALESCE(asset_created_at, decided_at) DESC',
      );

      return Success(
        rows.map(_fromMap).toList(growable: false),
      );
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load decisions by state.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<int>> countByDecision(
    PhotoDecision decision,
  ) async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) AS count FROM $_table WHERE decision = ?',
        <Object?>[decision.index],
      );

      return Success(
        Sqflite.firstIntValue(result) ?? 0,
      );
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to count photo decisions.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  Map<String, Object?> _toMap(PhotoDecisionRecord record) {
    return <String, Object?>{
      'asset_id': record.assetId,
      'decision': record.newDecision.index,
      'folder_id': record.newFolderId,
      'decided_at': record.decidedAt.millisecondsSinceEpoch,
      'asset_created_at':
          record.assetCreatedAt?.millisecondsSinceEpoch,
    };
  }

  PhotoDecisionRecord _fromMap(Map<String, Object?> map) {
    final decisionIndex = map['decision']! as int;
    final decidedAt = map['decided_at']! as int;
    final assetCreatedAt = map['asset_created_at'] as int?;

    return PhotoDecisionRecord(
      assetId: map['asset_id']! as String,
      previousDecision: PhotoDecision.unreviewed,
      newDecision: PhotoDecision.values[decisionIndex],
      newFolderId: map['folder_id'] as String?,
      decidedAt: DateTime.fromMillisecondsSinceEpoch(decidedAt),
      assetCreatedAt: assetCreatedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(assetCreatedAt),
    );
  }

  void _notifyChanged() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  void _logFailure(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.error(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> close() async {
    await _changesController.close();
  }
}
