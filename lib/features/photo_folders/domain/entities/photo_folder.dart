final class PhotoFolder {
  const PhotoFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.photoCount,
    this.coverAssetId,
    this.previewAssetIds = const <String>[],
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int photoCount;
  final String? coverAssetId;

  /// Até três fotos mais recentes da pasta, usadas somente para preview.
  ///
  /// Nenhuma imagem é armazenada no banco. A lista contém apenas assetIds.
  final List<String> previewAssetIds;

  PhotoFolder copyWith({
    String? name,
    DateTime? updatedAt,
    int? photoCount,
    String? coverAssetId,
    List<String>? previewAssetIds,
    bool clearCover = false,
  }) {
    return PhotoFolder(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoCount: photoCount ?? this.photoCount,
      coverAssetId:
          clearCover ? null : coverAssetId ?? this.coverAssetId,
      previewAssetIds:
          previewAssetIds ?? this.previewAssetIds,
    );
  }
}
