
import 'package:delivo/features/deletion_review/data/services/deletion_review_service.dart';
import 'package:delivo/features/deletion_review/data/services/photo_manager_gallery_deletion_gateway.dart';
import 'package:delivo/features/deletion_review/domain/repositories/gallery_deletion_gateway.dart';
import 'package:delivo/features/triage/presentation/providers/photo_decision_batch_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final galleryDeletionGatewayProvider =
    Provider<GalleryDeletionGateway>((ref) {
  return PhotoManagerGalleryDeletionGateway();
});

final deletionReviewServiceProvider =
    Provider<DeletionReviewService>((ref) {
  return DeletionReviewService(
    gateway: ref.watch(galleryDeletionGatewayProvider),
    batchService:
        ref.watch(photoDecisionBatchServiceProvider),
  );
});
