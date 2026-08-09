
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';

enum DecisionCollectionSort {
  photoNewest,
  photoOldest,
  decisionNewest,
  decisionOldest,
}

List<PhotoDecisionRecord> filterAndSortDecisionRecords({
  required Iterable<PhotoDecisionRecord> records,
  required String query,
  required DecisionCollectionSort sort,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = records.where((record) {
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final date = record.assetCreatedAt ?? record.decidedAt;
    return _searchableDate(date).contains(normalizedQuery);
  }).toList(growable: true);

  filtered.sort((a, b) {
    final photoA = a.assetCreatedAt ?? a.decidedAt;
    final photoB = b.assetCreatedAt ?? b.decidedAt;

    return switch (sort) {
      DecisionCollectionSort.photoNewest =>
        photoB.compareTo(photoA),
      DecisionCollectionSort.photoOldest =>
        photoA.compareTo(photoB),
      DecisionCollectionSort.decisionNewest =>
        b.decidedAt.compareTo(a.decidedAt),
      DecisionCollectionSort.decisionOldest =>
        a.decidedAt.compareTo(b.decidedAt),
    };
  });

  return filtered;
}

String decisionCollectionDateLabel(DateTime date) {
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
