import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/presentation/widgets/decision_collection_page.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecisionCollectionPage(
      title: 'Favoritas',
      emptyTitle: 'Nenhuma favorita ainda',
      emptyDescription:
          'As fotos favoritedas durante a triagem aparecerão aqui.',
      decision: PhotoDecision.favorite,
      actionLabel: 'Remover dos favoritos',
      actionIcon: Icons.undo_rounded,
    );
  }
}
