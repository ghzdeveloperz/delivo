import 'package:delivo/core/database/app_database_provider.dart';
import 'package:delivo/core/logging/app_logger_provider.dart';
import 'package:delivo/features/photo_folders/data/repositories/sqflite_photo_folder_repository.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/domain/repositories/photo_folder_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoFolderRepositoryProvider =
    Provider<PhotoFolderRepository>((ref) {
  final repository = SqflitePhotoFolderRepository(
    database: ref.watch(appDatabaseProvider),
    logger: ref.watch(appLoggerProvider),
  );

  ref.onDispose(repository.close);

  return repository;
});

final photoFolderRevisionProvider = StreamProvider<int>((ref) async* {
  final repository = ref.watch(photoFolderRepositoryProvider);

  var revision = 0;
  yield revision;

  await for (final _ in repository.changes) {
    revision++;
    yield revision;
  }
});

final photoFoldersProvider =
    FutureProvider<List<PhotoFolder>>((ref) async {
  ref.watch(photoFolderRevisionProvider);

  final result =
      await ref.watch(photoFolderRepositoryProvider).getFolders();

  return result.fold(
    onSuccess: (folders) => folders,
    onFailure: (error) => throw error,
  );
});

final photoFolderProvider =
    FutureProvider.family<PhotoFolder?, String>((ref, folderId) async {
  ref.watch(photoFolderRevisionProvider);

  final result =
      await ref.watch(photoFolderRepositoryProvider).getFolder(folderId);

  return result.fold(
    onSuccess: (folder) => folder,
    onFailure: (error) => throw error,
  );
});

final photoFolderItemsProvider =
    FutureProvider.family<List<PhotoFolderItem>, String>(
  (ref, folderId) async {
    ref.watch(photoFolderRevisionProvider);

    final result =
        await ref.watch(photoFolderRepositoryProvider).getItems(folderId);

    return result.fold(
      onSuccess: (items) => items,
      onFailure: (error) => throw error,
    );
  },
);
