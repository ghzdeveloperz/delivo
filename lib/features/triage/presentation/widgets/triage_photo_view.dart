import 'dart:typed_data';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TriagePhotoView extends ConsumerStatefulWidget {
  const TriagePhotoView({required this.assetId, super.key});

  final String assetId;

  @override
  ConsumerState<TriagePhotoView> createState() => _TriagePhotoViewState();
}

class _TriagePhotoViewState extends ConsumerState<TriagePhotoView> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant TriagePhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetId != widget.assetId) {
      _future = _load();
    }
  }

  Future<Uint8List?> _load() {
    final cache = ref.read(triageThumbnailCacheProvider);

    return cache.get(
      assetId: widget.assetId,
      loader: () async {
        final result = await ref
            .read(galleryRepositoryProvider)
            .getThumbnail(
              assetId: widget.assetId,
              width: 1200,
              height: 1600,
              quality: 88,
            );

        return result.fold<Uint8List?>(
          onSuccess: (value) => value,
          onFailure: (_) => null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final bytes = snapshot.data;

        if (bytes == null) {
          return const Center(
            child: Icon(Icons.broken_image_outlined, size: 44),
          );
        }

        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        );
      },
    );
  }
}
