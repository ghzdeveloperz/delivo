
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/core/widgets/photo_fullscreen_viewer.dart';
import 'package:delivo/features/deletion_review/domain/entities/deletion_batch_result.dart';
import 'package:delivo/features/deletion_review/presentation/providers/deletion_review_providers.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_asset_metrics_provider.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:delivo/features/photo_folders/presentation/widgets/photo_folder_picker_sheet.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/domain/services/decision_collection_filter.dart';
import 'package:delivo/features/triage/presentation/providers/decision_collection_provider.dart';
import 'package:delivo/features/triage/presentation/providers/photo_decision_batch_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkedForDeletionPage extends ConsumerStatefulWidget {
  const MarkedForDeletionPage({super.key});

  @override
  ConsumerState<MarkedForDeletionPage> createState() =>
      _MarkedForDeletionPageState();
}

class _MarkedForDeletionPageState
    extends ConsumerState<MarkedForDeletionPage> {
  static const Duration _exitDuration =
      Duration(milliseconds: 240);

  final Set<String> _selected = <String>{};
  final Set<String> _exiting = <String>{};

  bool _selectionMode = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      decisionCollectionProvider(
        PhotoDecision.markedForDeletion,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selected.length} selecionada${_selected.length == 1 ? '' : 's'}'
              : 'Revisar exclusão',
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
              ? _DeletionSelectionBar(
                  busy: _busy,
                  onRestore: () => _applySafeTransition(
                    _selectedRecords(),
                    _DeletionSafeAction.restore,
                  ),
                  onFavorite: () => _applySafeTransition(
                    _selectedRecords(),
                    _DeletionSafeAction.favorite,
                  ),
                  onOrganize: () => _applySafeTransition(
                    _selectedRecords(),
                    _DeletionSafeAction.organize,
                  ),
                  onDelete: _deleteSelected,
                )
              : null,
      body: recordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Não foi possível carregar a revisão.',
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Nenhuma foto está marcada para exclusão.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final selectedRecords = records
              .where(
                (record) =>
                    _selected.contains(record.assetId),
              )
              .toList(growable: false);

          return Column(
            children: [
              _DeletionSummary(
                allRecords: records,
                selectedRecords: selectedRecords,
                selectionMode: _selectionMode,
              ),
              Expanded(
                child: _DeletionGrid(
                  records: records,
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
                PhotoDecision.markedForDeletion,
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
              label: 'Restaurar',
              icon: Icons.undo_rounded,
              onPressed: () => _applySafeTransition(
                <PhotoDecisionRecord>[record],
                _DeletionSafeAction.restore,
              ),
            ),
            PhotoViewerAction(
              label: 'Favoritar',
              icon: Icons.favorite_outline_rounded,
              onPressed: () => _applySafeTransition(
                <PhotoDecisionRecord>[record],
                _DeletionSafeAction.favorite,
              ),
            ),
            PhotoViewerAction(
              label: 'Organizar',
              icon: Icons.folder_outlined,
              onPressed: () => _applySafeTransition(
                <PhotoDecisionRecord>[record],
                _DeletionSafeAction.organize,
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

  Future<bool> _applySafeTransition(
    List<PhotoDecisionRecord> records,
    _DeletionSafeAction action,
  ) async {
    if (records.isEmpty || _busy) {
      return false;
    }

    String? folderId;

    if (action == _DeletionSafeAction.organize) {
      final folder =
          await PhotoFolderPickerSheet.show(context);

      if (folder == null) {
        return false;
      }

      folderId = folder.id;
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
      _DeletionSafeAction.restore =>
        await service.clearDecisions(
          records.map((record) => record.assetId),
        ),
      _DeletionSafeAction.favorite =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.favorite,
        ),
      _DeletionSafeAction.organize =>
        await service.replaceDecision(
          records: records,
          decision: PhotoDecision.organized,
          folderId: folderId,
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

  Future<void> _deleteSelected() async {
    final records = _selectedRecords();

    if (records.isEmpty || _busy) {
      return;
    }

    final ids =
        records.map((record) => record.assetId).toSet();

    final metrics =
        ref.read(galleryAssetMetricsServiceProvider);
    final bytes = await metrics.totalBytes(ids);

    if (!mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir fotos do dispositivo?',
          ),
          content: Text(
            '${records.length} ${records.length == 1 ? 'foto selecionada' : 'fotos selecionadas'} · ${_formatBytes(bytes)}\n\n'
            'Esta é a exclusão física. O sistema operacional poderá solicitar uma confirmação adicional. '
            'Dependendo do dispositivo, itens excluídos podem ou não permanecer em uma área de apagados recentemente.',
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
              child: const Text('Excluir selecionadas'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final result = await ref
        .read(deletionReviewServiceProvider)
        .delete(ids);

    metrics.removeFromCache(result.deletedIds);

    if (!mounted) {
      return;
    }

    _invalidate();

    setState(() {
      _busy = false;
      _selected.clear();
      _selectionMode = false;
    });

    await _showResult(result);
  }

  Future<void> _showResult(
    DeletionBatchResult result,
  ) {
    final deleted = result.deletedIds.length;
    final failed = result.failedIds.length;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                result.isCompleteSuccess
                    ? 'Exclusão concluída'
                    : result.isPartial
                        ? 'Exclusão parcial'
                        : 'Exclusão não concluída',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$deleted excluída${deleted == 1 ? '' : 's'}',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$failed não excluída${failed == 1 ? '' : 's'}',
              ),
              if (!result.localCleanupSucceeded) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'O sistema confirmou a exclusão, mas o índice local do Delivo não pôde ser totalmente sincronizado.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (result.systemCallFailed) ...[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'O sistema operacional não concluiu a solicitação. Verifique as permissões e tente novamente.',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _invalidate() {
    ref
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.markedForDeletion,
        ),
      )
      ..invalidate(
        decisionCollectionProvider(
          PhotoDecision.favorite,
        ),
      )
      ..invalidate(photoFoldersProvider);
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final megabytes = bytes / (1024 * 1024);

    if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(1)} MB';
    }

    return '${(megabytes / 1024).toStringAsFixed(2)} GB';
  }
}

enum _DeletionSafeAction {
  restore,
  favorite,
  organize,
}

class _DeletionSummary extends ConsumerWidget {
  const _DeletionSummary({
    required this.allRecords,
    required this.selectedRecords,
    required this.selectionMode,
  });

  final List<PhotoDecisionRecord> allRecords;
  final List<PhotoDecisionRecord> selectedRecords;
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records =
        selectionMode && selectedRecords.isNotEmpty
            ? selectedRecords
            : allRecords;

    final future = ref
        .read(galleryAssetMetricsServiceProvider)
        .totalBytes(
          records.map((record) => record.assetId),
        );

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estas fotos estão apenas marcadas. Revise tudo antes de excluir.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<int>(
            future: future,
            builder: (context, snapshot) {
              final sizeText = snapshot.hasData
                  ? _MarkedForDeletionPageState
                      ._formatBytes(snapshot.data!)
                  : 'calculando…';

              return Text(
                '${records.length} ${records.length == 1 ? 'foto' : 'fotos'} · $sizeText',
                style: theme.textTheme.titleSmall,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeletionGrid extends StatelessWidget {
  const _DeletionGrid({
    required this.records,
    required this.selected,
    required this.exiting,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
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

class _DeletionSelectionBar extends StatelessWidget {
  const _DeletionSelectionBar({
    required this.busy,
    required this.onRestore,
    required this.onFavorite,
    required this.onOrganize,
    required this.onDelete,
  });

  final bool busy;
  final VoidCallback onRestore;
  final VoidCallback onFavorite;
  final VoidCallback onOrganize;
  final VoidCallback onDelete;

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
              label: 'Restaurar',
              icon: Icons.undo_rounded,
              enabled: !busy,
              onTap: onRestore,
            ),
            _Action(
              label: 'Favoritar',
              icon: Icons.favorite_outline_rounded,
              enabled: !busy,
              onTap: onFavorite,
            ),
            _Action(
              label: 'Organizar',
              icon: Icons.folder_outlined,
              enabled: !busy,
              onTap: onOrganize,
            ),
            _Action(
              label: 'Excluir',
              icon: Icons.delete_forever_outlined,
              enabled: !busy,
              onTap: onDelete,
              destructive: true,
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
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
          foregroundColor: destructive
              ? Theme.of(context).colorScheme.error
              : null,
        ),
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
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
