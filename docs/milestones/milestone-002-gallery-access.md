# Milestone 002 — Acesso à Galeria

## Funcionalidades

- Implementado acesso real à galeria do dispositivo.
- Adicionado fluxo de permissão antes do acesso às fotos.
- Suporte a permissões autorizada, limitada, negada e restrita.
- Implementada tela explicativa de privacidade antes da solicitação nativa.
- Adicionada listagem real de fotos da galeria.
- Implementado carregamento de thumbnails.
- Adicionada paginação incremental de 40 fotos por vez.
- Implementado pull-to-refresh da galeria.
- Adicionada contagem real de fotos acessíveis na Home.
- Implementada sincronização automática quando fotos são adicionadas ou removidas externamente.
- Adicionado suporte ao acesso limitado da galeria.

## Melhorias Técnicas

- Criado contrato `GalleryRepository` desacoplado do plugin nativo.
- Criada abstração `GalleryDataSource` para isolar o `photo_manager`.
- Implementado `PhotoManagerGalleryRepository`.
- Criado `GalleryChangeObserver` para eventos nativos da galeria.
- Centralizada a configuração de permissões Android e iOS.
- Adicionados estados explícitos para loading, ready, empty, permission denied e failure.
- Implementado controller de galeria com Riverpod.
- Adicionado tratamento tipado de falhas.
- Configuradas permissões necessárias no Android e iOS.
- Adicionados testes com fakes e overrides de providers.

## Performance

- Fotos carregadas de forma paginada em lotes de 40.
- Evitado carregamento completo da galeria em memória.
- Thumbnails carregadas em resolução reduzida.
- Utilizado `GridView.builder` para criação lazy dos itens.
- Implementado preload da próxima página próximo ao final do scroll.
- Bloqueadas requisições duplicadas durante paginação.
- Adicionada deduplicação por `assetId`.
- Sincronização baseada em eventos nativos em vez de polling.
- Aplicado debounce de 500 ms em mudanças consecutivas da galeria.

## Refatorações

- Separado acesso nativo da galeria da camada de domínio.
- Movida integração com `photo_manager` para a camada `data`.
- Alterado `homeSummaryProvider` para carregamento assíncrono.
- Preparada arquitetura para testes sem dependência direta de Android ou iOS.
- Centralizado o fluxo de permissão e leitura da galeria no controller.

## Correções

- Corrigido uso obrigatório de `requestOption` no `photo_manager`.
- Corrigido suporte a `GalleryPermission`.
- Corrigido estado de acesso limitado.
- Corrigida atualização da galeria após remoção externa de fotos.
- Corrigida atualização da contagem da Home após mudanças na galeria.
- Corrigidos testes após migração de `Provider` para `FutureProvider`.

## Status

Concluída.
