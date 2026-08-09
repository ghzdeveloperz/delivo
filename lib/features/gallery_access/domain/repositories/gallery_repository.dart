import 'dart:typed_data';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_page.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';

abstract interface class GalleryRepository {
  Future<Result<GalleryPermission>> getPermissionStatus();

  Future<Result<GalleryPermission>> requestPermission();

  Future<Result<void>> openSettings();

  Future<Result<int>> getPhotoCount();

  Future<Result<GalleryPage>> getPhotos({
    required int page,
    required int pageSize,
  });

  Future<Result<PhotoAsset?>> getPhotoById(String assetId);

  Future<Result<Uint8List?>> getThumbnail({
    required String assetId,
    required int width,
    required int height,
    required int quality,
  });
}
