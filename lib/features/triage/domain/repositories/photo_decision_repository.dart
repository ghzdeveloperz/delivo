import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';

abstract interface class PhotoDecisionRepository {
  Stream<void> get changes;

  Future<Result<PhotoDecisionRecord?>> getDecision(String assetId);

  Future<Result<void>> saveDecision(PhotoDecisionRecord decision);

  Future<Result<void>> removeDecision(String assetId);

  Future<Result<Set<String>>> getReviewedAssetIds();

  Future<Result<List<PhotoDecisionRecord>>> getByDecision(
    PhotoDecision decision,
  );

  Future<Result<int>> countByDecision(PhotoDecision decision);
}
