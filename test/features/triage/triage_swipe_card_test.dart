import 'package:delivo/features/triage/presentation/widgets/triage_swipe_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required Future<bool> Function() onFavorite,
    required Future<bool> Function() onMarkForDeletion,
    required Future<bool> Function() onOrganize,
    Future<void> Function()? onDecisionCompleted,
    VoidCallback? onDecisionAnimationFailed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 480,
            child: TriageSwipeCard(
              enabled: true,
              onFavorite: onFavorite,
              onMarkForDeletion: onMarkForDeletion,
              onOrganize: onOrganize,
              onDecisionCompleted:
                  onDecisionCompleted ?? () async {},
              onDecisionAnimationFailed:
                  onDecisionAnimationFailed ?? () {},
              child: const ColoredBox(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'swipe up marks photo for deletion review',
    (tester) async {
      var deletionCalls = 0;

      await tester.pumpWidget(
        buildSubject(
          onFavorite: () async => true,
          onMarkForDeletion: () async {
            deletionCalls++;
            return true;
          },
          onOrganize: () async => true,
        ),
      );

      await tester.drag(
        find.byType(TriageSwipeCard),
        const Offset(0, -180),
      );

      await tester.pumpAndSettle();

      expect(deletionCalls, 1);
    },
  );

  testWidgets(
    'swipe down favorites photo',
    (tester) async {
      var favoriteCalls = 0;

      await tester.pumpWidget(
        buildSubject(
          onFavorite: () async {
            favoriteCalls++;
            return true;
          },
          onMarkForDeletion: () async => true,
          onOrganize: () async => true,
        ),
      );

      await tester.drag(
        find.byType(TriageSwipeCard),
        const Offset(0, 180),
      );

      await tester.pumpAndSettle();

      expect(favoriteCalls, 1);
    },
  );

  testWidgets(
    'horizontal swipe organizes photo',
    (tester) async {
      var organizeCalls = 0;

      await tester.pumpWidget(
        buildSubject(
          onFavorite: () async => true,
          onMarkForDeletion: () async => true,
          onOrganize: () async {
            organizeCalls++;
            return true;
          },
        ),
      );

      await tester.drag(
        find.byType(TriageSwipeCard),
        const Offset(180, 0),
      );

      await tester.pumpAndSettle();

      expect(organizeCalls, 1);
    },
  );

  testWidgets(
    'small drag cancels without persisting decision',
    (tester) async {
      var favoriteCalls = 0;
      var deletionCalls = 0;
      var organizeCalls = 0;

      await tester.pumpWidget(
        buildSubject(
          onFavorite: () async {
            favoriteCalls++;
            return true;
          },
          onMarkForDeletion: () async {
            deletionCalls++;
            return true;
          },
          onOrganize: () async {
            organizeCalls++;
            return true;
          },
        ),
      );

      await tester.drag(
        find.byType(TriageSwipeCard),
        const Offset(20, 20),
      );

      await tester.pumpAndSettle();

      expect(favoriteCalls, 0);
      expect(deletionCalls, 0);
      expect(organizeCalls, 0);
    },
  );

  testWidgets(
    'failed persistence does not complete decision',
    (tester) async {
      var completed = 0;
      var failed = 0;

      await tester.pumpWidget(
        buildSubject(
          onFavorite: () async => false,
          onMarkForDeletion: () async => true,
          onOrganize: () async => true,
          onDecisionCompleted: () async {
            completed++;
          },
          onDecisionAnimationFailed: () {
            failed++;
          },
        ),
      );

      await tester.drag(
        find.byType(TriageSwipeCard),
        const Offset(0, 180),
      );

      await tester.pumpAndSettle();

      expect(completed, 0);
      expect(failed, 1);
    },
  );
}
