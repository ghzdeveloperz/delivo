import 'dart:collection';
import 'dart:typed_data';

final class TriageThumbnailCache {
  TriageThumbnailCache({required this.maxEntries}) : assert(maxEntries > 0);

  final int maxEntries;

  final LinkedHashMap<String, Future<Uint8List?>> _entries =
      LinkedHashMap<String, Future<Uint8List?>>();

  Future<Uint8List?> get({
    required String assetId,
    required Future<Uint8List?> Function() loader,
  }) {
    final cached = _entries.remove(assetId);

    if (cached != null) {
      _entries[assetId] = cached;
      return cached;
    }

    final future = loader();
    _entries[assetId] = future;

    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }

    return future;
  }

  void clear() {
    _entries.clear();
  }
}
