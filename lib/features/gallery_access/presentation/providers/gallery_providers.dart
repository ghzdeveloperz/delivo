import 'package:delivo/core/logging/app_logger_provider.dart';
import 'package:delivo/features/gallery_access/data/datasources/gallery_change_observer.dart';
import 'package:delivo/features/gallery_access/data/datasources/gallery_data_source.dart';
import 'package:delivo/features/gallery_access/data/datasources/photo_manager_gallery_data_source.dart';
import 'package:delivo/features/gallery_access/data/repositories/photo_manager_gallery_repository.dart';
import 'package:delivo/features/gallery_access/domain/repositories/gallery_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final galleryDataSourceProvider = Provider<GalleryDataSource>(
  (ref) => const PhotoManagerGalleryDataSource(),
);

final galleryRepositoryProvider = Provider<GalleryRepository>(
  (ref) {
    return PhotoManagerGalleryRepository(
      dataSource: ref.watch(galleryDataSourceProvider),
      logger: ref.watch(appLoggerProvider),
    );
  },
);

final galleryChangeObserverProvider = Provider<GalleryChangeObserver>(
  (ref) {
    final observer = PhotoManagerGalleryChangeObserver();

    ref.onDispose(() {
      observer.dispose();
    });

    return observer;
  },
);

final galleryChangesProvider = StreamProvider<void>(
  (ref) async* {
    final observer = ref.watch(galleryChangeObserverProvider);

    await observer.start();

    yield* observer.changes;
  },
);
