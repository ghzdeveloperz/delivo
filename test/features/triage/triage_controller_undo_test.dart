import 'dart:typed_data';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_page.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';
import 'package:delivo/features/gallery_access/domain/repositories/gallery_repository.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:delivo/features/triage/data/repositories/in_memory_photo_decision_repository.dart';
import 'package:delivo/features/triage/presentation/providers/triage_controller.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:delivo/features/triage/presentation/triage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('undo atomically restores last photo to unreviewed', () async {
    final decisions = InMemoryPhotoDecisionRepository();
    final gallery = _FakeGalleryRepository();

    final container = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(gallery),
        photoDecisionRepositoryProvider.overrideWithValue(decisions),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await decisions.close();
    });

    final controller = container.read(triageControllerProvider.notifier);

    await controller.load();

    expect(container.read(triageControllerProvider), isA<TriageReady>());

    final persisted = await controller.persistDeletionCurrent();
    expect(persisted, isTrue);

    await controller.completePersistedDecision();

    final decisionAfterSave = await decisions.getDecision('asset-1');

    expect(
      decisionAfterSave.fold(
        onSuccess: (value) => value != null,
        onFailure: (_) => false,
      ),
      isTrue,
    );

    await controller.undo();

    final decisionAfterUndo = await decisions.getDecision('asset-1');

    expect(
      decisionAfterUndo.fold(
        onSuccess: (value) => value,
        onFailure: (_) => Object(),
      ),
      isNull,
    );

    final state = container.read(triageControllerProvider);
    expect(state, isA<TriageReady>());
    expect((state as TriageReady).currentPhoto.id, 'asset-1');
  });
}

final class _FakeGalleryRepository implements GalleryRepository {
  final List<PhotoAsset> _photos = <PhotoAsset>[
    PhotoAsset(
      id: 'asset-1',
      createdAt: DateTime(2026, 8, 8),
      width: 1080,
      height: 1920,
    ),
    PhotoAsset(
      id: 'asset-2',
      createdAt: DateTime(2026, 8, 7),
      width: 1080,
      height: 1920,
    ),
  ];

  @override
  Future<Result<GalleryPermission>> getPermissionStatus() async {
    return const Success(GalleryPermission.authorized);
  }

  @override
  Future<Result<GalleryPermission>> requestPermission() async {
    return const Success(GalleryPermission.authorized);
  }

  @override
  Future<Result<void>> openSettings() async {
    return const Success(null);
  }

  @override
  Future<Result<int>> getPhotoCount() async {
    return Success(_photos.length);
  }

  @override
  Future<Result<GalleryPage>> getPhotos({
    required int page,
    required int pageSize,
  }) async {
    if (page > 0) {
      return Success(GalleryPage(photos: const [], page: page, hasMore: false));
    }

    return Success(GalleryPage(photos: _photos, page: 0, hasMore: false));
  }

  @override
  Future<Result<PhotoAsset?>> getPhotoById(String assetId) async {
    for (final photo in _photos) {
      if (photo.id == assetId) {
        return Success(photo);
      }
    }

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
