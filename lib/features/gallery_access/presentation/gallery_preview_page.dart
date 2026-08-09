import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/gallery_access/domain/entities/gallery_permission.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_access_state.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_access_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryPreviewPage extends ConsumerStatefulWidget {
  const GalleryPreviewPage({super.key});

  @override
  ConsumerState<GalleryPreviewPage> createState() => _GalleryPreviewPageState();
}

class _GalleryPreviewPageState extends ConsumerState<GalleryPreviewPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(_handleScroll);

    Future<void>.microtask(
      () => ref.read(galleryAccessControllerProvider.notifier).loadFirstPage(),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    const preloadDistance = 800.0;

    final position = _scrollController.position;

    if (position.extentAfter <= preloadDistance) {
      ref.read(galleryAccessControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryAccessControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua galeria'),
      ),
      body: switch (state) {
        GalleryAccessLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        GalleryAccessReady(
          :final photos,
          :final permission,
          :final isLoadingMore,
        ) =>
          Column(
            children: [
              if (permission == GalleryPermission.limited)
                const _LimitedAccessBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(galleryAccessControllerProvider.notifier)
                      .refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: photos.length + (isLoadingMore ? 3 : 0),
                    itemBuilder: (context, index) {
                      if (index >= photos.length) {
                        return const _LoadingTile();
                      }

                      final photo = photos[index];

                      return GalleryThumbnail(
                        key: ValueKey(photo.id),
                        assetId: photo.id,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        GalleryAccessEmpty(:final permission) => RefreshIndicator(
            onRefresh: () => ref
                .read(galleryAccessControllerProvider.notifier)
                .refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: _EmptyGallery(
                    isLimited: permission == GalleryPermission.limited,
                  ),
                ),
              ],
            ),
          ),
        GalleryAccessPermissionDenied() => const _PermissionLost(),
        GalleryAccessFailure(:final message) => _FailureView(message: message),
        _ => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE5E7F0),
      child: Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _LimitedAccessBanner extends StatelessWidget {
  const _LimitedAccessBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      color: theme.colorScheme.secondaryContainer,
      child: Text(
        'Acesso limitado: o Delivo está exibindo somente as fotos autorizadas pelo sistema.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({
    required this.isLimited,
  });

  final bool isLimited;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          isLimited
              ? 'Nenhuma foto autorizada foi encontrada.'
              : 'Nenhuma foto foi encontrada na galeria.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PermissionLost extends StatelessWidget {
  const _PermissionLost();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'O acesso à galeria não está mais disponível.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _FailureView extends ConsumerWidget {
  const _FailureView({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => ref
                  .read(galleryAccessControllerProvider.notifier)
                  .loadFirstPage(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
