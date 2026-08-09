import 'dart:typed_data';

import 'package:delivo/features/gallery_access/data/datasources/gallery_data_source.dart';
import 'package:photo_manager/photo_manager.dart';

final class FakeGalleryDataSource implements GalleryDataSource {
  PermissionState permissionState = PermissionState.authorized;
  int photoCount = 0;
  Object? permissionError;
  Object? countError;

  @override
  Future<PermissionState> getPermissionStatus() async {
    if (permissionError case final Object error) {
      throw error;
    }

    return permissionState;
  }

  @override
  Future<PermissionState> requestPermission() async {
    if (permissionError case final Object error) {
      throw error;
    }

    return permissionState;
  }

  @override
  Future<int> getPhotoCount() async {
    if (countError case final Object error) {
      throw error;
    }

    return photoCount;
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<List<AssetPathEntity>> getImageAlbums() async {
    return const [];
  }

  @override
  Future<List<AssetEntity>> getAssets({
    required AssetPathEntity path,
    required int page,
    required int pageSize,
  }) async {
    return const [];
  }

  @override
  Future<AssetEntity?> getAssetById(String id) async {
    return null;
  }

  @override
  Future<Uint8List?> getThumbnail({
    required AssetEntity asset,
    required int width,
    required int height,
    required int quality,
  }) async {
    return null;
  }
}
