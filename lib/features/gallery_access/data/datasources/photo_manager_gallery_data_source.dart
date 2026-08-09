import 'dart:typed_data';

import 'package:delivo/features/gallery_access/data/datasources/gallery_data_source.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerGalleryDataSource implements GalleryDataSource {
  const PhotoManagerGalleryDataSource();

  static const PermissionRequestOption _permissionRequestOption =
      PermissionRequestOption(
    iosAccessLevel: IosAccessLevel.readWrite,
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  @override
  Future<PermissionState> getPermissionStatus() {
    return PhotoManager.getPermissionState(
      requestOption: _permissionRequestOption,
    );
  }

  @override
  Future<PermissionState> requestPermission() {
    return PhotoManager.requestPermissionExtend(
      requestOption: _permissionRequestOption,
    );
  }

  @override
  Future<void> openSettings() {
    return PhotoManager.openSetting();
  }

  @override
  Future<int> getPhotoCount() {
    return PhotoManager.getAssetCount(
      type: RequestType.image,
    );
  }

  @override
  Future<List<AssetPathEntity>> getImageAlbums() {
    return PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
  }

  @override
  Future<List<AssetEntity>> getAssets({
    required AssetPathEntity path,
    required int page,
    required int pageSize,
  }) {
    return path.getAssetListPaged(
      page: page,
      size: pageSize,
    );
  }

  @override
  Future<AssetEntity?> getAssetById(String id) {
    return AssetEntity.fromId(id);
  }

  @override
  Future<Uint8List?> getThumbnail({
    required AssetEntity asset,
    required int width,
    required int height,
    required int quality,
  }) {
    return asset.thumbnailDataWithSize(
      ThumbnailSize(width, height),
      quality: quality,
    );
  }
}
