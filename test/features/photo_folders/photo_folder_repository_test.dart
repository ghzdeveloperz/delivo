import 'package:flutter_test/flutter_test.dart';

import 'in_memory_photo_folder_repository.dart';

void main() {
  test('creates renames and deletes a logical folder', () async {
    final repository =
        InMemoryPhotoFolderRepository();

    final created =
        await repository.createFolder('Viagem');

    final folder = created.fold(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    );

    expect(folder, isNotNull);
    expect(folder!.name, 'Viagem');

    await repository.renameFolder(
      folderId: folder.id,
      name: 'Viagens',
    );

    final renamed =
        await repository.getFolder(folder.id);

    expect(
      renamed.fold(
        onSuccess: (value) => value?.name,
        onFailure: (_) => null,
      ),
      'Viagens',
    );

    await repository.deleteFolder(folder.id);

    final removed =
        await repository.getFolder(folder.id);

    expect(
      removed.fold(
        onSuccess: (value) => value,
        onFailure: (_) => Object(),
      ),
      isNull,
    );

    await repository.close();
  });

  test('moves and removes photo without touching gallery file', () async {
    final repository =
        InMemoryPhotoFolderRepository();

    final created =
        await repository.createFolder('Trabalho');

    final folder = created.fold(
      onSuccess: (value) => value,
      onFailure: (_) => null,
    )!;

    await repository.movePhoto(
      assetId: 'asset-1',
      folderId: folder.id,
      assetCreatedAt: DateTime(2026, 8, 8),
    );

    final items =
        await repository.getItems(folder.id);

    expect(
      items.fold(
        onSuccess: (value) => value.single.assetId,
        onFailure: (_) => '',
      ),
      'asset-1',
    );

    await repository.removePhoto('asset-1');

    final empty =
        await repository.getItems(folder.id);

    expect(
      empty.fold(
        onSuccess: (value) => value,
        onFailure: (_) => <Object>[],
      ),
      isEmpty,
    );

    await repository.close();
  });
}
