import 'package:delivo/app/router/app_routes.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/gallery_access/presentation/gallery_thumbnail.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoFoldersPage extends ConsumerStatefulWidget {
  const PhotoFoldersPage({super.key});

  @override
  ConsumerState<PhotoFoldersPage> createState() =>
      _PhotoFoldersPageState();
}

class _PhotoFoldersPageState
    extends ConsumerState<PhotoFoldersPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(photoFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pastas'),
      ),
      body: foldersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => _ErrorView(
          onRetry: () => ref.invalidate(photoFoldersProvider),
        ),
        data: (folders) {
          if (folders.isEmpty) {
            return _EmptyFoldersView(
              onCreate: () => _createFolder(
                context,
                ref,
              ),
            );
          }

          final filtered = _filterFolders(
            folders,
            _query,
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
                child: _SearchBarWithCreateAction(
                  controller: _searchController,
                  hintText: 'Procurar pasta',
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  onCreate: () => _createFolder(
                    context,
                    ref,
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filtered.isEmpty
                      ? _NoSearchResults(
                          key: ValueKey<String>(
                            'empty-${_query.trim().toLowerCase()}',
                          ),
                        )
                      : GridView.builder(
                          key: ValueKey<String>(
                            'grid-${_query.trim().toLowerCase()}-${filtered.length}',
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.xxl,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 0.92,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final folder = filtered[index];

                            return _FolderCard(
                              folder: folder,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.photoFolderDetails,
                                arguments: folder.id,
                              ),
                              onRename: () => _renameFolder(
                                context,
                                ref,
                                folder,
                              ),
                              onDelete: () => _deleteFolder(
                                context,
                                ref,
                                folder,
                              ),
                            );
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

  List<PhotoFolder> _filterFolders(
    List<PhotoFolder> folders,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) {
      return folders;
    }

    return folders
        .where(
          (folder) =>
              folder.name.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  Future<void> _createFolder(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = await _requestName(
      context,
      title: 'Nova pasta',
      confirmLabel: 'Criar',
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    final result = await ref
        .read(photoFolderRepositoryProvider)
        .createFolder(name);

    final success = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (_) => false,
    );

    if (!context.mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Não foi possível criar a pasta. Talvez esse nome já esteja em uso.',
        ),
      ),
    );
  }

  Future<void> _renameFolder(
    BuildContext context,
    WidgetRef ref,
    PhotoFolder folder,
  ) async {
    final name = await _requestName(
      context,
      title: 'Renomear pasta',
      initialValue: folder.name,
      confirmLabel: 'Salvar',
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    await ref.read(photoFolderRepositoryProvider).renameFolder(
          folderId: folder.id,
          name: name,
        );
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    PhotoFolder folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir pasta?'),
          content: Text(
            'As ${folder.photoCount} fotos desta pasta voltarão para Não revisadas. Nenhum arquivo da galeria será apagado.',
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
              child: const Text('Excluir pasta'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(photoFolderRepositoryProvider)
        .deleteFolder(folder.id);
  }

  Future<String?> _requestName(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? initialValue,
  }) async {
    final controller = TextEditingController(
      text: initialValue,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome da pasta',
            ),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final PhotoFolder folder;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _FolderPhotoCollage(
                        assetIds: folder.previewAssetIds,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<_FolderMenuAction>(
                          color: theme.colorScheme.surface,
                          onSelected: (action) {
                            switch (action) {
                              case _FolderMenuAction.rename:
                                onRename();
                              case _FolderMenuAction.delete:
                                onDelete();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: _FolderMenuAction.rename,
                              child: Text('Renomear'),
                            ),
                            PopupMenuItem(
                              value: _FolderMenuAction.delete,
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${folder.photoCount} ${folder.photoCount == 1 ? 'foto' : 'fotos'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

class _FolderPhotoCollage extends StatelessWidget {
  const _FolderPhotoCollage({
    required this.assetIds,
  });

  final List<String> assetIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (assetIds.isEmpty) {
      return ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: Icon(
            Icons.folder_rounded,
            size: 54,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (assetIds.length == 1) {
      return _CoverThumbnail(
        assetId: assetIds[0],
      );
    }

    if (assetIds.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _CoverThumbnail(
              assetId: assetIds[1],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _CoverThumbnail(
              assetId: assetIds[0],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CoverThumbnail(
                  assetId: assetIds[1],
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: _CoverThumbnail(
                  assetId: assetIds[2],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _CoverThumbnail(
            assetId: assetIds[0],
          ),
        ),
      ],
    );
  }
}

class _CoverThumbnail extends StatelessWidget {
  const _CoverThumbnail({
    required this.assetId,
  });

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox.square(
            dimension: 320,
            child: GalleryThumbnail(
              assetId: assetId,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBarWithCreateAction extends StatelessWidget {
  const _SearchBarWithCreateAction({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onCreate,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Criar nova pasta',
          onPressed: onCreate,
          icon: const Icon(
            Icons.create_new_folder_outlined,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

enum _FolderMenuAction {
  rename,
  delete,
}

class _EmptyFoldersView extends StatelessWidget {
  const _EmptyFoldersView({
    required this.onCreate,
  });

  final VoidCallback onCreate;

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
              Icons.folder_open_rounded,
              size: 58,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhuma pasta ainda',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Crie pastas para organizar suas fotos sem mover os arquivos originais.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreate,
                icon: const Icon(
                  Icons.create_new_folder_outlined,
                ),
                label: const Text('Criar nova pasta'),
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
    final theme = Theme.of(context);

    return Center(
      child: Text(
        'Nenhuma pasta encontrada.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
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
      child: FilledButton(
        onPressed: onRetry,
        child: const Text('Tentar novamente'),
      ),
    );
  }
}
