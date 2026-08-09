import 'dart:typed_data';

import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/core/logging/app_logger.dart';
import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/data/datasources/gallery_data_source.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_page.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';
import 'package:delivo/features/gallery_access/domain/repositories/gallery_repository.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerGalleryRepository implements GalleryRepository {
  const PhotoManagerGalleryRepository({
    required GalleryDataSource dataSource,
    required AppLogger logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  final GalleryDataSource _dataSource;
  final AppLogger _logger;

  @override
  Future<Result<GalleryPermission>> getPermissionStatus() async {
    try {
      final state = await _dataSource.getPermissionStatus();
      return Success(_mapPermission(state));
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to read gallery permission status.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<GalleryPermission>> requestPermission() async {
    try {
      final state = await _dataSource.requestPermission();
      return Success(_mapPermission(state));
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to request gallery permission.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> openSettings() async {
    try {
      await _dataSource.openSettings();
      return const Success(null);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to open app settings.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(UnexpectedFailure());
    }
  }

  @override
  Future<Result<int>> getPhotoCount() async {
    try {
      final count = await _dataSource.getPhotoCount();
      return Success(count);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to read gallery photo count.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<GalleryPage>> getPhotos({
    required int page,
    required int pageSize,
  }) async {
    try {
      final paths = await _dataSource.getImageAlbums();

      if (paths.isEmpty) {
        return Success(
          GalleryPage(
            photos: const [],
            page: page,
            hasMore: false,
          ),
        );
      }

      final assets = await _dataSource.getAssets(
        path: paths.first,
        page: page,
        pageSize: pageSize,
      );

      final photos = assets
          .map(
            (asset) => PhotoAsset(
              id: asset.id,
              createdAt: asset.createDateTime,
              width: asset.width,
              height: asset.height,
            ),
          )
          .toList(growable: false);

      return Success(
        GalleryPage(
          photos: photos,
          page: page,
          hasMore: assets.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load gallery page.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  @override
  Future<Result<PhotoAsset?>> getPhotoById(String assetId) async {
    try {
      final asset = await _dataSource.getAssetById(assetId);

      if (asset == null) {
        return const Success(null);
      }

      return Success(
        PhotoAsset(
          id: asset.id,
          createdAt: asset.createDateTime,
          width: asset.width,
          height: asset.height,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load gallery asset.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(AssetNotFoundFailure());
    }
  }

  @override
  Future<Result<Uint8List?>> getThumbnail({
    required String assetId,
    required int width,
    required int height,
    required int quality,
  }) async {
    try {
      final asset = await _dataSource.getAssetById(assetId);

      if (asset == null) {
        return const Success(null);
      }

      final bytes = await _dataSource.getThumbnail(
        asset: asset,
        width: width,
        height: height,
        quality: quality,
      );

      return Success(bytes);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load gallery thumbnail.',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(StorageFailure());
    }
  }

  GalleryPermission _mapPermission(PermissionState state) {
    return switch (state) {
      PermissionState.authorized => GalleryPermission.authorized,
      PermissionState.limited => GalleryPermission.limited,
      PermissionState.denied => GalleryPermission.denied,
      PermissionState.restricted => GalleryPermission.restricted,
      _ => GalleryPermission.notDetermined,
    };
  }
}
