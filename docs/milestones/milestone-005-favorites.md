# Milestone 005 — Favorites

## Funcionalidades

- Evoluída a área de fotos favoritas para gerenciamento completo.
- Mantido o estado exclusivo `PhotoDecision.favorite`.
- Adicionada visualização das favoritas agrupadas pela data original da foto.
- Adicionado campo de busca por dia, mês e ano.
- Adicionada ordenação por fotos mais recentes.
- Adicionada ordenação por fotos mais antigas.
- Adicionada ordenação pela data em que a foto foi favoritada.
- Adicionada visualização individual da fotografia.
- Adicionado zoom na visualização individual.
- Adicionado modo de seleção múltipla.
- Adicionado início da seleção através de long press.
- Adicionada opção para selecionar todas as favoritas.
- Adicionada remoção individual e em lote dos favoritos.
- Adicionada organização individual e em lote em pastas.
- Adicionada movimentação de favoritas para revisão de exclusão.
- Adicionada confirmação antes de transformar uma favorita em foto marcada para revisão.
- Integrado o seletor de pastas existente ao fluxo de favoritas.
- Adicionadas animações suaves ao remover fotos da coleção.

## Melhorias Técnicas

- Criado serviço reutilizável para alterações de decisões em lote.
- Implementadas operações transacionais para múltiplas decisões no SQLite.
- Criado serviço compartilhado para filtragem e ordenação das coleções.
- Mantido `assetId` como referência única das fotografias.
- Mantida a separação entre metadados locais e arquivos físicos da galeria.
- Integrada a feature de Favoritas com Pastas e Revisão de Exclusão.
- Adicionado visualizador reutilizável de fotografias em tela cheia.
- Mantida a arquitetura feature-first existente.
- Preservado o modelo de decisão exclusiva do Delivo.

## Performance

- Busca realizada somente sobre registros já carregados.
- Nenhuma consulta à galeria é executada por caractere digitado.
- Ações em lote são executadas dentro de transações SQLite.
- Grid construída de forma lazy.
- Thumbnails continuam sendo carregadas sob demanda.
- Nenhuma fotografia é copiada ou armazenada pelo Delivo.
- Reaproveitado o cache existente de thumbnails da galeria.
- Animações limitadas aos itens afetados pela operação.

## Refatorações

- Extraída lógica compartilhada para alterações de decisão em lote.
- Extraída lógica de filtro e ordenação das coleções.
- Criado visualizador de fotos reutilizável pelas diferentes features.
- Tela de Favoritas deixou de ser somente uma coleção passiva.
- Integradas ações individuais e múltiplas ao mesmo fluxo de domínio.
- Padronizada a experiência de seleção com as demais áreas do aplicativo.

## Correções

- Garantido que uma foto não permaneça simultaneamente como favorita e organizada.
- Garantido que uma foto enviada para revisão deixe de ser favorita.
- Garantida restauração correta para `unreviewed` ao desfavoritar.
- Corrigida sincronização das coleções após alterações em lote.
- Corrigida atualização da lista após movimentação para uma pasta.
- Corrigida atualização da coleção de revisão após transferência de uma favorita.
- Evitadas mudanças abruptas na grid durante remoções.

## Testes

- Testado filtro por mês e ano.
- Testada ordenação pela data original da fotografia.
- Validada seleção múltipla.
- Validada seleção de todas as favoritas.
- Validada remoção em lote.
- Validada organização em pasta.
- Validada movimentação para revisão.
- Validada visualização individual.
- Validado zoom.
- Validada persistência das alterações após reiniciar o aplicativo.

## Status

Concluída.
