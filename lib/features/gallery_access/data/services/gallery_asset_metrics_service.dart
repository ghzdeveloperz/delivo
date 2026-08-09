
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

final class GalleryAssetMetricsService {
  final Map<String, int> _sizeCache = <String, int>{};

  Future<int> totalBytes(
    Iterable<String> assetIds,
  ) async {
    final ids = assetIds.toSet().toList(growable: false);

    if (ids.isEmpty) {
      return 0;
    }

    var total = 0;
    const batchSize = 4;

    for (var start = 0;
        start < ids.length;
        start += batchSize) {
      final end =
          (start + batchSize).clamp(0, ids.length);

      final sizes = await Future.wait<int>(
        ids.sublist(start, end).map(_assetSize),
      );

      for (final size in sizes) {
        total += size;
      }
    }

    return total;
  }

  Future<int> _assetSize(String assetId) async {
    final cached = _sizeCache[assetId];

    if (cached != null) {
      return cached;
    }

    File? file;

    try {
      final entity = await AssetEntity.fromId(assetId);

      if (entity == null) {
        _sizeCache[assetId] = 0;
        return 0;
      }

      file = await entity.originFile;

      if (file == null) {
        _sizeCache[assetId] = 0;
        return 0;
      }

      final length = await file.length();
      _sizeCache[assetId] = length;
      return length;
    } catch (_) {
      _sizeCache[assetId] = 0;
      return 0;
    } finally {
      if (Platform.isIOS && file != null) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }
  }

  void removeFromCache(Iterable<String> assetIds) {
    for (final id in assetIds) {
      _sizeCache.remove(id);
    }
  }
}
