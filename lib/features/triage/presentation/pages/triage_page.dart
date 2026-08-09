import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/photo_folders/presentation/widgets/photo_folder_picker_sheet.dart';
import 'package:delivo/features/triage/presentation/providers/triage_controller.dart';
import 'package:delivo/features/triage/presentation/triage_state.dart';
import 'package:delivo/features/triage/presentation/widgets/triage_photo_view.dart';
import 'package:delivo/features/triage/presentation/widgets/triage_swipe_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TriagePage extends ConsumerStatefulWidget {
  const TriagePage({super.key});

  @override
  ConsumerState<TriagePage> createState() =>
      _TriagePageState();
}

class _TriagePageState
    extends ConsumerState<TriagePage> {
  final GlobalKey<TriageSwipeCardState> _cardKey =
      GlobalKey<TriageSwipeCardState>();

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(
      () => ref
          .read(triageControllerProvider.notifier)
          .load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(triageControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          TriageLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          TriageReady() => _ReadyTriage(
              state: state,
              cardKey: _cardKey,
            ),
          TriageEmpty() =>
            const _TriageEmptyView(),
          TriageFailure(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ReadyTriage extends ConsumerWidget {
  const _ReadyTriage({
    required this.state,
    required this.cardKey,
  });

  final TriageReady state;
  final GlobalKey<TriageSwipeCardState> cardKey;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final controller =
        ref.read(triageControllerProvider.notifier);

    Future<bool> persistFavorite() async {
      final success =
          await controller.persistFavoriteCurrent();

      if (success) {
        await HapticFeedback.mediumImpact();
      }

      return success;
    }

    Future<bool> persistDeletion() async {
      final success =
          await controller.persistDeletionCurrent();

      if (success) {
        await HapticFeedback.mediumImpact();
      }

      return success;
    }

    Future<bool> persistOrganization() async {
      final folder =
          await PhotoFolderPickerSheet.show(context);

      if (folder == null) {
        return false;
      }

      final success =
          await controller.persistOrganizeCurrent(
        folder,
      );

      if (success) {
        await HapticFeedback.mediumImpact();
      }

      return success;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          _TriageHeader(
            loadedPosition: state.currentPosition,
            date: state.currentPhoto.createdAt,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RepaintBoundary(
              child: TriageSwipeCard(
                key: cardKey,
                enabled: !state.isPersisting,
                onFavorite: persistFavorite,
                onMarkForDeletion:
                    persistDeletion,
                onOrganize:
                    persistOrganization,
                onDecisionCompleted:
                    controller
                        .completePersistedDecision,
                onDecisionAnimationFailed:
                    controller
                        .cancelPersistingState,
                child: TriagePhotoView(
                  key: ValueKey(
                    state.currentPhoto.id,
                  ),
                  assetId: state.currentPhoto.id,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionBar(
            canUndo:
                state.canUndo && !state.isPersisting,
            enabled: !state.isPersisting,
            onDelete: () => cardKey.currentState
                ?.triggerDeletion(),
            onUndo: () async {
              await controller.undo();
              await HapticFeedback.selectionClick();
            },
            onOrganize: () => cardKey.currentState
                ?.triggerOrganize(),
            onFavorite: () => cardKey.currentState
                ?.triggerFavorite(),
          ),
        ],
      ),
    );
  }
}

class _TriageHeader extends StatelessWidget {
  const _TriageHeader({
    required this.loadedPosition,
    required this.date,
  });

  final int loadedPosition;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () =>
                  Navigator.of(context).maybePop(),
              tooltip: 'Voltar',
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
          ),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                _formatDate(date),
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Foto $loadedPosition',
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  color: theme.colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Como funciona',
              onPressed: () =>
                  _showGestureHelp(context),
              icon: const Icon(
                Icons.info_outline_rounded,
              ),
            ),
          ),
        ],
      ),
    );
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

  static Future<void> _showGestureHelp(
    BuildContext context,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GestureHelpItem(
                icon: Icons
                    .keyboard_arrow_up_rounded,
                color: AppColors.destructive,
                title: 'Para cima',
                description:
                    'Marcar para revisão de exclusão',
              ),
              SizedBox(height: AppSpacing.md),
              _GestureHelpItem(
                icon: Icons
                    .keyboard_arrow_down_rounded,
                color: AppColors.favorite,
                title: 'Para baixo',
                description:
                    'Favoritar e manter',
              ),
              SizedBox(height: AppSpacing.md),
              _GestureHelpItem(
                icon: Icons.swap_horiz_rounded,
                color: AppColors.secondary,
                title: 'Para o lado',
                description:
                    'Organizar em uma pasta',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.canUndo,
    required this.enabled,
    required this.onDelete,
    required this.onUndo,
    required this.onOrganize,
    required this.onFavorite,
  });

  final bool canUndo;
  final bool enabled;
  final VoidCallback onDelete;
  final VoidCallback onUndo;
  final VoidCallback onOrganize;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          label: 'Revisar',
          tooltip: 'Marcar para exclusão',
          icon: Icons.close_rounded,
          color: AppColors.destructive,
          onPressed:
              enabled ? onDelete : null,
        ),
        _ActionButton(
          label: 'Desfazer',
          tooltip: 'Desfazer última decisão',
          icon: Icons.undo_rounded,
          color:
              theme.colorScheme.onSurfaceVariant,
          onPressed:
              canUndo ? onUndo : null,
        ),
        _ActionButton(
          label: 'Organizar',
          tooltip: 'Organizar em pasta',
          icon: Icons.folder_rounded,
          color: AppColors.secondary,
          onPressed:
              enabled ? onOrganize : null,
        ),
        _ActionButton(
          label: 'Favoritar',
          tooltip: 'Favoritar e manter',
          icon: Icons.favorite_rounded,
          color: AppColors.favorite,
          onPressed:
              enabled ? onFavorite : null,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Semantics(
      label: tooltip,
      button: true,
      enabled: !disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            iconSize: 27,
            style: IconButton.styleFrom(
              minimumSize:
                  const Size.square(58),
              foregroundColor: color,
              backgroundColor:
                  color.withValues(alpha: 0.11),
              disabledForegroundColor:
                  Theme.of(context)
                      .disabledColor,
              disabledBackgroundColor:
                  Theme.of(context)
                      .disabledColor
                      .withValues(alpha: 0.07),
            ),
            icon: Icon(icon),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
              color: disabled
                  ? Theme.of(context)
                      .disabledColor
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GestureHelpItem extends StatelessWidget {
  const _GestureHelpItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: theme.colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TriageEmptyView extends StatelessWidget {
  const _TriageEmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 42,
                color:
                    theme.colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'Tudo revisado por enquanto.',
              style:
                  theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
