# Changelog

Todas as mudanças relevantes do Delivo serão registradas neste arquivo.

## [Unreleased]

### Milestone 001 — Foundation

#### Added

- Fundação inicial do Delivo.
- Arquitetura feature-first com separação por camadas.
- Design System com tema claro e escuro.
- Tipografia Manrope local.
- Riverpod para estado e injeção de dependência.
- Navegação base.
- Result e falhas tipadas.
- Logging seguro.
- Home inicial.
- Base de testes.

### Milestone 002 — Acesso à Galeria

#### Added

- Acesso real à galeria do dispositivo.
- Fluxo seguro de permissões Android e iOS.
- Suporte a acesso completo e limitado às fotos.
- Paginação incremental da galeria.
- Carregamento otimizado de thumbnails.
- Contagem real de fotos na Home.
- Sincronização automática com alterações externas da galeria.
- Testes do repositório e do fluxo de permissões.

#### Changed

- Home passou a utilizar dados reais da galeria.
- Acesso à galeria foi desacoplado da camada de apresentação.

#### Fixed

- Corrigido tratamento de permissões do `photo_manager`.
- Corrigida atualização após fotos serem adicionadas ou removidas externamente.

### Milestone 003 — Triage

#### Added

- Triagem de fotos uma por vez.
- Swipe para cima para marcar para revisão de exclusão.
- Swipe para baixo para favoritar.
- Swipe horizontal preparado para organização em pastas.
- Threshold, direção dominante e animações de retorno e saída.
- Feedback visual e háptico durante a triagem.
- Persistência local das decisões com SQLite.
- Retomada das decisões após reiniciar o aplicativo.
- Desfazer da última decisão.
- Paginação contínua durante sessões longas.
- Preload e cache limitado de thumbnails.
- Galeria de fotos favoritas.
- Galeria de fotos marcadas para revisão de exclusão.
- Agrupamento das coleções pela data original da foto.
- Restauração de fotos para o estado de não revisadas.
- Contadores reais de favoritas e fotos para revisar.
- Animação suave ao restaurar fotos das coleções.
- Animação de contadores no estilo odômetro por casa decimal.
- Testes de gestures, swipe, repository e undo.

#### Changed

- Home passou a refletir decisões persistidas da triagem.
- Contadores da Home passam a atualizar após o retorno à tela.
- A interação de triagem passou a separar animação e persistência.
- Repository temporário em memória foi substituído por SQLite em produção.

#### Fixed

- Corrigida atualização das grids após restauração.
- Corrigida sincronização dos contadores da Home.
- Corrigido avanço da fotografia antes do fim da animação.
- Corrigidas ações duplicadas durante gestos rápidos.
- Corrigido tratamento de movimentos diagonais.
- Corrigida direção dos gestos verticais.
- Corrigida animação de números com múltiplos dígitos.

### Milestone 004 — Photo Folders

#### Added

- Organização lógica de fotos em pastas.
- Criação, renomeação e exclusão de pastas.
- Seleção de pasta através do swipe horizontal da triagem.
- Criação de pasta durante a própria triagem.
- Persistência de `PhotoDecision.organized`.
- Desfazer após organização.
- Movimentação de fotos entre pastas.
- Restauração de fotos organizadas para Não revisadas.
- Definição de capa da pasta.
- Grid de fotos agrupada por data.
- Preview das pastas com mosaico de até três fotografias.
- Busca por nome de pasta.
- Criação de nova pasta integrada ao campo de busca.
- Migration do banco para versão 2.
- Testes do fluxo de pastas.

#### Changed

- Banco SQLite centralizado através de `AppDatabase`.
- Repository de decisões passou a compartilhar a mesma instância de banco das pastas.
- Swipe horizontal deixou de ser placeholder e passou a executar organização real.
- Cards de pastas passaram a exibir previews fotográficos.
- Tela de Pastas e seletor da triagem passaram a oferecer busca local.

#### Fixed

- Corrigido preenchimento das thumbnails no mosaico das pastas.
- Corrigida restauração de fotos organizadas.
- Corrigido desfazer da decisão `organized`.
- Corrigida exclusão de pasta sem afetar arquivos físicos.
- Corrigidos testes da `TriageSwipeCard` após alteração dos callbacks.
- Corrigida atualização reativa das telas de pastas.
- Suavizada a transição dos resultados durante buscas.
