
import 'package:delivo/features/deletion_review/domain/repositories/gallery_deletion_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeDeletionGateway
    implements GalleryDeletionGateway {
  _FakeDeletionGateway({
    required this.deletedIds,
    this.failedByException = false,
  });

  final Set<String> deletedIds;
  final bool failedByException;

  @override
  Future<GalleryDeletionAttempt> deleteAssets(
    Set<String> assetIds,
  ) async {
    return GalleryDeletionAttempt(
      deletedIds: deletedIds,
      failedByException: failedByException,
    );
  }
}

void main() {
  test(
    'classifies partial native deletion from returned ids',
    () async {
      final requested = <String>{'a', 'b', 'c'};

      final attempt = await _FakeDeletionGateway(
        deletedIds: <String>{'a', 'c'},
      ).deleteAssets(requested);

      final deleted =
          attempt.deletedIds.intersection(requested);
      final failed = requested.difference(deleted);

      expect(deleted, <String>{'a', 'c'});
      expect(failed, <String>{'b'});
      expect(attempt.failedByException, isFalse);
    },
  );

  test(
    'represents native failure without confirmed deletion',
    () async {
      final attempt = await _FakeDeletionGateway(
        deletedIds: const <String>{},
        failedByException: true,
      ).deleteAssets(<String>{'a'});

      expect(attempt.deletedIds, isEmpty);
      expect(attempt.failedByException, isTrue);
    },
  );
}
