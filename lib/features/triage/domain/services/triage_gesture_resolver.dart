import 'package:delivo/features/triage/domain/entities/triage_gesture_action.dart';

final class TriageGestureResolver {
  const TriageGestureResolver({
    this.distanceThreshold = 88,
    this.velocityThreshold = 700,
    this.dominanceRatio = 1.15,
  });

  final double distanceThreshold;
  final double velocityThreshold;
  final double dominanceRatio;

  TriageGestureAction resolve({
    required double dx,
    required double dy,
    required double velocityX,
    required double velocityY,
  }) {
    final absoluteDx = dx.abs();
    final absoluteDy = dy.abs();
    final absoluteVelocityX = velocityX.abs();
    final absoluteVelocityY = velocityY.abs();

    final horizontalDominant = absoluteDx >= absoluteDy * dominanceRatio;
    final verticalDominant = absoluteDy >= absoluteDx * dominanceRatio;

    if (horizontalDominant) {
      final confirmed =
          absoluteDx >= distanceThreshold ||
          absoluteVelocityX >= velocityThreshold;

      return confirmed
          ? TriageGestureAction.organize
          : TriageGestureAction.cancel;
    }

    if (verticalDominant) {
      final confirmed =
          absoluteDy >= distanceThreshold ||
          absoluteVelocityY >= velocityThreshold;

      if (!confirmed) {
        return TriageGestureAction.cancel;
      }

      return dy < 0 || velocityY < -velocityThreshold
          ? TriageGestureAction.markForDeletion
          : TriageGestureAction.favorite;
    }

    return TriageGestureAction.cancel;
  }
}
