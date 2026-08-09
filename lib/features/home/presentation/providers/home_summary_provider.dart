import 'dart:math' as math;

import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  ref.watch(galleryChangesProvider);

  final galleryRepository = ref.watch(galleryRepositoryProvider);
  final decisionRepository =
      ref.watch(photoDecisionRepositoryProvider);

  final permissionResult =
      await galleryRepository.getPermissionStatus();

  final permission = permissionResult.fold<GalleryPermission?>(
    onSuccess: (value) => value,
    onFailure: (_) => null,
  );

  if (permission != GalleryPermission.authorized &&
      permission != GalleryPermission.limited) {
    return HomeSummary.empty;
  }

  final photoCountResult = await galleryRepository.getPhotoCount();
  final reviewedResult =
      await decisionRepository.getReviewedAssetIds();
  final favoriteResult =
      await decisionRepository.countByDecision(
    PhotoDecision.favorite,
  );
  final deletionResult =
      await decisionRepository.countByDecision(
    PhotoDecision.markedForDeletion,
  );

  final photoCount = photoCountResult.fold<int>(
    onSuccess: (value) => value,
    onFailure: (_) => 0,
  );

  final reviewedCount = reviewedResult.fold<int>(
    onSuccess: (value) => value.length,
    onFailure: (_) => 0,
  );

  final favoriteCount = favoriteResult.fold<int>(
    onSuccess: (value) => value,
    onFailure: (_) => 0,
  );

  final markedCount = deletionResult.fold<int>(
    onSuccess: (value) => value,
    onFailure: (_) => 0,
  );

  return HomeSummary(
    unreviewedCount: math.max(0, photoCount - reviewedCount),
    favoriteCount: favoriteCount,
    markedForDeletionCount: markedCount,
    estimatedBytesToFree: 0,
  );
});
