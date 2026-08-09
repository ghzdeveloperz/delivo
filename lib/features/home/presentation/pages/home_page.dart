import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/home/presentation/providers/home_summary_provider.dart';
import 'package:delivo/features/home/presentation/widgets/home_stat_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Delivo', style: theme.textTheme.headlineMedium),
                ),
                IconButton(
                  onPressed: () {},
                  tooltip: 'Configurações',
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sua galeria, mais leve.',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Revise suas fotos com segurança e decida o que manter, organizar ou revisar para exclusão.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 56,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Iniciar triagem'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Visão geral', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.55,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                HomeStatItem(
                  icon: Icons.photo_library_outlined,
                  label: 'Não revisadas',
                  value: '${summary.unreviewedCount}',
                ),
                HomeStatItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Favoritas',
                  value: '${summary.favoriteCount}',
                ),
                HomeStatItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Para revisar',
                  value: '${summary.markedForDeletionCount}',
                ),
                HomeStatItem(
                  icon: Icons.sd_storage_outlined,
                  label: 'Espaço estimado',
                  value: _formatBytes(summary.estimatedBytesToFree),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _NavigationTile(
              icon: Icons.folder_outlined,
              title: 'Pastas',
              subtitle: 'Organize fotos para decidir depois',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            _NavigationTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Revisar exclusão',
              subtitle: 'Nenhuma foto é excluída sem sua confirmação',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final megabytes = bytes / (1024 * 1024);

    if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(0)} MB';
    }

    final gigabytes = megabytes / 1024;
    return '${gigabytes.toStringAsFixed(1)} GB';
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
