
final class GalleryDeletionAttempt {
  const GalleryDeletionAttempt({
    required this.deletedIds,
    required this.failedByException,
  });

  final Set<String> deletedIds;
  final bool failedByException;
}

abstract interface class GalleryDeletionGateway {
  Future<GalleryDeletionAttempt> deleteAssets(
    Set<String> assetIds,
  );
}
