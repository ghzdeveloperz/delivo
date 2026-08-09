
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';

enum PhotoFolderItemSort {
  photoNewest,
  photoOldest,
  addedNewest,
  addedOldest,
}

List<PhotoFolderItem> filterAndSortPhotoFolderItems({
  required Iterable<PhotoFolderItem> items,
  required String query,
  required PhotoFolderItemSort sort,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = items.where((item) {
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final date = item.assetCreatedAt ?? item.assignedAt;
    return _searchableDate(date).contains(normalizedQuery);
  }).toList(growable: true);

  filtered.sort((a, b) {
    final photoA = a.assetCreatedAt ?? a.assignedAt;
    final photoB = b.assetCreatedAt ?? b.assignedAt;

    return switch (sort) {
      PhotoFolderItemSort.photoNewest =>
        photoB.compareTo(photoA),
      PhotoFolderItemSort.photoOldest =>
        photoA.compareTo(photoB),
      PhotoFolderItemSort.addedNewest =>
        b.assignedAt.compareTo(a.assignedAt),
      PhotoFolderItemSort.addedOldest =>
        a.assignedAt.compareTo(b.assignedAt),
    };
  });

  return filtered;
}

String photoFolderDateLabel(DateTime date) {
  const months = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  return '${date.day} de ${months[date.month - 1]} de ${date.year}';
}

String _searchableDate(DateTime date) {
  const months = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  final month = months[date.month - 1];

  return '${date.day} $month ${date.year} '
      '${date.day}/${date.month}/${date.year} '
      '${date.month}/${date.year}';
}
