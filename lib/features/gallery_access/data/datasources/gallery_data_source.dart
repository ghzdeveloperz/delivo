import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

abstract interface class GalleryDataSource {
  Future<PermissionState> getPermissionStatus();

  Future<PermissionState> requestPermission();

  Future<void> openSettings();

  Future<int> getPhotoCount();

  Future<List<AssetPathEntity>> getImageAlbums();

  Future<List<AssetEntity>> getAssets({
    required AssetPathEntity path,
    required int page,
    required int pageSize,
  });

  Future<AssetEntity?> getAssetById(String id);

  Future<Uint8List?> getThumbnail({
    required AssetEntity asset,
    required int width,
    required int height,
    required int quality,
  });
}
