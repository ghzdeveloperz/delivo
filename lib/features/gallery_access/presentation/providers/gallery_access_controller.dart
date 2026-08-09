import 'dart:async';

import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_access_state.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final galleryAccessControllerProvider =
    NotifierProvider<GalleryAccessController, GalleryAccessState>(
  GalleryAccessController.new,
);

final class GalleryAccessController extends Notifier<GalleryAccessState> {
  static const int _pageSize = 40;
  static const Duration _changeDebounce = Duration(milliseconds: 500);

  int _nextPage = 0;
  bool _isLoadingNextPage = false;
  Timer? _changeTimer;

  @override
  GalleryAccessState build() {
    ref
      ..listen<AsyncValue<void>>(
        galleryChangesProvider,
        (previous, next) {
          if (next.hasValue && previous?.hasValue == false) {
            _scheduleGalleryRefresh();
            return;
          }

          if (next.hasValue && previous?.hasValue == true) {
            _scheduleGalleryRefresh();
          }
        },
      )
      ..onDispose(() {
        _changeTimer?.cancel();
      });

    return const GalleryAccessInitial();
  }

  Future<bool> requestPermission() async {
    if (state is GalleryAccessRequestingPermission) {
      return false;
    }

    state = const GalleryAccessRequestingPermission();

    final repository = ref.read(galleryRepositoryProvider);
    final result = await repository.requestPermission();

    return result.fold(
      onSuccess: (permission) {
        switch (permission) {
          case GalleryPermission.authorized:
          case GalleryPermission.limited:
            state = const GalleryAccessInitial();
            return true;
          case GalleryPermission.denied:
          case GalleryPermission.restricted:
          case GalleryPermission.notDetermined:
            state = const GalleryAccessPermissionDenied();
            return false;
        }
      },
      onFailure: (error) {
        state = GalleryAccessFailure(_messageFor(error));
        return false;
      },
    );
  }

  Future<void> loadFirstPage() async {
    _nextPage = 0;
    _isLoadingNextPage = false;
    state = const GalleryAccessLoading();

    final repository = ref.read(galleryRepositoryProvider);
    final permissionResult = await repository.getPermissionStatus();

    final permission = permissionResult.fold<GalleryPermission?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    if (permission == null) {
      state = const GalleryAccessFailure(
        'Não foi possível verificar o acesso à sua galeria.',
      );
      return;
    }

    if (permission != GalleryPermission.authorized &&
        permission != GalleryPermission.limited) {
      state = const GalleryAccessPermissionDenied();
      return;
    }

    final result = await repository.getPhotos(
      page: 0,
      pageSize: _pageSize,
    );

    result.fold(
      onSuccess: (page) {
        if (page.photos.isEmpty) {
          state = GalleryAccessEmpty(permission: permission);
          return;
        }

        _nextPage = 1;

        state = GalleryAccessReady(
          photos: page.photos,
          permission: permission,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      onFailure: (error) {
        state = GalleryAccessFailure(_messageFor(error));
      },
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state;

    if (currentState is! GalleryAccessReady ||
        !currentState.hasMore ||
        currentState.isLoadingMore ||
        _isLoadingNextPage) {
      return;
    }

    _isLoadingNextPage = true;
    state = currentState.copyWith(isLoadingMore: true);

    final result = await ref.read(galleryRepositoryProvider).getPhotos(
          page: _nextPage,
          pageSize: _pageSize,
        );

    result.fold(
      onSuccess: (page) {
        final latestState = state;

        if (latestState is! GalleryAccessReady) {
          return;
        }

        final existingIds = latestState.photos
            .map((photo) => photo.id)
            .toSet();

        final newPhotos = page.photos
            .where((photo) => !existingIds.contains(photo.id))
            .toList(growable: false);

        final merged = <PhotoAsset>[
          ...latestState.photos,
          ...newPhotos,
        ];

        _nextPage++;

        state = latestState.copyWith(
          photos: merged,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      onFailure: (_) {
        final latestState = state;

        if (latestState is GalleryAccessReady) {
          state = latestState.copyWith(
            isLoadingMore: false,
          );
        }
      },
    );

    _isLoadingNextPage = false;
  }

  Future<void> refresh() {
    return loadFirstPage();
  }

  Future<void> openSettings() async {
    await ref.read(galleryRepositoryProvider).openSettings();
  }

  void _scheduleGalleryRefresh() {
    final currentState = state;

    if (currentState is! GalleryAccessReady &&
        currentState is! GalleryAccessEmpty) {
      return;
    }

    _changeTimer?.cancel();
    _changeTimer = Timer(
      _changeDebounce,
      () {
        loadFirstPage();
      },
    );
  }

  String _messageFor(Object error) {
    if (error case final AppFailure failure) {
      return failure.message;
    }

    return 'Não foi possível acessar sua galeria.';
  }
}
