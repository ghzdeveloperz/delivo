import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';

abstract interface class PhotoFolderRepository {
  Stream<void> get changes;

  Future<Result<List<PhotoFolder>>> getFolders();

  Future<Result<PhotoFolder?>> getFolder(String folderId);

  Future<Result<PhotoFolder>> createFolder(String name);

  Future<Result<void>> renameFolder({
    required String folderId,
    required String name,
  });

  Future<Result<void>> deleteFolder(String folderId);

  Future<Result<void>> setCover({
    required String folderId,
    required String? assetId,
  });

  Future<Result<List<PhotoFolderItem>>> getItems(String folderId);

  Future<Result<void>> movePhoto({
    required String assetId,
    required String folderId,
    required DateTime? assetCreatedAt,
  });

  Future<Result<void>> removePhoto(String assetId);
}
