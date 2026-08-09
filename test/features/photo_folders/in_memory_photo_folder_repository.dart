import 'dart:async';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/domain/repositories/photo_folder_repository.dart';

final class InMemoryPhotoFolderRepository
    implements PhotoFolderRepository {
  final Map<String, PhotoFolder> folders =
      <String, PhotoFolder>{};

  final Map<String, PhotoFolderItem> items =
      <String, PhotoFolderItem>{};

  final StreamController<void> _changes =
      StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<Result<PhotoFolder>> createFolder(
    String name,
  ) async {
    final now = DateTime.now();
    final folder = PhotoFolder(
      id: 'folder-${folders.length + 1}',
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
      photoCount: 0,
    );

    folders[folder.id] = folder;
    _changes.add(null);

    return Success(folder);
  }

  @override
  Future<Result<void>> deleteFolder(
    String folderId,
  ) async {
    folders.remove(folderId);
    items.removeWhere(
      (_, item) => item.folderId == folderId,
    );
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<PhotoFolder?>> getFolder(
    String folderId,
  ) async {
    return Success(folders[folderId]);
  }

  @override
  Future<Result<List<PhotoFolder>>> getFolders() async {
    return Success(folders.values.toList());
  }

  @override
  Future<Result<List<PhotoFolderItem>>> getItems(
    String folderId,
  ) async {
    return Success(
      items.values
          .where(
            (item) => item.folderId == folderId,
          )
          .toList(),
    );
  }

  @override
  Future<Result<void>> movePhoto({
    required String assetId,
    required String folderId,
    required DateTime? assetCreatedAt,
  }) async {
    items[assetId] = PhotoFolderItem(
      assetId: assetId,
      folderId: folderId,
      assetCreatedAt: assetCreatedAt,
      assignedAt: DateTime.now(),
    );

    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> removePhoto(
    String assetId,
  ) async {
    items.remove(assetId);
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> renameFolder({
    required String folderId,
    required String name,
  }) async {
    final current = folders[folderId];

    if (current != null) {
      folders[folderId] = current.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );
    }

    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> setCover({
    required String folderId,
    required String? assetId,
  }) async {
    final current = folders[folderId];

    if (current != null) {
      folders[folderId] = current.copyWith(
        coverAssetId: assetId,
        clearCover: assetId == null,
        updatedAt: DateTime.now(),
      );
    }

    _changes.add(null);
    return const Success(null);
  }

  Future<void> close() async {
    await _changes.close();
  }
}
