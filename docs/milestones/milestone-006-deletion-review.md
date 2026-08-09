# Milestone 006 — Deletion Review

## Funcionalidades

- Implementada revisão final das fotos marcadas para exclusão.
- Mantida separação entre marcação para revisão e exclusão física.
- Adicionado resumo da quantidade de fotos em revisão.
- Adicionada estimativa de espaço ocupado pelas fotos marcadas.
- Adicionada visualização das fotos agrupadas pela data original.
- Adicionado modo de seleção múltipla.
- Adicionado long press para iniciar seleção.
- Adicionada opção para selecionar todas as fotografias.
- Adicionada restauração individual e em lote para Não revisadas.
- Adicionada transformação individual e em lote em favoritas.
- Adicionada organização individual e em lote em pastas.
- Adicionada visualização individual em tela cheia.
- Adicionado zoom da fotografia.
- Implementada exclusão física somente na etapa de revisão final.
- Adicionada confirmação explícita do Delivo antes da exclusão.
- Integrada confirmação nativa fornecida pelo sistema operacional.
- Adicionado tratamento de exclusão parcial.
- Adicionado tratamento de cancelamento ou falha na operação nativa.
- Adicionado resumo do resultado após tentativa de exclusão.
- Mantidas fotos não excluídas na fila de revisão.
- Atualizada estimativa de espaço da Home com dados reais das fotos marcadas.

## Melhorias Técnicas

- Criada abstração `GalleryDeletionGateway`.
- Implementada integração nativa através do `photo_manager`.
- Criado `DeletionReviewService` para centralizar o fluxo de exclusão.
- Criado resultado tipado para operações de exclusão em lote.
- Separada exclusão física da manipulação dos registros locais.
- Implementado processamento apenas dos IDs confirmados como excluídos.
- Adicionado serviço para cálculo de tamanho dos assets.
- Adicionado cache em memória dos tamanhos já consultados.
- Integrado serviço de métricas ao resumo da Home.
- Mantido SQLite como fonte de verdade das decisões locais.
- Preservada a arquitetura offline-first.
- Mantida a ausência de uploads ou processamento remoto das fotos.

## Performance

- Tamanho dos arquivos calculado somente quando necessário.
- Implementado cache de tamanho por `assetId`.
- Leitura de métricas executada em pequenos lotes.
- IDs duplicados são removidos antes do cálculo.
- Nenhum conteúdo binário das fotografias é persistido no SQLite.
- Grid continua utilizando construção lazy.
- Somente registros efetivamente excluídos são removidos do banco.
- Evitada reconstrução completa da aplicação durante operações de revisão.

## Segurança e Privacidade

- Nenhuma foto é excluída diretamente durante a triagem.
- Swipe para cima continua apenas marcando a foto para revisão.
- Exclusão física é disponibilizada exclusivamente na tela de revisão.
- Usuário recebe confirmação explícita antes da exclusão.
- Sistema operacional pode solicitar confirmação adicional.
- Cancelamentos não são interpretados como exclusões concluídas.
- Exclusões parciais mantêm os itens restantes na revisão.
- Nenhum caminho local sensível é armazenado ou exibido.
- Nenhuma fotografia é enviada para servidores externos.

## Refatorações

- Separada a integração nativa de exclusão da camada de apresentação.
- Criado gateway para facilitar testes e futuras implementações específicas de plataforma.
- Centralizado o fluxo de exclusão no `DeletionReviewService`.
- Reutilizado o serviço de decisões em lote.
- Reutilizado o visualizador em tela cheia.
- Padronizada seleção múltipla com Favoritas e Pastas.
- Integrada estimativa real de espaço ao `HomeSummary`.

## Correções

- Garantido que cancelar a exclusão nativa não remova a decisão local.
- Garantido que apenas IDs realmente excluídos sejam removidos do SQLite.
- Corrigido comportamento em exclusões parciais.
- Garantida permanência das fotos que não puderam ser excluídas.
- Corrigida sincronização entre revisão e Home após exclusões.
- Corrigido cálculo tipado da coleção de fotos marcadas no resumo da Home.
- Corrigida atualização das coleções ao restaurar, favoritar ou organizar fotos.
- Evitados estados inconsistentes entre galeria física e banco local.

## Testes

- Testado contrato de exclusão parcial.
- Testado cenário de falha na operação nativa.
- Validada restauração para Não revisadas.
- Validada movimentação para Favoritas.
- Validada organização em pasta.
- Validada seleção múltipla.
- Validada seleção de todas as fotografias.
- Validado cancelamento da confirmação de exclusão.
- Validada exclusão física após confirmação.
- Validada permanência dos itens não excluídos.
- Validada atualização do contador da Home.
- Validada atualização da estimativa de espaço após exclusões.

## Status

Concluída.
