# Delivo — Architecture Skeleton

Extraia o conteúdo deste ZIP diretamente na raiz do projeto Flutter `delivo/`.

A estrutura segue uma abordagem feature-first com separação por camadas:

- `presentation`: UI, controllers/notifiers e estado de tela.
- `domain`: entidades, contratos, regras e casos de uso.
- `data`: implementações de repositórios, datasources, plugins e persistência.

## Estrutura principal

```text
lib/
  app/
    router/
    theme/

  core/
    errors/
    logging/
    permissions/
    result/
    utils/
    widgets/

  features/
    onboarding/
      data/
      domain/
      presentation/

    gallery_access/
      data/
      domain/
      presentation/

    triage/
      data/
      domain/
      presentation/

    photo_folders/
      data/
      domain/
      presentation/

    favorites/
      data/
      domain/
      presentation/

    deletion_review/
      data/
      domain/
      presentation/

    settings/
      data/
      domain/
      presentation/

test/
  core/
  features/

integration_test/
```

Os arquivos `.gitkeep` existem apenas para permitir que o Git preserve as pastas vazias.
Eles poderão ser removidos automaticamente conforme arquivos Dart reais forem adicionados.
