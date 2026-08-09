
import 'package:delivo/features/deletion_review/domain/repositories/gallery_deletion_gateway.dart';
import 'package:photo_manager/photo_manager.dart';

final class PhotoManagerGalleryDeletionGateway
    implements GalleryDeletionGateway {
  @override
  Future<GalleryDeletionAttempt> deleteAssets(
    Set<String> assetIds,
  ) async {
    if (assetIds.isEmpty) {
      return const GalleryDeletionAttempt(
        deletedIds: <String>{},
        failedByException: false,
      );
    }

    try {
      final deleted =
          await PhotoManager.editor.deleteWithIds(
        assetIds.toList(growable: false),
      );

      return GalleryDeletionAttempt(
        deletedIds: deleted.toSet(),
        failedByException: false,
      );
    } catch (_) {
      return const GalleryDeletionAttempt(
        deletedIds: <String>{},
        failedByException: true,
      );
    }
  }
}
