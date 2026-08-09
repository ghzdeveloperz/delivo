
final class DeletionBatchResult {
  const DeletionBatchResult({
    required this.requestedIds,
    required this.deletedIds,
    required this.failedIds,
    required this.localCleanupSucceeded,
    required this.systemCallFailed,
  });

  final Set<String> requestedIds;
  final Set<String> deletedIds;
  final Set<String> failedIds;
  final bool localCleanupSucceeded;
  final bool systemCallFailed;

  bool get isCompleteSuccess =>
      deletedIds.length == requestedIds.length &&
      failedIds.isEmpty &&
      localCleanupSucceeded &&
      !systemCallFailed;

  bool get isPartial =>
      deletedIds.isNotEmpty &&
      failedIds.isNotEmpty;
}
