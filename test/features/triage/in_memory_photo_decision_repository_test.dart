import 'package:delivo/features/triage/data/repositories/in_memory_photo_decision_repository.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saving a decision makes asset reviewed', () async {
    final repository = InMemoryPhotoDecisionRepository();

    await repository.saveDecision(
      PhotoDecisionRecord(
        assetId: 'asset-1',
        assetCreatedAt: DateTime(2026, 8, 8),
        previousDecision: PhotoDecision.unreviewed,
        newDecision: PhotoDecision.favorite,
        decidedAt: DateTime(2026, 8, 8),
      ),
    );

    final reviewed = await repository.getReviewedAssetIds();

    expect(
      reviewed.fold(
        onSuccess: (value) => value.contains('asset-1'),
        onFailure: (_) => false,
      ),
      isTrue,
    );

    await repository.close();
  });

  test('removing a decision makes asset unreviewed again', () async {
    final repository = InMemoryPhotoDecisionRepository();

    await repository.saveDecision(
      PhotoDecisionRecord(
        assetId: 'asset-1',
        assetCreatedAt: DateTime(2026, 8, 8),
        previousDecision: PhotoDecision.unreviewed,
        newDecision: PhotoDecision.markedForDeletion,
        decidedAt: DateTime(2026, 8, 8),
      ),
    );

    await repository.removeDecision('asset-1');

    final reviewed = await repository.getReviewedAssetIds();

    expect(
      reviewed.fold(
        onSuccess: (value) => value.contains('asset-1'),
        onFailure: (_) => true,
      ),
      isFalse,
    );

    await repository.close();
  });

  test('filters records by decision', () async {
    final repository = InMemoryPhotoDecisionRepository();

    await repository.saveDecision(
      PhotoDecisionRecord(
        assetId: 'favorite',
        previousDecision: PhotoDecision.unreviewed,
        newDecision: PhotoDecision.favorite,
        decidedAt: DateTime(2026),
      ),
    );

    await repository.saveDecision(
      PhotoDecisionRecord(
        assetId: 'deletion',
        previousDecision: PhotoDecision.unreviewed,
        newDecision: PhotoDecision.markedForDeletion,
        decidedAt: DateTime(2026),
      ),
    );

    final favorites = await repository.getByDecision(PhotoDecision.favorite);

    expect(
      favorites.fold(
        onSuccess: (value) => value.map((e) => e.assetId).toList(),
        onFailure: (_) => <String>[],
      ),
      <String>['favorite'],
    );

    await repository.close();
  });
}
