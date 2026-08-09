sealed class TriageSource {
  const TriageSource();
}

final class UnreviewedSource extends TriageSource {
  const UnreviewedSource();
}

final class FolderSource extends TriageSource {
  const FolderSource(this.folderId);

  final String folderId;
}
