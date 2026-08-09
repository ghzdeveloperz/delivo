import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final decisionCollectionProvider = FutureProvider.family<
    List<PhotoDecisionRecord>,
    PhotoDecision>((ref, decision) async {
  ref.watch(photoDecisionRevisionProvider);

  final result = await ref
      .watch(photoDecisionRepositoryProvider)
      .getByDecision(decision);

  return result.fold(
    onSuccess: (records) => records,
    onFailure: (error) => throw error,
  );
});
