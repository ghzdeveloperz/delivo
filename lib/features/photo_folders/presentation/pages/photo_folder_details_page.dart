
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/core/widgets/photo_fullscreen_viewer.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder_item.dart';
import 'package:delivo/features/photo_folders/domain/services/photo_folder_item_filter.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:delivo/features/photo_folders/presentation/widgets/photo_folder_picker_sheet.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/presentation/providers/decision_collection_provider.dart';
import 'package:delivo/features/triage/presentation/providers/photo_decision_batch_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoFolderDetailsPage extends ConsumerStatefulWidget {
  const PhotoFolderDetailsPage({
    required this.folderId,
    super.key,
  });

  final String folderId;

  @override
  ConsumerState<PhotoFolderDetailsPage> createState() =>
      _PhotoFolderDetailsPageState();
}

class _PhotoFolderDetailsPageState
    extends ConsumerState<PhotoFolderDetailsPage> {
  static const Duration _exitDuration =
      Duration(milliseconds: 240);

  final TextEditingController _searchController =
      TextEditingController();
  final Set<String> _selected = <String>{};
  final Set<String> _exiting = <String>{};

  PhotoFolderItemSort _sort =
      PhotoFolderItemSort.photoNewest;

  String _query = '';
  bool _selectionMode = false;
  bool _busy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final folderAsync = ref.watch(
      photoFolderProvider(widget.folderId),
    );
    final itemsAsync = ref.watch(
      photoFolderItemsProvider(widget.folderId),
    );

    final folder = folderAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selected.length} selecionada${_selected.length == 1 ? '' : 's'}'
              : folder?.name ?? 'Pasta',
        ),
        leading: _selectionMode
            ? IconButton(
                tooltip: 'Cancelar seleção',
                onPressed: _leaveSelection,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        actions: [
          if (_selectionMode)
            TextButton(
              onPressed: itemsAsync.value?.isNotEmpty == true
                  ? () => _selectAll(
                        itemsAsync.value!,
                      )
                  : null,
              child: const Text('Todas'),
            )
          else
            TextButton(
              onPressed: itemsAsync.value?.isNotEmpty == true
                  ? () {
                      setState(() {
                        _selectionMode = true;
                      });
                    }
                  : null,
              child: const Text('Selecionar'),
            ),
        ],
      ),
      bottomNavigationBar:
          _selectionMode && _selected.isNotEmpty
              ? _FolderSelectionBar(
                  busy: _busy,
                  onFavorite: () => _applyBatchAction(
                    _selectedItems(),
                    _FolderBatchAction.favorite,
                  ),
                  onMove: () => _applyBatchAction(
                    _selectedItems(),
                    _FolderBatchAction.move,
                  ),
                  onReview: () => _applyBatchAction(
                    _selectedItems(),
                    _FolderBatchAction.review,
                  ),
                  onUnreviewed: () => _applyBatchAction(
                    _selectedItems(),
                    _FolderBatchAction.unreviewed,
                  ),
                )
              : null,
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => _ErrorView(
          onRetry: _invalidate,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyFolderView();
          }

          final visible = filterAndSortPhotoFolderItems(
            items: items,
            query: _query,
            sort: _sort,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _query = value;
                          });
                        },
                        textInputAction:
                            TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por data, mês ou ano',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    PopupMenuButton<PhotoFolderItemSort>(
                      tooltip: 'Ordenar',
                      icon: const Icon(
                        Icons.swap_vert_rounded,
                      ),
                      onSelected: (value) {
                        setState(() {
                          _sort = value;
                        });
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value:
                              PhotoFolderItemSort.photoNewest,
                          child:
                              Text('Fotos mais recentes'),
                        ),
                        PopupMenuItem(
                          value:
                              PhotoFolderItemSort.photoOldest,
                          child:
                              Text('Fotos mais antigas'),
                        ),
                        PopupMenuItem(
                          value:
                              PhotoFolderItemSort.addedNewest,
                          child: Text(
                            'Adicionadas recentemente',
                          ),
                        ),
                        PopupMenuItem(
                          value:
                              PhotoFolderItemSort.addedOldest,
                          child: Text(
                            'Adicionadas primeiro',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: visible.isEmpty
                      ? const _NoSearchResults(
                          key: ValueKey<String>(
                            'folder-no-results',
                          ),
                        )
                      : _FolderItemsGrid(
                          key: ValueKey<String>(
                            '${visible.length}-$_query-$_sort',
                          ),
                          items: visible,
                          selected: _selected,
                          exiting: _exiting,
                          coverAssetId:
                              folder?.coverAssetId,
                          selectionMode: _selectionMode,
                          onTap: _onItemTap,
                          onLongPress: (item) {
                            setState(() {
                              _selectionMode = true;
                              _toggle(item.assetId);
                            });
                          },
                          onMenuAction: _handleMenuAction,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggle(String assetId) {
    if (_selected.contains(assetId)) {
      _selected.remove(assetId);
    } else {
      _selected.add(assetId);
    }

    if (_selected.isEmpty) {
      _selectionMode = false;
    }
  }

  void _leaveSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _selectAll(List<PhotoFolderItem> items) {
    setState(() {
      _selected
        ..clear()
        ..addAll(
          items.map((item) => item.assetId),
        );
    });
  }

  List<PhotoFolderItem> _selectedItems() {
    final items = ref
            .read(
              photoFolderItemsProvider(
                widget.folderId,
              ),
            )
            .value ??
        const <PhotoFolderItem>[];

    return items
        .where(
          (item) => _selected.contains(item.assetId),
        )
        .toList(growable: false);
  }

  Future<void> _onItemTap(
    PhotoFolderItem item,
  ) async {
    if (_selectionMode) {
      setState(() {
        _toggle(item.assetId);
      });
      return;
    }

    final changed =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PhotoFullscreenViewer(
          assetId: item.assetId,
          actions: [
            PhotoViewerAction(
              label: 'Favoritar',
              icon: Icons.favorite_outline_rounded,
              onPressed: () => _applyBatchAction(
                <PhotoFolderItem>[item],
                _FolderBatchAction.favorite,
              ),
            ),
            PhotoViewerAction(
              label: 'Mover',
              icon: Icons.drive_file_move_outline,
              onPressed: () => _applyBatchAction(
                <PhotoFolderItem>[item],
                _FolderBatchAction.move,
              ),
            ),
            PhotoViewerAction(
              label: 'Capa',
              icon: Icons.photo_album_outlined,
              onPressed: () => _setAsCover(item),
            ),
            PhotoViewerAction(
              label: 'Revisar',
              icon: Icons.delete_outline_rounded,
              onPressed: () => _applyBatchAction(
                <PhotoFolderItem>[item],
                _FolderBatchAction.review,
              ),
            ),
            PhotoViewerAction(
              label: 'Não revisar',
              icon: Icons.undo_rounded,
              onPressed: () => _applyBatchAction(
                <PhotoFolderItem>[item],
                _FolderBatchAction.unreviewed,
              ),
            ),
          ],
        ),
      ),
    );

    if (changed == true) {
      _invalidate();
    }
  }

  Future<void> _handleMenuAction(
    PhotoFolderItem item,
    _FolderItemMenuAction action,
  ) async {
    switch (action) {
      case _FolderItemMenuAction.move:
        await _applyBatchAction(
          <PhotoFolderItem>[item],
          _FolderBatchAction.move,
        );
      case _FolderItemMenuAction.cover:
        await _setAsCover(item);
      case _FolderItemMenuAction.favorite:
        await _applyBatchAction(
          <PhotoFolderItem>[item],
          _FolderBatchAction.favorite,
        );
      case _FolderItemMenuAction.review:
        await _applyBatchAction(
          <PhotoFolderItem>[item],
          _FolderBatchAction.review,
        );
      case _FolderItemMenuAction.unreviewed:
        await _applyBatchAction(
          <PhotoFolderItem>[item],
          _FolderBatchAction.unreviewed,
        );
    }
  }

  Future<bool> _setAsCover(
    PhotoFolderItem item,
  ) async {
    if (_busy) {
      return false;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(photoFolderRepositoryProvider)
        .setCover(
          folderId: widget.folderId,
          assetId: item.assetId,
        );

    final success = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!mounted) {
      return success;
    }

    setState(() {
      _busy = false;
    });

    if (success) {
      _invalidate();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capa da pasta atualizada.'),
        ),
      );

      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Não foi possível atualizar a capa.'),
      ),
    );

    return false;
  }

  Future<bool> _applyBatchAction(
    List<PhotoFolderItem> items,
    _FolderBatchAction action,
  ) async {
    if (items.isEmpty || _busy) {
      return false;
    }

    String? targetFolderId;

    if (action == _FolderBatchAction.move) {
      final targetFolder =
          await PhotoFolderPickerSheet.show(context);

      if (targetFolder == null) {
        return false;
      }

      if (targetFolder.id == widget.folderId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Essas fotos já estão nesta pasta.',
            ),
          ),
        );
        return false;
      }

      targetFolderId = targetFolder.id;
    }

    if (action == _FolderBatchAction.review) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Enviar para revisão de exclusão?',
            ),
            content: Text(
              items.length == 1
                  ? 'Esta foto sairá da pasta e ficará marcada para revisão. Ela ainda não será excluída.'
                  : '${items.length} fotos sairão da pasta e ficarão marcadas para revisão. Nenhuma será excluída agora.',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(true),
                child: const Text('Marcar para revisar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return false;
      }
    }

    setState(() {
      _busy = true;
      _exiting.addAll(
        items.map((item) => item.assetId),
      );
    });

    await Future<void>.delayed(_exitDuration);

    final service =
        ref.read(photoDecisionBatchServiceProvider);

    final records = items
        .map(
          (item) => PhotoDecisionRecord(
            assetId: item.assetId,
            assetCreatedAt: item.assetCreatedAt,
            previousDecision:
                PhotoDecision.organized,
            previousFolderId: widget.folderId,
            newDecision:
                PhotoDecision.organized,
            newFolderId: widget.folderId,
            decidedAt: item.assignedAt,
          ),
        )
        .toList(growable: false);

    final result = switch (action) {
      _FolderBatchAction.favorite =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.favorite,
        ),
      _FolderBatchAction.move =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.organized,
          folderId: targetFolderId,
        ),
      _FolderBatchAction.review =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.markedForDeletion,
        ),
      _FolderBatchAction.unreviewed =>
        await service.clearDecisions(
          items.map((item) => item.assetId),
        ),
    };

    final success = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!mounted) {
      return success;
    }

    if (success) {
      await _clearCoverIfNeeded(items);

      if (!mounted) {
        return true;
      }

      _invalidate();

      setState(() {
        _busy = false;
        _selected.clear();
        _exiting.clear();
        _selectionMode = false;
      });

      return true;
    }

    setState(() {
      _busy = false;
      _exiting.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Não foi possível concluir a ação.'),
      ),
    );

    return false;
  }

  Future<void> _clearCoverIfNeeded(
    List<PhotoFolderItem> movedItems,
  ) async {
    final folder = ref
        .read(
          photoFolderProvider(widget.folderId),
        )
        .value;

    final coverId = folder?.coverAssetId;

    if (coverId == null) {
      return;
    }

    final coverWasMoved = movedItems.any(
      (item) => item.assetId == coverId,
    );

    if (!coverWasMoved) {
      return;
    }

    await ref
        .read(photoFolderRepositoryProvider)
        .setCover(
          folderId: widget.folderId,
          assetId: null,
        );
  }

  void _invalidate() {
    ref
      ..invalidate(
        photoFolderProvider(widget.folderId),
      )
      ..invalidate(
        photoFolderItemsProvider(widget.folderId),
      )
      ..invalidate(photoFoldersProvider)
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.favorite,
        ),
      )
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.markedForDeletion,
        ),
      );
  }
}

enum _FolderBatchAction {
  favorite,
  move,
  review,
  unreviewed,
}

enum _FolderItemMenuAction {
  move,
  cover,
  favorite,
  review,
  unreviewed,
}

class _FolderItemsGrid extends StatelessWidget {
  const _FolderItemsGrid({
    required this.items,
    required this.selected,
    required this.exiting,
    required this.coverAssetId,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMenuAction,
    super.key,
  });

  final List<PhotoFolderItem> items;
  final Set<String> selected;
  final Set<String> exiting;
  final String? coverAssetId;
  final bool selectionMode;
  final ValueChanged<PhotoFolderItem> onTap;
  final ValueChanged<PhotoFolderItem> onLongPress;
  final Future<void> Function(
    PhotoFolderItem item,
    _FolderItemMenuAction action,
  ) onMenuAction;

  @override
  Widget build(BuildContext context) {
    final groups =
        <DateTime, List<PhotoFolderItem>>{};

    for (final item in items) {
      final date =
          item.assetCreatedAt ?? item.assignedAt;
      final key =
          DateTime(date.year, date.month, date.day);

      groups
          .putIfAbsent(
            key,
            () => <PhotoFolderItem>[],
          )
          .add(item);
    }

    final slivers = <Widget>[];

    for (final entry in groups.entries) {
      slivers
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                photoFolderDateLabel(entry.key),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
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
                    selected:
                        selected.contains(item.assetId),
                    exiting:
                        exiting.contains(item.assetId),
                    isCover:
                        coverAssetId == item.assetId,
                    selectionMode: selectionMode,
                    onTap: () => onTap(item),
                    onLongPress: () =>
                        onLongPress(item),
                    onMenuAction: (action) =>
                        onMenuAction(item, action),
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
}

class _FolderPhotoTile extends StatelessWidget {
  const _FolderPhotoTile({
    required this.item,
    required this.selected,
    required this.exiting,
    required this.isCover,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMenuAction,
  });

  final PhotoFolderItem item;
  final bool selected;
  final bool exiting;
  final bool isCover;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<_FolderItemMenuAction>
      onMenuAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: exiting ? 0 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        scale: exiting ? 0.9 : 1,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GalleryThumbnail(
                assetId: item.assetId,
              ),
              if (selectionMode)
                ColoredBox(
                  color: selected
                      ? theme.colorScheme.primary
                          .withValues(alpha: 0.28)
                      : Colors.black
                          .withValues(alpha: 0.06),
                ),
              if (isCover)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.64,
                      ),
                      borderRadius:
                          BorderRadius.circular(999),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (selectionMode)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons
                            .radio_button_unchecked_rounded,
                    color: selected
                        ? theme.colorScheme.primary
                        : Colors.white,
                  ),
                )
              else
                Positioned(
                  top: 0,
                  right: 0,
                  child:
                      PopupMenuButton<
                          _FolderItemMenuAction>(
                    color: theme.colorScheme.surface,
                    iconColor: Colors.white,
                    onSelected: onMenuAction,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value:
                            _FolderItemMenuAction.move,
                        child: Text(
                          'Mover para outra pasta',
                        ),
                      ),
                      PopupMenuItem(
                        value:
                            _FolderItemMenuAction.cover,
                        child:
                            Text('Usar como capa'),
                      ),
                      PopupMenuItem(
                        value:
                            _FolderItemMenuAction.favorite,
                        child: Text('Favoritar'),
                      ),
                      PopupMenuItem(
                        value:
                            _FolderItemMenuAction.review,
                        child: Text(
                          'Enviar para revisão',
                        ),
                      ),
                      PopupMenuItem(
                        value: _FolderItemMenuAction
                            .unreviewed,
                        child: Text(
                          'Voltar para não revisadas',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderSelectionBar extends StatelessWidget {
  const _FolderSelectionBar({
    required this.busy,
    required this.onFavorite,
    required this.onMove,
    required this.onReview,
    required this.onUnreviewed,
  });

  final bool busy;
  final VoidCallback onFavorite;
  final VoidCallback onMove;
  final VoidCallback onReview;
  final VoidCallback onUnreviewed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            _BottomAction(
              label: 'Favoritar',
              icon: Icons.favorite_outline_rounded,
              enabled: !busy,
              onTap: onFavorite,
            ),
            _BottomAction(
              label: 'Mover',
              icon: Icons.drive_file_move_outline,
              enabled: !busy,
              onTap: onMove,
            ),
            _BottomAction(
              label: 'Revisar',
              icon: Icons.delete_outline_rounded,
              enabled: !busy,
              onTap: onReview,
            ),
            _BottomAction(
              label: 'Não revisar',
              icon: Icons.undo_rounded,
              enabled: !busy,
              onTap: onUnreviewed,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 10),
              ),
            ],
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Esta pasta está vazia',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Organize fotos durante a triagem ou mova fotos de outra pasta para cá.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nenhuma foto encontrada para essa data.',
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onRetry,
        child: const Text('Tentar novamente'),
      ),
    );
  }
}
