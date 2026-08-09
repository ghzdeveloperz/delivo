import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';

sealed class GalleryAccessState {
  const GalleryAccessState();
}

final class GalleryAccessInitial extends GalleryAccessState {
  const GalleryAccessInitial();
}

final class GalleryAccessRequestingPermission extends GalleryAccessState {
  const GalleryAccessRequestingPermission();
}

final class GalleryAccessPermissionDenied extends GalleryAccessState {
  const GalleryAccessPermissionDenied();
}

final class GalleryAccessLoading extends GalleryAccessState {
  const GalleryAccessLoading();
}

final class GalleryAccessReady extends GalleryAccessState {
  const GalleryAccessReady({
    required this.photos,
    required this.permission,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<PhotoAsset> photos;
  final GalleryPermission permission;
  final bool hasMore;
  final bool isLoadingMore;

  GalleryAccessReady copyWith({
    List<PhotoAsset>? photos,
    GalleryPermission? permission,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return GalleryAccessReady(
      photos: photos ?? this.photos,
      permission: permission ?? this.permission,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class GalleryAccessEmpty extends GalleryAccessState {
  const GalleryAccessEmpty({
    required this.permission,
  });

  final GalleryPermission permission;
}

final class GalleryAccessFailure extends GalleryAccessState {
  const GalleryAccessFailure(this.message);

  final String message;
}
