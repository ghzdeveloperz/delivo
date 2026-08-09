import 'package:delivo/app/theme/app_spacing.dart';
import 'package:delivo/features/photo_folders/domain/entities/photo_folder.dart';
import 'package:delivo/features/photo_folders/presentation/providers/photo_folder_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoFolderPickerSheet extends ConsumerStatefulWidget {
  const PhotoFolderPickerSheet({
    super.key,
  });

  static Future<PhotoFolder?> show(BuildContext context) {
    return showModalBottomSheet<PhotoFolder>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const PhotoFolderPickerSheet(),
    );
  }

  @override
  ConsumerState<PhotoFolderPickerSheet> createState() =>
      _PhotoFolderPickerSheetState();
}

class _PhotoFolderPickerSheetState
    extends ConsumerState<PhotoFolderPickerSheet> {
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
    final theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organizar em pasta',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A foto continua na galeria original. O Delivo salva apenas a organização.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            foldersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (folders) {
                if (folders.isEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _createFolder(
                        context,
                        ref,
                      ),
                      icon: const Icon(
                        Icons.create_new_folder_outlined,
                      ),
                      label: const Text('Criar nova pasta'),
                    ),
                  );
                }

                return _SearchBarWithCreateAction(
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
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: foldersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Não foi possível carregar suas pastas.',
                  ),
                ),
                data: (folders) {
                  if (folders.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma pasta criada ainda.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final filtered = _filterFolders(
                    folders,
                    _query,
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: filtered.isEmpty
                        ? _NoSearchResults(
                            key: ValueKey<String>(
                              'empty-${_query.trim().toLowerCase()}',
                            ),
                          )
                        : _FolderList(
                            key: ValueKey<String>(
                              'list-${_query.trim().toLowerCase()}-${filtered.length}',
                            ),
                            folders: filtered,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
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
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nova pasta'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Ex.: Viagem, Família, Trabalho',
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value);
            },
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
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null ||
        name.trim().isEmpty ||
        !context.mounted) {
      return;
    }

    final result = await ref
        .read(photoFolderRepositoryProvider)
        .createFolder(name);

    final folder = result.fold<PhotoFolder?>(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    if (!context.mounted) {
      return;
    }

    if (folder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível criar a pasta. Verifique se o nome já existe.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(folder);
  }
}

class _FolderList extends StatelessWidget {
  const _FolderList({
    required this.folders,
    super.key,
  });

  final List<PhotoFolder> folders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: folders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final folder = folders[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.folder_rounded,
          ),
          title: Text(folder.name),
          subtitle: Text(
            '${folder.photoCount} ${folder.photoCount == 1 ? 'foto' : 'fotos'}',
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
          ),
          onTap: () => Navigator.of(context).pop(folder),
        );
      },
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
