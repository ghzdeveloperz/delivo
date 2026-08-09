
import 'package:delivo/features/deletion_review/domain/entities/deletion_batch_result.dart';
import 'package:delivo/features/deletion_review/domain/repositories/gallery_deletion_gateway.dart';
import 'package:delivo/features/triage/data/services/photo_decision_batch_service.dart';

final class DeletionReviewService {
  DeletionReviewService({
    required GalleryDeletionGateway gateway,
    required PhotoDecisionBatchService batchService,
  })  : _gateway = gateway,
        _batchService = batchService;

  final GalleryDeletionGateway _gateway;
  final PhotoDecisionBatchService _batchService;

  Future<DeletionBatchResult> delete(
    Set<String> requestedIds,
  ) async {
    final attempt =
        await _gateway.deleteAssets(requestedIds);

    final deletedIds =
        attempt.deletedIds.intersection(requestedIds);
    final failedIds =
        requestedIds.difference(deletedIds);

    var localCleanupSucceeded = true;

    if (deletedIds.isNotEmpty) {
      final cleanup =
          await _batchService.clearDecisions(deletedIds);

      localCleanupSucceeded = cleanup.fold<bool>(
        onSuccess: (_) => true,
        onFailure: (_) => false,
      );
    }

    return DeletionBatchResult(
      requestedIds: requestedIds,
      deletedIds: deletedIds,
      failedIds: failedIds,
      localCleanupSucceeded: localCleanupSucceeded,
      systemCallFailed: attempt.failedByException,
    );
  }
}
