import 'dart:typed_data';

import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:delivo/features/triage/presentation/triage_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final triageControllerProvider =
    NotifierProvider<TriageController, TriageState>(
  TriageController.new,
);

final class TriageController extends Notifier<TriageState> {
  static const int _pageSize = 40;
  static const int _preloadAheadCount = 2;
  static const int _compactAfterIndex = 30;
  static const int _keepPreviousCount = 2;

  final List<PhotoDecisionRecord> _sessionHistory =
      <PhotoDecisionRecord>[];

  int _nextPage = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  TriageState build() {
    return const TriageInitial();
  }

  Future<void> load() async {
    state = const TriageLoading();
    _nextPage = 0;
    _hasMore = true;
    _loadingMore = false;
    _sessionHistory.clear();

    final reviewedResult = await ref
        .read(photoDecisionRepositoryProvider)
        .getReviewedAssetIds();

    final reviewedIds = reviewedResult.fold<Set<String>>(
      onSuccess: (value) => value,
      onFailure: (_) => <String>{},
    );

    final photos = await _loadNextUnreviewedBatch(reviewedIds);

    if (photos == null) {
      return;
    }

    if (photos.isEmpty) {
      state = const TriageEmpty();
      return;
    }

    final ready = TriageReady(
      photos: photos,
      currentIndex: 0,
      canUndo: false,
      isPersisting: false,
      hasMore: _hasMore,
    );

    state = ready;
    _preloadAhead(ready);
  }

  Future<bool> persistFavoriteCurrent() {
    return _persistDecision(PhotoDecision.favorite);
  }

  Future<bool> persistDeletionCurrent() {
    return _persistDecision(PhotoDecision.markedForDeletion);
  }

  Future<bool> persistOrganizeCurrent(
    PhotoFolder folder,
  ) async {
    final currentState = state;

    if (currentState is! TriageReady ||
        currentState.isPersisting) {
      return false;
    }

    state = currentState.copyWith(isPersisting: true);

    final currentPhoto = currentState.currentPhoto;
    final decisionRepository =
        ref.read(photoDecisionRepositoryProvider);

    final previousResult =
        await decisionRepository.getDecision(currentPhoto.id);

    final previousRecord =
        previousResult.fold<PhotoDecisionRecord?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    final folderResult = await ref
        .read(photoFolderRepositoryProvider)
        .movePhoto(
          assetId: currentPhoto.id,
          folderId: folder.id,
          assetCreatedAt: currentPhoto.createdAt,
        );

    final saved = folderResult.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!saved) {
      state = currentState.copyWith(
        isPersisting: false,
      );
      return false;
    }

    _sessionHistory.add(
      PhotoDecisionRecord(
        assetId: currentPhoto.id,
        assetCreatedAt: currentPhoto.createdAt,
        previousDecision:
            previousRecord?.newDecision ??
            PhotoDecision.unreviewed,
        previousFolderId: previousRecord?.newFolderId,
        newDecision: PhotoDecision.organized,
        newFolderId: folder.id,
        decidedAt: DateTime.now(),
      ),
    );

    return true;
  }

  Future<bool> _persistDecision(
    PhotoDecision decision,
  ) async {
    final currentState = state;

    if (currentState is! TriageReady ||
        currentState.isPersisting) {
      return false;
    }

    state = currentState.copyWith(isPersisting: true);

    final currentPhoto = currentState.currentPhoto;
    final repository =
        ref.read(photoDecisionRepositoryProvider);

    final previousResult =
        await repository.getDecision(currentPhoto.id);

    final previousRecord =
        previousResult.fold<PhotoDecisionRecord?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    final record = PhotoDecisionRecord(
      assetId: currentPhoto.id,
      assetCreatedAt: currentPhoto.createdAt,
      previousDecision:
          previousRecord?.newDecision ??
          PhotoDecision.unreviewed,
      previousFolderId: previousRecord?.newFolderId,
      newDecision: decision,
      decidedAt: DateTime.now(),
    );

    final saveResult = await repository.saveDecision(record);

    final saved = saveResult.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!saved) {
      state = currentState.copyWith(
        isPersisting: false,
      );
      return false;
    }

    _sessionHistory.add(record);
    return true;
  }

  Future<void> completePersistedDecision() async {
    final currentState = state;

    if (currentState is! TriageReady ||
        !currentState.isPersisting) {
      return;
    }

    var photos = currentState.photos;
    var nextIndex = currentState.currentIndex + 1;

    if (nextIndex >= photos.length && _hasMore) {
      final reviewed = await ref
          .read(photoDecisionRepositoryProvider)
          .getReviewedAssetIds();

      final reviewedIds = reviewed.fold<Set<String>>(
        onSuccess: (value) => value,
        onFailure: (_) => <String>{},
      );

      final nextBatch =
          await _loadNextUnreviewedBatch(reviewedIds);

      if (nextBatch == null) {
        state = currentState.copyWith(
          isPersisting: false,
        );
        return;
      }

      photos = <PhotoAsset>[
        ...photos,
        ...nextBatch,
      ];
    }

    if (nextIndex >= photos.length) {
      state = const TriageEmpty();
      return;
    }

    var ready = TriageReady(
      photos: photos,
      currentIndex: nextIndex,
      canUndo: true,
      isPersisting: false,
      hasMore: _hasMore,
    );

    ready = _compactIfNeeded(ready);
    state = ready;

    _preloadAhead(ready);

    if (_remainingAhead(ready) <= _preloadAheadCount &&
        _hasMore) {
      await _appendNextBatch();
    }
  }

  void cancelPersistingState() {
    final currentState = state;

    if (currentState is TriageReady &&
        currentState.isPersisting) {
      state = currentState.copyWith(
        isPersisting: false,
      );
    }
  }

  Future<void> undo() async {
    if (_sessionHistory.isEmpty) {
      return;
    }

    final currentState = state;

    if (currentState is TriageReady &&
        currentState.isPersisting) {
      return;
    }

    final lastAction = _sessionHistory.removeLast();

    final restored = await _restoreDecision(lastAction);

    if (!restored) {
      _sessionHistory.add(lastAction);
      return;
    }

    if (currentState is TriageReady) {
      final existingIndex =
          currentState.photos.indexWhere(
        (photo) => photo.id == lastAction.assetId,
      );

      if (existingIndex >= 0) {
        final ready = currentState.copyWith(
          currentIndex: existingIndex,
          canUndo: _sessionHistory.isNotEmpty,
          isPersisting: false,
        );

        state = ready;
        _preloadAhead(ready);
        return;
      }
    }

    final assetResult =
        await ref.read(galleryRepositoryProvider).getPhotoById(
              lastAction.assetId,
            );

    final photo = assetResult.fold<PhotoAsset?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    if (photo == null) {
      return;
    }

    final ready = TriageReady(
      photos: <PhotoAsset>[photo],
      currentIndex: 0,
      canUndo: _sessionHistory.isNotEmpty,
      isPersisting: false,
      hasMore: _hasMore,
    );

    state = ready;
    _preloadAhead(ready);
  }

  Future<bool> _restoreDecision(
    PhotoDecisionRecord record,
  ) async {
    final decisionRepository =
        ref.read(photoDecisionRepositoryProvider);
    final folderRepository =
        ref.read(photoFolderRepositoryProvider);

    if (record.previousDecision ==
        PhotoDecision.unreviewed) {
      final result = record.newDecision ==
              PhotoDecision.organized
          ? await folderRepository.removePhoto(
              record.assetId,
            )
          : await decisionRepository.removeDecision(
              record.assetId,
            );

      return result.fold<bool>(
        onSuccess: (_) => true,
        onFailure: (_) => false,
      );
    }

    if (record.previousDecision ==
            PhotoDecision.organized &&
        record.previousFolderId != null) {
      final result = await folderRepository.movePhoto(
        assetId: record.assetId,
        folderId: record.previousFolderId!,
        assetCreatedAt: record.assetCreatedAt,
      );

      return result.fold<bool>(
        onSuccess: (_) => true,
        onFailure: (_) => false,
      );
    }

    final result = await decisionRepository.saveDecision(
      PhotoDecisionRecord(
        assetId: record.assetId,
        assetCreatedAt: record.assetCreatedAt,
        previousDecision: record.newDecision,
        previousFolderId: record.newFolderId,
        newDecision: record.previousDecision,
        newFolderId: record.previousFolderId,
        decidedAt: DateTime.now(),
      ),
    );

    return result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );
  }

  Future<List<PhotoAsset>?> _loadNextUnreviewedBatch(
    Set<String> reviewedIds,
  ) async {
    final gallery = ref.read(galleryRepositoryProvider);

    while (_hasMore) {
      final result = await gallery.getPhotos(
        page: _nextPage,
        pageSize: _pageSize,
      );

      final page = result.fold(
        onSuccess: (value) => value,
        onFailure: (_) => null,
      );

      if (page == null) {
        state = const TriageFailure(
          'Não foi possível carregar suas fotos.',
        );
        return null;
      }

      _nextPage++;
      _hasMore = page.hasMore;

      final photos = page.photos
          .where(
            (photo) => !reviewedIds.contains(photo.id),
          )
          .toList(growable: false);

      if (photos.isNotEmpty || !_hasMore) {
        return photos;
      }
    }

    return const <PhotoAsset>[];
  }

  Future<void> _appendNextBatch() async {
    if (_loadingMore || !_hasMore) {
      return;
    }

    final currentState = state;

    if (currentState is! TriageReady) {
      return;
    }

    _loadingMore = true;

    final reviewedResult = await ref
        .read(photoDecisionRepositoryProvider)
        .getReviewedAssetIds();

    final reviewedIds =
        reviewedResult.fold<Set<String>>(
      onSuccess: (value) => value,
      onFailure: (_) => <String>{},
    );

    final next =
        await _loadNextUnreviewedBatch(reviewedIds);

    _loadingMore = false;

    if (next == null || next.isEmpty) {
      final latest = state;

      if (latest is TriageReady) {
        state = latest.copyWith(
          hasMore: _hasMore,
        );
      }
      return;
    }

    final latest = state;

    if (latest is! TriageReady) {
      return;
    }

    final existingIds =
        latest.photos.map((photo) => photo.id).toSet();

    final unique = next
        .where(
          (photo) => !existingIds.contains(photo.id),
        )
        .toList(growable: false);

    final ready = latest.copyWith(
      photos: <PhotoAsset>[
        ...latest.photos,
        ...unique,
      ],
      hasMore: _hasMore,
    );

    state = ready;
    _preloadAhead(ready);
  }

  TriageReady _compactIfNeeded(TriageReady ready) {
    if (ready.currentIndex < _compactAfterIndex) {
      return ready;
    }

    final start =
        ready.currentIndex - _keepPreviousCount;

    final compacted = ready.photos.sublist(start);

    return ready.copyWith(
      photos: compacted,
      currentIndex: _keepPreviousCount,
    );
  }

  int _remainingAhead(TriageReady ready) {
    return ready.photos.length - ready.currentIndex - 1;
  }

  void _preloadAhead(TriageReady ready) {
    final repository =
        ref.read(galleryRepositoryProvider);
    final cache = ref.read(
      triageThumbnailCacheProvider,
    );

    final end =
        (ready.currentIndex + _preloadAheadCount + 1)
            .clamp(0, ready.photos.length);

    for (var index = ready.currentIndex;
        index < end;
        index++) {
      final assetId = ready.photos[index].id;

      cache.get(
        assetId: assetId,
        loader: () async {
          final result = await repository.getThumbnail(
            assetId: assetId,
            width: 1200,
            height: 1600,
            quality: 88,
          );

          return result.fold<Uint8List?>(
            onSuccess: (value) => value,
            onFailure: (_) => null,
          );
        },
      );
    }
  }

  String _messageFor(Object error) {
    if (error case final AppFailure failure) {
      return failure.message;
    }

    return 'Não foi possível iniciar a triagem.';
  }
}
