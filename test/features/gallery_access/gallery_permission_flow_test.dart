import 'dart:typed_data';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_page.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';
import 'package:delivo/features/gallery_access/domain/repositories/gallery_repository.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_access_state.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_access_controller.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authorized permission allows gallery flow', () async {
    final repository = _FakeGalleryRepository(
      permission: GalleryPermission.authorized,
    );

    final container = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(repository),
        galleryChangesProvider.overrideWith(
          (ref) => const Stream<void>.empty(),
        ),
      ],
    );

    addTearDown(container.dispose);

    final controller = container.read(galleryAccessControllerProvider.notifier);

    final granted = await controller.requestPermission();

    expect(granted, isTrue);
    expect(
      container.read(galleryAccessControllerProvider),
      isA<GalleryAccessInitial>(),
    );
  });

  test('limited permission allows gallery flow', () async {
    final repository = _FakeGalleryRepository(
      permission: GalleryPermission.limited,
    );

    final container = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(repository),
        galleryChangesProvider.overrideWith(
          (ref) => const Stream<void>.empty(),
        ),
      ],
    );

    addTearDown(container.dispose);

    final granted = await container
        .read(galleryAccessControllerProvider.notifier)
        .requestPermission();

    expect(granted, isTrue);
  });

  test('denied permission blocks gallery flow', () async {
    final repository = _FakeGalleryRepository(
      permission: GalleryPermission.denied,
    );

    final container = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(repository),
        galleryChangesProvider.overrideWith(
          (ref) => const Stream<void>.empty(),
        ),
      ],
    );

    addTearDown(container.dispose);

    final granted = await container
        .read(galleryAccessControllerProvider.notifier)
        .requestPermission();

    expect(granted, isFalse);
    expect(
      container.read(galleryAccessControllerProvider),
      isA<GalleryAccessPermissionDenied>(),
    );
  });
}

final class _FakeGalleryRepository implements GalleryRepository {
  _FakeGalleryRepository({required this.permission});

  final GalleryPermission permission;

  @override
  Future<Result<GalleryPermission>> getPermissionStatus() async {
    return Success(permission);
  }

  @override
  Future<Result<GalleryPermission>> requestPermission() async {
    return Success(permission);
  }

  @override
  Future<Result<void>> openSettings() async {
    return const Success(null);
  }

  @override
  Future<Result<int>> getPhotoCount() async {
    return const Success(0);
  }

  @override
  Future<Result<GalleryPage>> getPhotos({
    required int page,
    required int pageSize,
  }) async {
    return Success(GalleryPage(photos: const [], page: page, hasMore: false));
  }

  @override
  Future<Result<PhotoAsset?>> getPhotoById(String assetId) async {
    return const Success(null);
  }

  @override
  Future<Result<Uint8List?>> getThumbnail({
    required String assetId,
    required int width,
    required int height,
    required int quality,
  }) async {
    return const Success(null);
  }
}
