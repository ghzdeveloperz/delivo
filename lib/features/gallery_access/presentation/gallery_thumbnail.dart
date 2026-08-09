import 'dart:typed_data';

import 'package:delivo/core/result/result.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryThumbnail extends ConsumerStatefulWidget {
  const GalleryThumbnail({required this.assetId, super.key});

  final String assetId;

  @override
  ConsumerState<GalleryThumbnail> createState() => _GalleryThumbnailState();
}

class _GalleryThumbnailState extends ConsumerState<GalleryThumbnail> {
  late Future<Result<Uint8List?>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant GalleryThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetId != widget.assetId) {
      _future = _load();
    }
  }

  Future<Result<Uint8List?>> _load() {
    return ref
        .read(galleryRepositoryProvider)
        .getThumbnail(
          assetId: widget.assetId,
          width: 360,
          height: 360,
          quality: 78,
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Uint8List?>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(
            color: Color(0xFFE5E7F0),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final bytes = snapshot.data!.fold<Uint8List?>(
          onSuccess: (value) => value,
          onFailure: (_) => null,
        );

        if (bytes == null) {
          return const ColoredBox(
            color: Color(0xFFE5E7F0),
            child: Center(child: Icon(Icons.broken_image_outlined)),
          );
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.low,
        );
      },
    );
  }
}
