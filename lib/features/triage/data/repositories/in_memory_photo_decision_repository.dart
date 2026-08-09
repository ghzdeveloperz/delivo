import 'dart:async';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/domain/repositories/photo_decision_repository.dart';

final class InMemoryPhotoDecisionRepository implements PhotoDecisionRepository {
  final Map<String, PhotoDecisionRecord> _records =
      <String, PhotoDecisionRecord>{};

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changesController.stream;

  @override
  Future<Result<PhotoDecisionRecord?>> getDecision(String assetId) async {
    return Success(_records[assetId]);
  }

  @override
  Future<Result<void>> saveDecision(PhotoDecisionRecord decision) async {
    _records[decision.assetId] = decision;
    _changesController.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> removeDecision(String assetId) async {
    _records.remove(assetId);
    _changesController.add(null);
    return const Success(null);
  }

  @override
  Future<Result<Set<String>>> getReviewedAssetIds() async {
    return Success(_records.keys.toSet());
  }

  @override
  Future<Result<List<PhotoDecisionRecord>>> getByDecision(
    PhotoDecision decision,
  ) async {
    final records =
        _records.values
            .where((record) => record.newDecision == decision)
            .toList()
          ..sort((a, b) {
            final aDate = a.assetCreatedAt ?? a.decidedAt;
            final bDate = b.assetCreatedAt ?? b.decidedAt;
            return bDate.compareTo(aDate);
          });

    return Success(records);
  }

  @override
  Future<Result<int>> countByDecision(PhotoDecision decision) async {
    final count = _records.values
        .where((record) => record.newDecision == decision)
        .length;

    return Success(count);
  }

  Future<void> close() async {
    await _changesController.close();
  }
}
