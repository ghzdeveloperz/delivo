import 'package:delivo/features/gallery_access/domain/entities/photo_asset.dart';

sealed class TriageState {
  const TriageState();
}

final class TriageInitial extends TriageState {
  const TriageInitial();
}

final class TriageLoading extends TriageState {
  const TriageLoading();
}

final class TriageReady extends TriageState {
  const TriageReady({
    required this.photos,
    required this.currentIndex,
    required this.canUndo,
    required this.isPersisting,
    required this.hasMore,
  });

  final List<PhotoAsset> photos;
  final int currentIndex;
  final bool canUndo;
  final bool isPersisting;
  final bool hasMore;

  PhotoAsset get currentPhoto => photos[currentIndex];

  int get currentPosition => currentIndex + 1;

  int get loadedTotal => photos.length;

  TriageReady copyWith({
    List<PhotoAsset>? photos,
    int? currentIndex,
    bool? canUndo,
    bool? isPersisting,
    bool? hasMore,
  }) {
    return TriageReady(
      photos: photos ?? this.photos,
      currentIndex: currentIndex ?? this.currentIndex,
      canUndo: canUndo ?? this.canUndo,
      isPersisting: isPersisting ?? this.isPersisting,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final class TriageEmpty extends TriageState {
  const TriageEmpty();
}

final class TriageFailure extends TriageState {
  const TriageFailure(this.message);

  final String message;
}
