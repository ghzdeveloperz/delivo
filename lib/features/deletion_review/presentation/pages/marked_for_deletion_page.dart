import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/presentation/widgets/decision_collection_page.dart';
import 'package:flutter/material.dart';

class MarkedForDeletionPage extends StatelessWidget {
  const MarkedForDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecisionCollectionPage(
      title: 'Para revisar',
      emptyTitle: 'Nenhuma foto marcada',
      emptyDescription:
          'Fotos marcadas durante a triagem aparecerão aqui antes de qualquer exclusão.',
      decision: PhotoDecision.markedForDeletion,
      actionLabel: 'Retirar da revisão de exclusão',
      actionIcon: Icons.undo_rounded,
    );
  }
}
