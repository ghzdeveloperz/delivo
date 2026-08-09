
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/domain/services/decision_collection_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PhotoDecisionRecord makeRecord({
    required String id,
    required DateTime photoDate,
    required DateTime decisionDate,
  }) {
    return PhotoDecisionRecord(
      assetId: id,
      assetCreatedAt: photoDate,
      previousDecision: PhotoDecision.unreviewed,
      newDecision: PhotoDecision.favorite,
      decidedAt: decisionDate,
    );
  }

  test('filters records by month and year', () {
    final records = <PhotoDecisionRecord>[
      makeRecord(
        id: '1',
        photoDate: DateTime(2026, 8, 8),
        decisionDate: DateTime(2026, 8, 9),
      ),
      makeRecord(
        id: '2',
        photoDate: DateTime(2024, 12, 6),
        decisionDate: DateTime(2026, 8, 9),
      ),
    ];

    final result = filterAndSortDecisionRecords(
      records: records,
      query: 'dezembro 2024',
      sort: DecisionCollectionSort.photoNewest,
    );

    expect(result.single.assetId, '2');
  });

  test('sorts by original photo date', () {
    final records = <PhotoDecisionRecord>[
      makeRecord(
        id: 'old',
        photoDate: DateTime(2024, 1, 1),
        decisionDate: DateTime(2026, 8, 9),
      ),
      makeRecord(
        id: 'new',
        photoDate: DateTime(2026, 8, 8),
        decisionDate: DateTime(2026, 8, 8),
      ),
    ];

    final result = filterAndSortDecisionRecords(
      records: records,
      query: '',
      sort: DecisionCollectionSort.photoNewest,
    );

    expect(result.first.assetId, 'new');
  });
}
