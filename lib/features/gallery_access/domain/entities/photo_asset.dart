final class PhotoAsset {
  const PhotoAsset({
    required this.id,
    required this.createdAt,
    required this.width,
    required this.height,
  });

  final String id;
  final DateTime createdAt;
  final int width;
  final int height;

  double get aspectRatio {
    if (height == 0) {
      return 1;
    }

    return width / height;
  }
}
