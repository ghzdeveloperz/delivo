import 'package:delivo/features/triage/domain/entities/triage_gesture_action.dart';
import 'package:delivo/features/triage/domain/services/triage_gesture_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = TriageGestureResolver();

  group('TriageGestureResolver', () {
    test('upward dominant drag marks for deletion', () {
      final action = resolver.resolve(
        dx: 10,
        dy: -120,
        velocityX: 0,
        velocityY: -200,
      );

      expect(action, TriageGestureAction.markForDeletion);
    });

    test('downward dominant drag favorites', () {
      final action = resolver.resolve(
        dx: 8,
        dy: 130,
        velocityX: 0,
        velocityY: 180,
      );

      expect(action, TriageGestureAction.favorite);
    });

    test('horizontal drag organizes', () {
      final action = resolver.resolve(
        dx: 120,
        dy: 20,
        velocityX: 100,
        velocityY: 0,
      );

      expect(action, TriageGestureAction.organize);
    });

    test('small movement cancels', () {
      final action = resolver.resolve(
        dx: 30,
        dy: -40,
        velocityX: 100,
        velocityY: -100,
      );

      expect(action, TriageGestureAction.cancel);
    });

    test(
      'fast upward flick marks for deletion even below distance threshold',
      () {
        final action = resolver.resolve(
          dx: 4,
          dy: -32,
          velocityX: 10,
          velocityY: -900,
        );

        expect(action, TriageGestureAction.markForDeletion);
      },
    );

    test('fast downward flick favorites even below distance threshold', () {
      final action = resolver.resolve(
        dx: 4,
        dy: 32,
        velocityX: 10,
        velocityY: 900,
      );

      expect(action, TriageGestureAction.favorite);
    });

    test('ambiguous diagonal movement cancels', () {
      final action = resolver.resolve(
        dx: 100,
        dy: 100,
        velocityX: 0,
        velocityY: 0,
      );

      expect(action, TriageGestureAction.cancel);
    });
  });
}
