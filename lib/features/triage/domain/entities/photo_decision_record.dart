import 'package:delivo/features/triage/domain/entities/photo_decision.dart';

final class PhotoDecisionRecord {
  const PhotoDecisionRecord({
    required this.assetId,
    required this.previousDecision,
    required this.newDecision,
    required this.decidedAt,
    this.assetCreatedAt,
    this.previousFolderId,
    this.newFolderId,
  });

  final String assetId;
  final DateTime? assetCreatedAt;
  final PhotoDecision previousDecision;
  final String? previousFolderId;
  final PhotoDecision newDecision;
  final String? newFolderId;
  final DateTime decidedAt;
}
