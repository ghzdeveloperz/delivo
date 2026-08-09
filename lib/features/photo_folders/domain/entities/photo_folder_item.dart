final class PhotoFolderItem {
  const PhotoFolderItem({
    required this.assetId,
    required this.folderId,
    required this.assignedAt,
    this.assetCreatedAt,
  });

  final String assetId;
  final String folderId;
  final DateTime assignedAt;
  final DateTime? assetCreatedAt;
}
