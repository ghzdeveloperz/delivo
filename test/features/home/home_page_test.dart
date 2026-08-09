import 'package:delivo/app/app.dart';
import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:delivo/features/home/presentation/providers/home_summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home renders summary from provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeSummaryProvider.overrideWithValue(
            const HomeSummary(
              unreviewedCount: 120,
              favoriteCount: 18,
              markedForDeletionCount: 7,
              estimatedBytesToFree: 25 * 1024 * 1024,
            ),
          ),
        ],
        child: const DelivoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Delivo'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('25 MB'), findsOneWidget);
    expect(find.text('Iniciar triagem'), findsOneWidget);
  });
}
