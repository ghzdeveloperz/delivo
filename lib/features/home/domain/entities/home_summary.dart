
final class HomeSummary {
  const HomeSummary({
    required this.totalPhotoCount,
    required this.reviewedCount,
    required this.unreviewedCount,
    required this.favoriteCount,
    required this.markedForDeletionCount,
    required this.estimatedBytesToFree,
  });

  static const HomeSummary empty = HomeSummary(
    totalPhotoCount: 0,
    reviewedCount: 0,
    unreviewedCount: 0,
    favoriteCount: 0,
    markedForDeletionCount: 0,
    estimatedBytesToFree: 0,
  );

  final int totalPhotoCount;
  final int reviewedCount;
  final int unreviewedCount;
  final int favoriteCount;
  final int markedForDeletionCount;
  final int estimatedBytesToFree;

  double get progress {
    if (totalPhotoCount <= 0) {
      return 0;
    }

    return (reviewedCount / totalPhotoCount)
        .clamp(0, 1);
  }

  int get progressPercent {
    return (progress * 100).round();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HomeSummary &&
            totalPhotoCount == other.totalPhotoCount &&
            reviewedCount == other.reviewedCount &&
            unreviewedCount == other.unreviewedCount &&
            favoriteCount == other.favoriteCount &&
            markedForDeletionCount ==
                other.markedForDeletionCount &&
            estimatedBytesToFree ==
                other.estimatedBytesToFree;
  }

  @override
  int get hashCode => Object.hash(
        totalPhotoCount,
        reviewedCount,
        unreviewedCount,
        favoriteCount,
        markedForDeletionCount,
        estimatedBytesToFree,
      );
}
