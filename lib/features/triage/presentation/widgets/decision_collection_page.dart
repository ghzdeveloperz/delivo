import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision.dart';
import 'package:delivo/features/triage/domain/entities/photo_decision_record.dart';
import 'package:delivo/features/triage/presentation/providers/decision_collection_provider.dart';
import 'package:delivo/features/triage/presentation/providers/triage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecisionCollectionPage extends ConsumerStatefulWidget {
  const DecisionCollectionPage({
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.decision,
    required this.actionLabel,
    required this.actionIcon,
    super.key,
  });

  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final PhotoDecision decision;
  final String actionLabel;
  final IconData actionIcon;

  @override
  ConsumerState<DecisionCollectionPage> createState() =>
      _DecisionCollectionPageState();
}

class _DecisionCollectionPageState
    extends ConsumerState<DecisionCollectionPage> {
  static const Duration _removeAnimationDuration =
      Duration(milliseconds: 220);

  final Set<String> _removingAssetIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      decisionCollectionProvider(widget.decision),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: recordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => _ErrorView(
          onRetry: () => ref.invalidate(
            decisionCollectionProvider(widget.decision),
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return _EmptyView(
              title: widget.emptyTitle,
              description: widget.emptyDescription,
            );
          }

          return _GroupedDecisionGrid(
            records: records,
            actionLabel: widget.actionLabel,
            actionIcon: widget.actionIcon,
            removingAssetIds: _removingAssetIds,
            removeAnimationDuration: _removeAnimationDuration,
            onRestore: _restore,
          );
        },
      ),
    );
  }

  Future<void> _restore(PhotoDecisionRecord record) async {
    if (_removingAssetIds.contains(record.assetId)) {
      return;
    }

    setState(() {
      _removingAssetIds.add(record.assetId);
    });

    await Future<void>.delayed(_removeAnimationDuration);

    if (!mounted) {
      return;
    }

    final result = await ref
        .read(photoDecisionRepositoryProvider)
        .removeDecision(record.assetId);

    final success = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ref.invalidate(
        decisionCollectionProvider(widget.decision),
      );

      return;
    }

    setState(() {
      _removingAssetIds.remove(record.assetId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Não foi possível restaurar a foto.',
        ),
      ),
    );
  }
}

class _GroupedDecisionGrid extends StatelessWidget {
  const _GroupedDecisionGrid({
    required this.records,
    required this.actionLabel,
    required this.actionIcon,
    required this.removingAssetIds,
    required this.removeAnimationDuration,
    required this.onRestore,
  });

  final List<PhotoDecisionRecord> records;
  final String actionLabel;
  final IconData actionIcon;
  final Set<String> removingAssetIds;
  final Duration removeAnimationDuration;
  final Future<void> Function(PhotoDecisionRecord record) onRestore;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate(records);
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
                  final record = entry.value[index];
                  final isRemoving =
                      removingAssetIds.contains(record.assetId);

                  return _DecisionPhotoTile(
                    key: ValueKey(record.assetId),
                    record: record,
                    actionLabel: actionLabel,
                    actionIcon: actionIcon,
                    isRemoving: isRemoving,
                    removeAnimationDuration:
                        removeAnimationDuration,
                    onRestore: () => onRestore(record),
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

  static Map<DateTime, List<PhotoDecisionRecord>> _groupByDate(
    List<PhotoDecisionRecord> records,
  ) {
    final groups = <DateTime, List<PhotoDecisionRecord>>{};

    for (final record in records) {
      final date = record.assetCreatedAt ?? record.decidedAt;
      final key = DateTime(date.year, date.month, date.day);

      groups.putIfAbsent(
        key,
        () => <PhotoDecisionRecord>[],
      ).add(record);
    }

    final keys = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return <DateTime, List<PhotoDecisionRecord>>{
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

class _DecisionPhotoTile extends StatelessWidget {
  const _DecisionPhotoTile({
    required this.record,
    required this.actionLabel,
    required this.actionIcon,
    required this.isRemoving,
    required this.removeAnimationDuration,
    required this.onRestore,
    super.key,
  });

  final PhotoDecisionRecord record;
  final String actionLabel;
  final IconData actionIcon;
  final bool isRemoving;
  final Duration removeAnimationDuration;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isRemoving,
      child: AnimatedOpacity(
        duration: removeAnimationDuration,
        curve: Curves.easeOutCubic,
        opacity: isRemoving ? 0 : 1,
        child: AnimatedScale(
          duration: removeAnimationDuration,
          curve: Curves.easeInOutCubic,
          scale: isRemoving ? 0.88 : 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GalleryThumbnail(
                assetId: record.assetId,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Semantics(
                    button: true,
                    label: actionLabel,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: actionLabel,
                        visualDensity: VisualDensity.compact,
                        onPressed: onRestore,
                        color: Colors.white,
                        iconSize: 19,
                        icon: Icon(actionIcon),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

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
              size: 52,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Não foi possível carregar esta coleção.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
