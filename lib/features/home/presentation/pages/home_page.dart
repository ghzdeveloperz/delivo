
import 'dart:async';
import 'dart:ui';

import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/core/widgets/delivo_aurora_background.dart';
import 'package:delivo/core/widgets/delivo_theme_switch.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:delivo/features/home/presentation/providers/home_summary_provider.dart';
import 'package:delivo/features/home/presentation/widgets/home_stat_item.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const Duration _returnRefreshDelay =
      Duration(milliseconds: 650);

  Timer? _refreshTimer;
  HomeSummary _visibleSummary = HomeSummary.empty;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _openAndRefresh(
    String route, {
    Object? arguments,
  }) async {
    await Navigator.of(context).pushNamed(
      route,
      arguments: arguments,
    );

    if (!mounted) {
      return;
    }

    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer(
      _returnRefreshDelay,
      () {
        if (mounted) {
          ref.invalidate(homeSummaryProvider);
        }
      },
    );
  }

  Future<void> _refreshNow() async {
    _refreshTimer?.cancel();

    ref
      ..invalidate(homeSummaryProvider)
      ..invalidate(photoFoldersProvider);

    await ref.read(homeSummaryProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync =
        ref.watch(homeSummaryProvider);
    final foldersAsync =
        ref.watch(photoFoldersProvider);

    final latestSummary = summaryAsync.value;

    if (latestSummary != null &&
        latestSummary != _visibleSummary) {
      _visibleSummary = latestSummary;
    }

    final summary = _visibleSummary;
    final theme = Theme.of(context);
    final colors = _HomeThemeColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DelivoAuroraBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshNow,
            color: theme.colorScheme.primary,
            backgroundColor: colors.refreshBackground,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                12,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                const _HomeHeader(),
                const SizedBox(height: 22),

                Text(
                  'Sua galeria,\nmais leve.',
                  style: theme
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                    height: 1.00,
                    letterSpacing: -1.10,
                  ),
                ),

                const SizedBox(height: 12),

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 540),
                  child: Text(
                    'Revise suas fotos com segurança e decida o que manter, organizar ou revisar para exclusão.',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: colors.secondaryText,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _PrimaryTriageButton(
                  onPressed: () =>
                      _openAndRefresh(
                    AppRoutes.triage,
                  ),
                ),

                const SizedBox(height: 16),

                _ProgressPanel(
                  summary: summary,
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Visão geral',
                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    if (summaryAsync.isLoading &&
                        summaryAsync.value == null)
                      SizedBox.square(
                        dimension: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 94,
                  child: HomeStatItem(
                    emphasized: true,
                    icon:
                        Icons.photo_library_outlined,
                    label: 'Não revisadas',
                    value:
                        '${summary.unreviewedCount}',
                    animatedValue:
                        summary.unreviewedCount,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 118,
                  child: Row(
                    children: [
                      Expanded(
                        child: HomeStatItem(
                          icon: Icons
                              .star_outline_rounded,
                          label: 'Favoritas',
                          value:
                              '${summary.favoriteCount}',
                          animatedValue:
                              summary.favoriteCount,
                          onTap: () =>
                              _openAndRefresh(
                            AppRoutes.favorites,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HomeStatItem(
                          icon: Icons
                              .delete_outline_rounded,
                          label: 'Para revisar',
                          value:
                              '${summary.markedForDeletionCount}',
                          animatedValue: summary
                              .markedForDeletionCount,
                          onTap: () =>
                              _openAndRefresh(
                            AppRoutes
                                .markedForDeletion,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 94,
                  child: HomeStatItem(
                    emphasized: true,
                    icon:
                        Icons.sd_storage_outlined,
                    label: 'Espaço estimado',
                    value: _formatBytes(
                      summary.estimatedBytesToFree,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Organização',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.35,
                  ),
                ),

                const SizedBox(height: 10),

                _FoldersEditorialTile(
                  folders:
                      foldersAsync.value ??
                          const <PhotoFolder>[],
                  loading: foldersAsync.isLoading,
                  onTap: () =>
                      _openAndRefresh(
                    AppRoutes.photoFolders,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final megabytes =
        bytes / (1024 * 1024);

    if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(0)} MB';
    }

    final gigabytes = megabytes / 1024;
    return '${gigabytes.toStringAsFixed(1)} GB';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _HomeThemeColors.of(context);

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/brand/delivo_logo.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            colors.primaryText,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Delivo',
            style: theme
                .textTheme
                .titleLarge
                ?.copyWith(
              color: colors.primaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const DelivoThemeSwitch(),
      ],
    );
  }
}

class _PrimaryTriageButton extends StatelessWidget {
  const _PrimaryTriageButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.96,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius:
                BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7)
                    .withValues(
                  alpha: isDark ? 0.18 : 0.14,
                ),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius:
                BorderRadius.circular(16),
            child: InkWell(
              onTap: onPressed,
              borderRadius:
                  BorderRadius.circular(16),
              child: Center(
                child: Text(
                  'Iniciar triagem',
                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.summary,
  });

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _HomeThemeColors.of(context);
    final progress = summary.progress;

    final progressLabel =
        summary.progressPercent == 0 &&
                summary.reviewedCount > 0
            ? '<1%'
            : '${summary.progressPercent}%';

    return Semantics(
      label:
          'Progresso da galeria: $progressLabel. '
          '${summary.reviewedCount} de ${summary.totalPhotoCount} fotos revisadas.',
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12,
            ),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: colors.glassBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progresso da galeria',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: colors.primaryText,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      progressLabel,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                            const Color(0xFF7D6EF0),
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(999),
                  child: SizedBox(
                    height: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: colors.progressTrack,
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            end: progress,
                          ),
                          duration: const Duration(
                            milliseconds: 700,
                          ),
                          curve: Curves.easeOutCubic,
                          builder:
                              (context, value, _) {
                            return FractionallySizedBox(
                              widthFactor: value,
                              alignment:
                                  Alignment.centerLeft,
                              child:
                                  const DecoratedBox(
                                decoration:
                                    BoxDecoration(
                                  gradient: AppColors
                                      .brandGradient,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${summary.reviewedCount} de ${summary.totalPhotoCount} fotos revisadas',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoldersEditorialTile extends StatelessWidget {
  const _FoldersEditorialTile({
    required this.folders,
    required this.loading,
    required this.onTap,
  });

  final List<PhotoFolder> folders;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _HomeThemeColors.of(context);
    final previews = _previewIds(folders);
    final folderCount = folders.length;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Material(
          color: colors.folderSurface,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints:
                  const BoxConstraints(
                minHeight: 106,
              ),
              padding: const EdgeInsets.all(
                14,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: colors.folderBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FolderPreviewStack(
                    assetIds: previews,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Pastas',
                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color:
                                      colors.primaryText,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                  0xFF6C5CE7,
                                ).withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(999),
                              ),
                              child: Text(
                                loading
                                    ? '...'
                                    : '$folderCount',
                                style: theme
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color:
                                      const Color(
                                    0xFF7D6EF0,
                                  ),
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          loading
                              ? 'Carregando organização…'
                              : folderCount == 0
                                  ? 'Crie pastas para organizar suas fotos'
                                  : 'Acesse e organize suas coleções',
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color:
                                colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colors.chevron,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<String> _previewIds(
    List<PhotoFolder> folders,
  ) {
    final ids = <String>[];

    for (final folder in folders) {
      for (final id in folder.previewAssetIds) {
        if (!ids.contains(id)) {
          ids.add(id);
        }

        if (ids.length == 3) {
          return ids;
        }
      }
    }

    return ids;
  }
}

class _FolderPreviewStack extends StatelessWidget {
  const _FolderPreviewStack({
    required this.assetIds,
  });

  final List<String> assetIds;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (assetIds.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C5CE7).withValues(
                alpha: isDark ? 0.20 : 0.13,
              ),
              const Color(0xFF2D9CDB).withValues(
                alpha: isDark ? 0.07 : 0.06,
              ),
            ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white
                    .withValues(alpha: 0.05)
                : const Color(0xFFE5E7F0),
          ),
        ),
        child: const Icon(
          Icons.folder_outlined,
          color: Color(0xFF7D6EF0),
          size: 28,
        ),
      );
    }

    return SizedBox(
      width: size + 14,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0;
              index < assetIds.length;
              index++)
            Positioned(
              left: index * 7.0,
              top: index * 2.0,
              child: Transform.rotate(
                angle:
                    (index - 1) * 0.035,
                child: Container(
                  width: size - index * 3,
                  height: size - index * 3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(17),
                    border: Border.all(
                      color: isDark
                          ? Colors.white
                              .withValues(
                              alpha: 0.10,
                            )
                          : Colors.white,
                      width: isDark ? 1 : 1.5,
                    ),
                  ),
                  child: GalleryThumbnail(
                    assetId:
                        assetIds[index],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _HomeThemeColors {
  const _HomeThemeColors({
    required this.primaryText,
    required this.secondaryText,
    required this.glassSurface,
    required this.glassBorder,
    required this.progressTrack,
    required this.chevron,
    required this.shadow,
    required this.refreshBackground,
    required this.folderSurface,
    required this.folderBorder,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color glassSurface;
  final Color glassBorder;
  final Color progressTrack;
  final Color chevron;
  final Color shadow;
  final Color refreshBackground;
  final Color folderSurface;
  final Color folderBorder;

  factory _HomeThemeColors.of(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _HomeThemeColors(
        primaryText: Colors.white,
        secondaryText:
            Colors.white.withValues(alpha: 0.58),
        glassSurface:
            Colors.white.withValues(alpha: 0.035),
        glassBorder:
            Colors.white.withValues(alpha: 0.065),
        progressTrack:
            Colors.white.withValues(alpha: 0.07),
        chevron:
            Colors.white.withValues(alpha: 0.48),
        shadow:
            Colors.black.withValues(alpha: 0.10),
        refreshBackground:
            const Color(0xFF181B2D),
        folderSurface:
            Colors.white.withValues(alpha: 0.052),
        folderBorder:
            Colors.white.withValues(alpha: 0.095),
      );
    }

    return _HomeThemeColors(
      primaryText: const Color(0xFF171A2B),
      secondaryText: const Color(0xFF6B7085),
      glassSurface:
          Colors.white.withValues(alpha: 0.72),
      glassBorder:
          const Color(0xFFE5E7F0)
              .withValues(alpha: 0.92),
      progressTrack:
          const Color(0xFFE5E7F0),
      chevron: const Color(0xFF6B7085),
      shadow: const Color(0xFF171A2B)
          .withValues(alpha: 0.045),
      refreshBackground: Colors.white,
      folderSurface:
          Colors.white.withValues(alpha: 0.82),
      folderBorder:
          const Color(0xFFDDE1EC),
    );
  }
}
