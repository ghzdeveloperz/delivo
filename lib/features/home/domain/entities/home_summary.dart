final class HomeSummary {
  const HomeSummary({
    required this.unreviewedCount,
    required this.favoriteCount,
    required this.markedForDeletionCount,
    required this.estimatedBytesToFree,
  });

  final int unreviewedCount;
  final int favoriteCount;
  final int markedForDeletionCount;
  final int estimatedBytesToFree;

  static const HomeSummary empty = HomeSummary(
    unreviewedCount: 0,
    favoriteCount: 0,
    markedForDeletionCount: 0,
    estimatedBytesToFree: 0,
  );
}
