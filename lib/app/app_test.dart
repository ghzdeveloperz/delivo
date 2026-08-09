import 'package:delivo/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Delivo initializes successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DelivoApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Delivo'), findsOneWidget);
  });
}
