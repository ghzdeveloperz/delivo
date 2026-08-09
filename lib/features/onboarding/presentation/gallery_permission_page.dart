import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_access_state.dart';
import 'package:delivo/features/gallery_access/presentation/providers/gallery_access_controller.dart';
import 'package:delivo/features/home/presentation/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryPermissionPage extends ConsumerWidget {
  const GalleryPermissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryAccessControllerProvider);
    final theme = Theme.of(context);

    final isLoading = state is GalleryAccessRequestingPermission;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PermissionIcon(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Suas fotos continuam suas.',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'O Delivo precisa visualizar sua galeria para mostrar as fotos durante a triagem.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _PrivacyItem(
                icon: Icons.cloud_off_outlined,
                title: 'Sem upload por padrão',
                description:
                    'As fotos permanecem no seu dispositivo durante este fluxo.',
              ),
              const SizedBox(height: AppSpacing.md),
              const _PrivacyItem(
                icon: Icons.delete_outline_rounded,
                title: 'Marcar não significa excluir',
                description:
                    'A exclusão física só acontecerá depois de revisão e confirmação.',
              ),
              const SizedBox(height: AppSpacing.md),
              const _PrivacyItem(
                icon: Icons.folder_outlined,
                title: 'Pastas serão lógicas',
                description:
                    'Organizar uma foto no Delivo não move o arquivo original.',
              ),
              const Spacer(),
              if (state is GalleryAccessPermissionDenied) ...[
                Text(
                  'O acesso não foi concedido. Você pode tentar novamente ou abrir as configurações do sistema.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(galleryAccessControllerProvider.notifier)
                          .openSettings(),
                  child: const Text('Abrir configurações'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (state case GalleryAccessFailure(:final message)) ...[
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final granted = await ref
                              .read(galleryAccessControllerProvider.notifier)
                              .requestPermission();

                          if (!context.mounted || !granted) {
                            return;
                          }

                          ref.invalidate(homeSummaryProvider);

                          await Navigator.of(context).pushReplacementNamed(
                            AppRoutes.galleryPreview,
                          );
                        },
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionIcon extends StatelessWidget {
  const _PermissionIcon();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 72,
        child: Icon(
          Icons.photo_library_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
