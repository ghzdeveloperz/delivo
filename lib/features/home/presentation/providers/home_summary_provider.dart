import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  ref.watch(galleryChangesProvider);

  final repository = ref.watch(galleryRepositoryProvider);
  final permissionResult = await repository.getPermissionStatus();

  final permission = permissionResult.fold<GalleryPermission?>(
    onSuccess: (value) => value,
    onFailure: (_) => null,
  );

  if (permission != GalleryPermission.authorized &&
      permission != GalleryPermission.limited) {
    return HomeSummary.empty;
  }

  final countResult = await repository.getPhotoCount();

  return countResult.fold(
    onSuccess: (count) => HomeSummary(
      unreviewedCount: count,
      favoriteCount: 0,
      markedForDeletionCount: 0,
      estimatedBytesToFree: 0,
    ),
    onFailure: (_) => HomeSummary.empty,
  );
});
