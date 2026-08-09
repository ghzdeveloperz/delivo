
import 'package:delivo/features/gallery_access/data/services/gallery_asset_metrics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final galleryAssetMetricsServiceProvider =
    Provider<GalleryAssetMetricsService>((ref) {
  return GalleryAssetMetricsService();
});
