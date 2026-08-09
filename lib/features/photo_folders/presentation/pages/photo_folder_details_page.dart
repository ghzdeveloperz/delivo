import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:delivo/features/photo_folders/presentation/widgets/photo_folder_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoFolderDetailsPage extends ConsumerWidget {
  const PhotoFolderDetailsPage({
    required this.folderId,
    super.key,
  });

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderAsync = ref.watch(photoFolderProvider(folderId));
    final itemsAsync =
        ref.watch(photoFolderItemsProvider(folderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          folderAsync.value?.name ?? 'Pasta',
        ),
      ),
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Não foi possível carregar esta pasta.',
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyFolderView();
          }

          return _GroupedFolderGrid(
            folderId: folderId,
            folder: folderAsync.value,
            items: items,
          );
        },
      ),
    );
  }
}

class _GroupedFolderGrid extends ConsumerWidget {
  const _GroupedFolderGrid({
    required this.folderId,
    required this.folder,
    required this.items,
  });

  final String folderId;
  final PhotoFolder? folder;
  final List<PhotoFolderItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groupByDate(items);
    final slivers = <Widget>[];

    for (final entry in groups.entries) {
      slivers
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                _formatDate(entry.key),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = entry.value[index];

                  return _FolderPhotoTile(
                    item: item,
                    isCover:
                        folder?.coverAssetId == item.assetId,
                    onMenu: (action) => _handleAction(
                      context,
                      ref,
                      item,
                      action,
                    ),
                  );
                },
                childCount: entry.value.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
            ),
          ),
        );
    }

    return CustomScrollView(
      slivers: slivers,
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    PhotoFolderItem item,
    _PhotoMenuAction action,
  ) async {
    final repository =
        ref.read(photoFolderRepositoryProvider);

    switch (action) {
      case _PhotoMenuAction.restore:
        await repository.removePhoto(item.assetId);

      case _PhotoMenuAction.move:
        final target = await PhotoFolderPickerSheet.show(context);

        if (target == null || target.id == folderId) {
          return;
        }

        await repository.movePhoto(
          assetId: item.assetId,
          folderId: target.id,
          assetCreatedAt: item.assetCreatedAt,
        );

      case _PhotoMenuAction.cover:
        await repository.setCover(
          folderId: folderId,
          assetId: item.assetId,
        );
    }
  }

  static Map<DateTime, List<PhotoFolderItem>> _groupByDate(
    List<PhotoFolderItem> items,
  ) {
    final groups = <DateTime, List<PhotoFolderItem>>{};

    for (final item in items) {
      final date = item.assetCreatedAt ?? item.assignedAt;
      final key = DateTime(date.year, date.month, date.day);

      groups.putIfAbsent(
        key,
        () => <PhotoFolderItem>[],
      ).add(item);
    }

    final keys = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return <DateTime, List<PhotoFolderItem>>{
      for (final key in keys) key: groups[key]!,
    };
  }

  static String _formatDate(DateTime date) {
    const months = <String>[
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _FolderPhotoTile extends StatelessWidget {
  const _FolderPhotoTile({
    required this.item,
    required this.isCover,
    required this.onMenu,
  });

  final PhotoFolderItem item;
  final bool isCover;
  final ValueChanged<_PhotoMenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GalleryThumbnail(
          key: ValueKey(item.assetId),
          assetId: item.assetId,
        ),
        if (isCover)
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: _CoverBadge(),
            ),
          ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<_PhotoMenuAction>(
            color: Theme.of(context).colorScheme.surface,
            onSelected: onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _PhotoMenuAction.move,
                child: Text('Mover para outra pasta'),
              ),
              PopupMenuItem(
                value: _PhotoMenuAction.cover,
                child: Text('Usar como capa'),
              ),
              PopupMenuItem(
                value: _PhotoMenuAction.restore,
                child: Text('Voltar para não revisadas'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Text(
          'Capa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyFolderView extends StatelessWidget {
  const _EmptyFolderView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Esta pasta está vazia.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

enum _PhotoMenuAction {
  move,
  cover,
  restore,
}
