# Milestone 003 — Triage

## Funcionalidades

- Implementada triagem de fotografias uma por vez.
- Adicionado gesto para cima para marcar uma foto para revisão de exclusão.
- Adicionado gesto para baixo para favoritar e manter uma foto.
- Adicionado gesto horizontal preparado para organização em pastas.
- Adicionados botões equivalentes aos gestos para acessibilidade e uso alternativo.
- Implementado desfazer da última decisão.
- Implementada persistência local das decisões em SQLite.
- Adicionada retomada das decisões após fechar e reabrir o aplicativo.
- Implementadas galerias específicas para fotos favoritas e fotos marcadas para revisão.
- Adicionado agrupamento das coleções pela data original da fotografia.
- Adicionada restauração de fotos favoritas ou marcadas para exclusão para o estado de não revisadas.
- Home integrada às contagens reais de fotos não revisadas, favoritas e marcadas para revisão.
- Adicionadas animações numéricas nos contadores da Home no estilo odômetro por casa decimal.
- Adicionada animação suave ao remover itens das grids de Favoritas e Para revisar.

## Melhorias Técnicas

- Criado domínio de decisões através de `PhotoDecision`.
- Criado histórico de decisões com `PhotoDecisionRecord`.
- Criado contrato `PhotoDecisionRepository`.
- Implementado `SqflitePhotoDecisionRepository`.
- Mantido `InMemoryPhotoDecisionRepository` para testes isolados.
- Criado resolver independente para interpretação dos gestos.
- Separada a persistência da animação de saída da fotografia.
- Adicionado stream de revisão para sincronização das coleções.
- Criadas rotas específicas para Favoritas e Para revisar.
- Implementado cache controlado de thumbnails da triagem.
- Adicionado preload das próximas fotografias.
- Implementada paginação contínua durante a triagem.

## Performance

- Carregamento das fotos realizado de forma incremental.
- Evitado carregamento completo de milhares de fotografias na memória.
- Pré-carregadas apenas a foto atual e uma pequena janela de próximas fotos.
- Cache de thumbnails limitado para evitar crescimento indefinido da memória.
- Lista interna da triagem compactada durante sessões longas.
- Utilizado `RepaintBoundary` na área animada da fotografia.
- Eventos persistidos no SQLite sem armazenamento dos bytes das imagens.
- Home deixa de recalcular os contadores continuamente durante a triagem.
- Contadores são atualizados apenas após o retorno à Home.
- Alterações visuais limitadas às casas decimais realmente modificadas.

## Refatorações

- Substituída persistência temporária em memória por SQLite na implementação de produção.
- Desacoplada lógica de gesto da camada de apresentação.
- Separado o componente visual de swipe da lógica de decisão.
- Centralizado o estado da triagem no `TriageController`.
- Criado componente reutilizável para coleções de decisões.
- Refatorados cards da Home para suportar navegação e contadores animados.
- Preparada a ação horizontal para integração com Photo Folders na próxima milestone.

## Correções

- Corrigida direção dos gestos verticais para melhorar ergonomia:
  - para cima marca para revisão de exclusão;
  - para baixo favorita a foto.
- Corrigida atualização das grids após restaurar uma fotografia.
- Corrigida sincronização dos contadores da Home após retornar de outras telas.
- Corrigida persistência das decisões entre reinicializações do aplicativo.
- Corrigida troca prematura de fotografia antes do término da animação.
- Corrigida duplicidade de ações durante persistência ou animação.
- Corrigido comportamento de gestos diagonais ambíguos.
- Corrigida animação dos contadores para alterar apenas unidade, dezena, centena ou demais casas necessárias.

## Testes

- Testes unitários do repositório de decisões.
- Testes do resolver de gestos.
- Testes de swipe vertical e horizontal.
- Teste de cancelamento abaixo do threshold.
- Teste de desfazer e restauração da decisão anterior.
- Testes de persistência e filtragem das decisões.

## Status

Concluída.
