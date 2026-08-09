
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/core/widgets/photo_fullscreen_viewer.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:delivo/features/photo_folders/presentation/widgets/photo_folder_picker_sheet.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/domain/services/decision_collection_filter.dart';
import 'package:delivo/features/triage/presentation/providers/decision_collection_provider.dart';
import 'package:delivo/features/triage/presentation/providers/photo_decision_batch_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() =>
      _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  static const Duration _exitDuration =
      Duration(milliseconds: 240);

  final TextEditingController _searchController =
      TextEditingController();
  final Set<String> _selected = <String>{};
  final Set<String> _exiting = <String>{};

  DecisionCollectionSort _sort =
      DecisionCollectionSort.photoNewest;
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
    final recordsAsync = ref.watch(
      decisionCollectionProvider(PhotoDecision.favorite),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selected.length} selecionada${_selected.length == 1 ? '' : 's'}'
              : 'Favoritas',
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
              onPressed: () {
                final records = recordsAsync.value ??
                    const <PhotoDecisionRecord>[];
                setState(() {
                  _selected
                    ..clear()
                    ..addAll(
                      records.map((record) => record.assetId),
                    );
                });
              },
              child: const Text('Todas'),
            )
          else
            TextButton(
              onPressed: recordsAsync.value?.isNotEmpty == true
                  ? () => setState(() {
                        _selectionMode = true;
                      })
                  : null,
              child: const Text('Selecionar'),
            ),
        ],
      ),
      bottomNavigationBar:
          _selectionMode && _selected.isNotEmpty
              ? _SelectionBar(
                  busy: _busy,
                  onRemove: () => _apply(
                    _selectedRecords(),
                    _FavoriteAction.remove,
                  ),
                  onOrganize: () => _apply(
                    _selectedRecords(),
                    _FavoriteAction.organize,
                  ),
                  onReview: () => _apply(
                    _selectedRecords(),
                    _FavoriteAction.review,
                  ),
                )
              : null,
      body: recordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Não foi possível carregar as favoritas.',
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Suas fotos favoritas aparecerão aqui.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final visible = filterAndSortDecisionRecords(
            records: records,
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
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por data, mês ou ano',
                          prefixIcon:
                              Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    PopupMenuButton<
                        DecisionCollectionSort>(
                      tooltip: 'Ordenar',
                      icon:
                          const Icon(Icons.swap_vert_rounded),
                      onSelected: (value) {
                        setState(() {
                          _sort = value;
                        });
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: DecisionCollectionSort
                              .photoNewest,
                          child: Text(
                            'Fotos mais recentes',
                          ),
                        ),
                        PopupMenuItem(
                          value: DecisionCollectionSort
                              .photoOldest,
                          child: Text(
                            'Fotos mais antigas',
                          ),
                        ),
                        PopupMenuItem(
                          value: DecisionCollectionSort
                              .decisionNewest,
                          child: Text(
                            'Favoritadas recentemente',
                          ),
                        ),
                        PopupMenuItem(
                          value: DecisionCollectionSort
                              .decisionOldest,
                          child: Text(
                            'Favoritadas primeiro',
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
                      ? const Center(
                          key: ValueKey<String>('empty-search'),
                          child: Text(
                            'Nenhuma favorita encontrada.',
                          ),
                        )
                      : _FavoritesGrid(
                          key: ValueKey<String>(
                            '${visible.length}-$_query-$_sort',
                          ),
                          records: visible,
                          selected: _selected,
                          exiting: _exiting,
                          selectionMode: _selectionMode,
                          onTap: _onTap,
                          onLongPress: (record) {
                            setState(() {
                              _selectionMode = true;
                              _toggle(record.assetId);
                            });
                          },
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

  List<PhotoDecisionRecord> _selectedRecords() {
    final records = ref
            .read(
              decisionCollectionProvider(
                PhotoDecision.favorite,
              ),
            )
            .value ??
        const <PhotoDecisionRecord>[];

    return records
        .where(
          (record) => _selected.contains(record.assetId),
        )
        .toList(growable: false);
  }

  Future<void> _onTap(
    PhotoDecisionRecord record,
  ) async {
    if (_selectionMode) {
      setState(() {
        _toggle(record.assetId);
      });
      return;
    }

    final changed =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PhotoFullscreenViewer(
          assetId: record.assetId,
          actions: [
            PhotoViewerAction(
              label: 'Desfavoritar',
              icon: Icons.heart_broken_outlined,
              onPressed: () => _apply(
                <PhotoDecisionRecord>[record],
                _FavoriteAction.remove,
              ),
            ),
            PhotoViewerAction(
              label: 'Organizar',
              icon: Icons.folder_outlined,
              onPressed: () => _apply(
                <PhotoDecisionRecord>[record],
                _FavoriteAction.organize,
              ),
            ),
            PhotoViewerAction(
              label: 'Revisar',
              icon: Icons.delete_outline_rounded,
              onPressed: () => _apply(
                <PhotoDecisionRecord>[record],
                _FavoriteAction.review,
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

  Future<bool> _apply(
    List<PhotoDecisionRecord> records,
    _FavoriteAction action,
  ) async {
    if (records.isEmpty || _busy) {
      return false;
    }

    String? folderId;

    if (action == _FavoriteAction.organize) {
      final folder =
          await PhotoFolderPickerSheet.show(context);

      if (folder == null) {
        return false;
      }

      folderId = folder.id;
    }

    if (action == _FavoriteAction.review) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Enviar para revisão de exclusão?',
            ),
            content: Text(
              records.length == 1
                  ? 'Esta foto deixará de ser favorita e ficará marcada para revisão. Ela ainda não será excluída.'
                  : '${records.length} fotos deixarão de ser favoritas e ficarão marcadas para revisão. Nenhuma será excluída agora.',
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
        records.map((record) => record.assetId),
      );
    });

    await Future<void>.delayed(_exitDuration);

    final service =
        ref.read(photoDecisionBatchServiceProvider);

    final result = switch (action) {
      _FavoriteAction.remove =>
        await service.clearDecisions(
          records.map((record) => record.assetId),
        ),
      _FavoriteAction.organize =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.organized,
          folderId: folderId,
        ),
      _FavoriteAction.review =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.markedForDeletion,
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
      _invalidate();
      setState(() {
        _busy = false;
        _exiting.clear();
        _selected.clear();
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

  void _invalidate() {
    ref
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.favorite,
        ),
      )
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.markedForDeletion,
        ),
      )
      ..invalidate(photoFoldersProvider);
  }
}

enum _FavoriteAction {
  remove,
  organize,
  review,
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({
    required this.records,
    required this.selected,
    required this.exiting,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final List<PhotoDecisionRecord> records;
  final Set<String> selected;
  final Set<String> exiting;
  final bool selectionMode;
  final ValueChanged<PhotoDecisionRecord> onTap;
  final ValueChanged<PhotoDecisionRecord> onLongPress;

  @override
  Widget build(BuildContext context) {
    final groups =
        <DateTime, List<PhotoDecisionRecord>>{};

    for (final record in records) {
      final date =
          record.assetCreatedAt ?? record.decidedAt;
      final key =
          DateTime(date.year, date.month, date.day);
      groups
          .putIfAbsent(
            key,
            () => <PhotoDecisionRecord>[],
          )
          .add(record);
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
                decisionCollectionDateLabel(entry.key),
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
                  final record = entry.value[index];
                  final isSelected =
                      selected.contains(record.assetId);
                  final isExiting =
                      exiting.contains(record.assetId);

                  return AnimatedOpacity(
                    duration: const Duration(
                      milliseconds: 240,
                    ),
                    opacity: isExiting ? 0 : 1,
                    child: AnimatedScale(
                      duration: const Duration(
                        milliseconds: 240,
                      ),
                      curve: Curves.easeOutCubic,
                      scale: isExiting ? 0.9 : 1,
                      child: GestureDetector(
                        onTap: () => onTap(record),
                        onLongPress: () =>
                            onLongPress(record),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GalleryThumbnail(
                              assetId: record.assetId,
                            ),
                            if (selectionMode)
                              ColoredBox(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(
                                          alpha: 0.28,
                                        )
                                    : Colors.black
                                        .withValues(
                                          alpha: 0.06,
                                        ),
                              ),
                            if (selectionMode)
                              Align(
                                alignment:
                                    Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(6),
                                  child: Icon(
                                    isSelected
                                        ? Icons
                                            .check_circle_rounded
                                        : Icons
                                            .radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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

    return CustomScrollView(slivers: slivers);
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.busy,
    required this.onRemove,
    required this.onOrganize,
    required this.onReview,
  });

  final bool busy;
  final VoidCallback onRemove;
  final VoidCallback onOrganize;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            _Action(
              label: 'Remover',
              icon: Icons.heart_broken_outlined,
              enabled: !busy,
              onTap: onRemove,
            ),
            _Action(
              label: 'Organizar',
              icon: Icons.folder_outlined,
              enabled: !busy,
              onTap: onOrganize,
            ),
            _Action(
              label: 'Revisar',
              icon: Icons.delete_outline_rounded,
              enabled: !busy,
              onTap: onReview,
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
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
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
