
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/domain/services/photo_folder_item_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PhotoFolderItem makeItem({
    required String id,
    required DateTime photoDate,
    required DateTime assignedAt,
  }) {
    return PhotoFolderItem(
      assetId: id,
      folderId: 'folder-a',
      assignedAt: assignedAt,
      assetCreatedAt: photoDate,
    );
  }

  test('filters folder items by month and year', () {
    final items = <PhotoFolderItem>[
      makeItem(
        id: 'august',
        photoDate: DateTime(2026, 8, 8),
        assignedAt: DateTime(2026, 8, 9),
      ),
      makeItem(
        id: 'december',
        photoDate: DateTime(2024, 12, 6),
        assignedAt: DateTime(2026, 8, 9),
      ),
    ];

    final result = filterAndSortPhotoFolderItems(
      items: items,
      query: 'dezembro 2024',
      sort: PhotoFolderItemSort.photoNewest,
    );

    expect(result.single.assetId, 'december');
  });

  test('sorts folder items by original photo date', () {
    final items = <PhotoFolderItem>[
      makeItem(
        id: 'old',
        photoDate: DateTime(2024, 1, 1),
        assignedAt: DateTime(2026, 8, 9),
      ),
      makeItem(
        id: 'new',
        photoDate: DateTime(2026, 8, 8),
        assignedAt: DateTime(2026, 8, 8),
      ),
    ];

    final result = filterAndSortPhotoFolderItems(
      items: items,
      query: '',
      sort: PhotoFolderItemSort.photoNewest,
    );

    expect(result.first.assetId, 'new');
  });

  test('sorts by date added to the folder', () {
    final items = <PhotoFolderItem>[
      makeItem(
        id: 'first',
        photoDate: DateTime(2026, 8, 8),
        assignedAt: DateTime(2026, 8, 8, 10),
      ),
      makeItem(
        id: 'last',
        photoDate: DateTime(2024, 1, 1),
        assignedAt: DateTime(2026, 8, 9, 10),
      ),
    ];

    final result = filterAndSortPhotoFolderItems(
      items: items,
      query: '',
      sort: PhotoFolderItemSort.addedNewest,
    );

    expect(result.first.assetId, 'last');
  });
}
