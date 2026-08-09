import 'dart:async';

import 'package:delivo/core/database/app_database.dart';
import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/core/logging/app_logger.dart';
import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/domain/repositories/photo_folder_repository.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:sqflite/sqflite.dart';

final class SqflitePhotoFolderRepository
    implements PhotoFolderRepository {
  SqflitePhotoFolderRepository({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changesController.stream;

  @override
  Future<Result<List<PhotoFolder>>> getFolders() async {
    try {
      final db = await _database.database;

      final rows = await db.rawQuery(
        '''
        SELECT
          f.id,
          f.name,
          f.created_at,
          f.updated_at,
          f.cover_asset_id,
          COUNT(d.asset_id) AS photo_count,

          (
            SELECT d1.asset_id
            FROM photo_decisions d1
            WHERE d1.folder_id = f.id
              AND d1.decision = ?
            ORDER BY
              COALESCE(d1.asset_created_at, d1.decided_at) DESC,
              d1.decided_at DESC
            LIMIT 1 OFFSET 0
          ) AS preview_1,

          (
            SELECT d2.asset_id
            FROM photo_decisions d2
            WHERE d2.folder_id = f.id
              AND d2.decision = ?
            ORDER BY
              COALESCE(d2.asset_created_at, d2.decided_at) DESC,
              d2.decided_at DESC
            LIMIT 1 OFFSET 1
          ) AS preview_2,

          (
            SELECT d3.asset_id
            FROM photo_decisions d3
            WHERE d3.folder_id = f.id
              AND d3.decision = ?
            ORDER BY
              COALESCE(d3.asset_created_at, d3.decided_at) DESC,
              d3.decided_at DESC
            LIMIT 1 OFFSET 2
          ) AS preview_3

        FROM photo_folders f
        LEFT JOIN photo_decisions d
          ON d.folder_id = f.id
          AND d.decision = ?
        GROUP BY f.id
        ORDER BY
          f.updated_at DESC,
          f.name COLLATE NOCASE ASC
        ''',
        <Object?>[
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
        ],
      );

      return Success(
        rows.map(_folderFromMap).toList(growable: false),
      );
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load photo folders.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<PhotoFolder?>> getFolder(String folderId) async {
    try {
      final db = await _database.database;

      final rows = await db.rawQuery(
        '''
        SELECT
          f.id,
          f.name,
          f.created_at,
          f.updated_at,
          f.cover_asset_id,
          COUNT(d.asset_id) AS photo_count,

          (
            SELECT d1.asset_id
            FROM photo_decisions d1
            WHERE d1.folder_id = f.id
              AND d1.decision = ?
            ORDER BY
              COALESCE(d1.asset_created_at, d1.decided_at) DESC,
              d1.decided_at DESC
            LIMIT 1 OFFSET 0
          ) AS preview_1,

          (
            SELECT d2.asset_id
            FROM photo_decisions d2
            WHERE d2.folder_id = f.id
              AND d2.decision = ?
            ORDER BY
              COALESCE(d2.asset_created_at, d2.decided_at) DESC,
              d2.decided_at DESC
            LIMIT 1 OFFSET 1
          ) AS preview_2,

          (
            SELECT d3.asset_id
            FROM photo_decisions d3
            WHERE d3.folder_id = f.id
              AND d3.decision = ?
            ORDER BY
              COALESCE(d3.asset_created_at, d3.decided_at) DESC,
              d3.decided_at DESC
            LIMIT 1 OFFSET 2
          ) AS preview_3

        FROM photo_folders f
        LEFT JOIN photo_decisions d
          ON d.folder_id = f.id
          AND d.decision = ?
        WHERE f.id = ?
        GROUP BY f.id
        LIMIT 1
        ''',
        <Object?>[
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
          PhotoDecision.organized.index,
          folderId,
        ],
      );

      if (rows.isEmpty) {
        return const Success(null);
      }

      return Success(_folderFromMap(rows.first));
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load photo folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<PhotoFolder>> createFolder(String name) async {
    try {
      final normalized = _normalizeName(name);

      if (normalized.isEmpty) {
        return const Failure(UnexpectedFailure());
      }

      final now = DateTime.now();
      final id = _generateId(now);
      final db = await _database.database;

      await db.insert(
        'photo_folders',
        <String, Object?>{
          'id': id,
          'name': normalized,
          'created_at': now.millisecondsSinceEpoch,
          'updated_at': now.millisecondsSinceEpoch,
          'cover_asset_id': null,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      _notifyChanged();

      return Success(
        PhotoFolder(
          id: id,
          name: normalized,
          createdAt: now,
          updatedAt: now,
          photoCount: 0,
        ),
      );
    } on DatabaseException catch (error, stackTrace) {
      _logFailure(
        'Failed to create photo folder.',
        error,
        stackTrace,
      );
      return const Failure(UnexpectedFailure());
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to create photo folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> renameFolder({
    required String folderId,
    required String name,
  }) async {
    try {
      final normalized = _normalizeName(name);

      if (normalized.isEmpty) {
        return const Failure(UnexpectedFailure());
      }

      final db = await _database.database;

      await db.update(
        'photo_folders',
        <String, Object?>{
          'name': normalized,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: <Object?>[folderId],
      );

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to rename photo folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> deleteFolder(String folderId) async {
    try {
      final db = await _database.database;

      await db.transaction((txn) async {
        await txn.delete(
          'photo_decisions',
          where: 'folder_id = ? AND decision = ?',
          whereArgs: <Object?>[
            folderId,
            PhotoDecision.organized.index,
          ],
        );

        await txn.delete(
          'photo_folders',
          where: 'id = ?',
          whereArgs: <Object?>[folderId],
        );
      });

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to delete photo folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> setCover({
    required String folderId,
    required String? assetId,
  }) async {
    try {
      final db = await _database.database;

      await db.update(
        'photo_folders',
        <String, Object?>{
          'cover_asset_id': assetId,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: <Object?>[folderId],
      );

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to update folder cover.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<List<PhotoFolderItem>>> getItems(
    String folderId,
  ) async {
    try {
      final db = await _database.database;

      final rows = await db.query(
        'photo_decisions',
        columns: const <String>[
          'asset_id',
          'folder_id',
          'decided_at',
          'asset_created_at',
        ],
        where: 'folder_id = ? AND decision = ?',
        whereArgs: <Object?>[
          folderId,
          PhotoDecision.organized.index,
        ],
        orderBy: 'COALESCE(asset_created_at, decided_at) DESC',
      );

      return Success(
        rows.map(_itemFromMap).toList(growable: false),
      );
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to load folder items.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> movePhoto({
    required String assetId,
    required String folderId,
    required DateTime? assetCreatedAt,
  }) async {
    try {
      final db = await _database.database;
      final now = DateTime.now();

      await db.transaction((txn) async {
        await txn.insert(
          'photo_decisions',
          <String, Object?>{
            'asset_id': assetId,
            'decision': PhotoDecision.organized.index,
            'folder_id': folderId,
            'decided_at': now.millisecondsSinceEpoch,
            'asset_created_at':
                assetCreatedAt?.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.update(
          'photo_folders',
          <String, Object?>{
            'updated_at': now.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: <Object?>[folderId],
        );
      });

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to move photo to folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<void>> removePhoto(String assetId) async {
    try {
      final db = await _database.database;

      await db.delete(
        'photo_decisions',
        where: 'asset_id = ? AND decision = ?',
        whereArgs: <Object?>[
          assetId,
          PhotoDecision.organized.index,
        ],
      );

      _notifyChanged();
      return const Success(null);
    } catch (error, stackTrace) {
      _logFailure(
        'Failed to remove photo from folder.',
        error,
        stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  PhotoFolder _folderFromMap(Map<String, Object?> map) {
    final previews = <String>[
      if (map['preview_1'] case final String id) id,
      if (map['preview_2'] case final String id) id,
      if (map['preview_3'] case final String id) id,
    ];

    return PhotoFolder(
      id: map['id']! as String,
      name: map['name']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at']! as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at']! as int,
      ),
      photoCount: (map['photo_count'] as int?) ?? 0,
      coverAssetId: map['cover_asset_id'] as String?,
      previewAssetIds: previews,
    );
  }

  PhotoFolderItem _itemFromMap(Map<String, Object?> map) {
    final created = map['asset_created_at'] as int?;

    return PhotoFolderItem(
      assetId: map['asset_id']! as String,
      folderId: map['folder_id']! as String,
      assignedAt: DateTime.fromMillisecondsSinceEpoch(
        map['decided_at']! as int,
      ),
      assetCreatedAt: created == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(created),
    );
  }

  String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _generateId(DateTime now) {
    return 'folder_${now.microsecondsSinceEpoch}';
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
