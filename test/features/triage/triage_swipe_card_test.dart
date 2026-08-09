import 'package:delivo/features/triage/presentation/widgets/triage_swipe_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('up swipe marks photo for deletion', (tester) async {
    var deletionCalls = 0;
    var completedCalls = 0;

    await tester.pumpWidget(
      _TestApp(
        child: TriageSwipeCard(
          enabled: true,
          onFavorite: () async => true,
          onMarkForDeletion: () async {
            deletionCalls++;
            return true;
          },
          onDecisionCompleted: () async {
            completedCalls++;
          },
          onDecisionAnimationFailed: () {},
          onOrganize: () async {},
          child: const ColoredBox(color: Colors.black),
        ),
      ),
    );

    await tester.drag(find.byType(TriageSwipeCard), const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(deletionCalls, 1);
    expect(completedCalls, 1);
  });

  testWidgets('down swipe favorites photo', (tester) async {
    var favoriteCalls = 0;

    await tester.pumpWidget(
      _TestApp(
        child: TriageSwipeCard(
          enabled: true,
          onFavorite: () async {
            favoriteCalls++;
            return true;
          },
          onMarkForDeletion: () async => true,
          onDecisionCompleted: () async {},
          onDecisionAnimationFailed: () {},
          onOrganize: () async {},
          child: const ColoredBox(color: Colors.black),
        ),
      ),
    );

    await tester.drag(find.byType(TriageSwipeCard), const Offset(0, 160));
    await tester.pumpAndSettle();

    expect(favoriteCalls, 1);
  });

  testWidgets('horizontal swipe opens organize action', (tester) async {
    var organizeCalls = 0;

    await tester.pumpWidget(
      _TestApp(
        child: TriageSwipeCard(
          enabled: true,
          onFavorite: () async => true,
          onMarkForDeletion: () async => true,
          onDecisionCompleted: () async {},
          onDecisionAnimationFailed: () {},
          onOrganize: () async {
            organizeCalls++;
          },
          child: const ColoredBox(color: Colors.black),
        ),
      ),
    );

    await tester.drag(find.byType(TriageSwipeCard), const Offset(160, 0));
    await tester.pumpAndSettle();

    expect(organizeCalls, 1);
  });

  testWidgets('small drag cancels decision', (tester) async {
    var decisions = 0;

    await tester.pumpWidget(
      _TestApp(
        child: TriageSwipeCard(
          enabled: true,
          onFavorite: () async {
            decisions++;
            return true;
          },
          onMarkForDeletion: () async {
            decisions++;
            return true;
          },
          onDecisionCompleted: () async {},
          onDecisionAnimationFailed: () {},
          onOrganize: () async {
            decisions++;
          },
          child: const ColoredBox(color: Colors.black),
        ),
      ),
    );

    await tester.drag(find.byType(TriageSwipeCard), const Offset(0, -30));
    await tester.pumpAndSettle();

    expect(decisions, 0);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: SizedBox.expand(child: child)),
    );
  }
}
