
import 'dart:typed_data';

import 'package:delivo/features/gallery_access/presentation/providers/gallery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PhotoViewerAction {
  const PhotoViewerAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Future<bool> Function() onPressed;
}

class PhotoFullscreenViewer extends ConsumerWidget {
  const PhotoFullscreenViewer({
    required this.assetId,
    required this.actions,
    super.key,
  });

  final String assetId;
  final List<PhotoViewerAction> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FutureBuilder<Uint8List?>(
                future: _load(ref),
                builder: (context, snapshot) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }

                  final bytes = snapshot.data;

                  if (bytes == null) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar esta foto.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  );
                },
              ),
            ),
          ),
          if (actions.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  12,
                ),
                child: Row(
                  children: [
                    for (final action in actions)
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final shouldClose =
                                await action.onPressed();

                            if (shouldClose &&
                                context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(action.icon),
                              const SizedBox(height: 4),
                              Text(
                                action.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<Uint8List?> _load(WidgetRef ref) async {
    final result =
        await ref.read(galleryRepositoryProvider).getThumbnail(
              assetId: assetId,
              width: 1800,
              height: 2400,
              quality: 94,
            );

    return result.fold<Uint8List?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );
  }
}
