import 'package:delivo/core/errors/app_failure.dart';
import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/data/repositories/photo_manager_gallery_repository.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';

import 'fakes/fake_gallery_data_source.dart';
import 'fakes/test_app_logger.dart';

void main() {
  late FakeGalleryDataSource dataSource;
  late TestAppLogger logger;
  late PhotoManagerGalleryRepository repository;

  setUp(() {
    dataSource = FakeGalleryDataSource();
    logger = TestAppLogger();

    repository = PhotoManagerGalleryRepository(
      dataSource: dataSource,
      logger: logger,
    );
  });

  group('PhotoManagerGalleryRepository permissions', () {
    test('maps authorized permission', () async {
      dataSource.permissionState = PermissionState.authorized;

      final result = await repository.getPermissionStatus();

      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => null),
        GalleryPermission.authorized,
      );
    });

    test('maps limited permission', () async {
      dataSource.permissionState = PermissionState.limited;

      final result = await repository.getPermissionStatus();

      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => null),
        GalleryPermission.limited,
      );
    });

    test('maps denied permission', () async {
      dataSource.permissionState = PermissionState.denied;

      final result = await repository.getPermissionStatus();

      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => null),
        GalleryPermission.denied,
      );
    });

    test('returns typed failure when permission check throws', () async {
      dataSource.permissionError = StateError('native failure');

      final result = await repository.getPermissionStatus();

      expect(result, isA<Failure<GalleryPermission>>());

      final error = result.fold<Object?>(
        onSuccess: (_) => null,
        onFailure: (error) => error,
      );

      expect(error, isA<UnexpectedFailure>());
      expect(logger.messages, isNotEmpty);
    });
  });

  group('PhotoManagerGalleryRepository count', () {
    test('returns photo count', () async {
      dataSource.photoCount = 347;

      final result = await repository.getPhotoCount();

      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => -1),
        347,
      );
    });

    test('returns StorageFailure when native count fails', () async {
      dataSource.countError = StateError('storage failure');

      final result = await repository.getPhotoCount();

      final error = result.fold<Object?>(
        onSuccess: (_) => null,
        onFailure: (error) => error,
      );

      expect(error, isA<StorageFailure>());
    });
  });
}
