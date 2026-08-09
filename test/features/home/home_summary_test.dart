
import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'calculates gallery progress from reviewed and total photos',
    () {
      const summary = HomeSummary(
        totalPhotoCount: 100,
        reviewedCount: 25,
        unreviewedCount: 75,
        favoriteCount: 10,
        markedForDeletionCount: 5,
        estimatedBytesToFree: 0,
      );

      expect(summary.progress, 0.25);
      expect(summary.progressPercent, 25);
    },
  );

  test(
    'returns zero progress when gallery is empty',
    () {
      expect(HomeSummary.empty.progress, 0);
      expect(HomeSummary.empty.progressPercent, 0);
    },
  );

  test(
    'clamps progress to one',
    () {
      const summary = HomeSummary(
        totalPhotoCount: 10,
        reviewedCount: 20,
        unreviewedCount: 0,
        favoriteCount: 0,
        markedForDeletionCount: 0,
        estimatedBytesToFree: 0,
      );

      expect(summary.progress, 1);
      expect(summary.progressPercent, 100);
    },
  );
}
