import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';

final class GalleryPage {
  const GalleryPage({
    required this.photos,
    required this.page,
    required this.hasMore,
  });

  final List<PhotoAsset> photos;
  final int page;
  final bool hasMore;
}
