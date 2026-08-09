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
### Milestone 005 — Favorites

#### Added

- Gerenciamento completo das fotos favoritas.
- Busca por dia, mês e ano.
- Ordenação pela data original da fotografia.
- Ordenação pela data em que a foto foi favoritada.
- Visualização individual das favoritas.
- Zoom em tela cheia.
- Seleção múltipla.
- Seleção através de long press.
- Opção de selecionar todas.
- Remoção individual e em lote dos favoritos.
- Organização de favoritas em pastas.
- Envio de favoritas para revisão de exclusão.
- Confirmação antes de remover o estado protegido de favorita.
- Ações em lote através de transações SQLite.
- Animações suaves durante alterações da coleção.

#### Changed

- Favoritas deixou de funcionar somente como uma grid de consulta.
- Coleção passou a oferecer gerenciamento individual e em lote.
- Operações entre Favoritas, Pastas e Revisão passaram a respeitar o mesmo modelo exclusivo de decisão.
- Visualização de fotos passou a utilizar viewer reutilizável.

#### Fixed

- Corrigida sincronização após remoções em lote.
- Corrigida atualização após organizar favoritas em pastas.
- Corrigida atualização após enviar favoritas para revisão.
- Garantido que uma fotografia não permaneça em dois estados simultaneamente.
- Suavizada a remoção de fotografias da grid.


### Milestone 006 — Deletion Review

#### Added

- Fluxo final de revisão das fotografias marcadas para exclusão.
- Seleção individual e múltipla.
- Seleção de todas as fotografias.
- Estimativa de espaço ocupado pelas fotos marcadas.
- Restauração para Não revisadas.
- Movimentação de fotos marcadas para Favoritas.
- Organização de fotos marcadas em pastas.
- Visualização individual com zoom.
- Exclusão física através da API nativa da galeria.
- Confirmação explícita antes da exclusão.
- Suporte à confirmação adicional do sistema operacional.
- Tratamento de exclusões parciais.
- Resultado detalhado da operação de exclusão.
- Estimativa real de espaço a liberar na Home.
- Cache em memória do tamanho dos assets.
- Abstração `GalleryDeletionGateway`.
- Serviço `DeletionReviewService`.

#### Changed

- Fotos marcadas para exclusão continuam intactas até autorização explícita na revisão.
- Home passou a calcular o espaço estimado a partir dos assets realmente marcados.
- Exclusões locais passaram a depender do resultado confirmado pela camada nativa.
- Operações de revisão passaram a compartilhar infraestrutura de decisões em lote.

#### Fixed

- Corrigido cancelamento da exclusão para preservar os registros locais.
- Corrigido tratamento de exclusão parcial.
- Corrigida remoção local para considerar somente IDs realmente excluídos.
- Corrigida sincronização da Home após exclusões.
- Corrigida tipagem da coleção de decisões no `homeSummaryProvider`.
- Corrigida atualização das coleções após restauração, organização ou favoritação.
- Evitados estados divergentes entre SQLite e galeria física.


### Photo Folders — Management Polish

#### Added

- Busca por data dentro das pastas.
- Ordenação pela data original da foto.
- Ordenação pela data de entrada na pasta.
- Visualização de fotos em tela cheia.
- Zoom.
- Seleção múltipla.
- Long press para seleção.
- Selecionar todas.
- Favoritar fotos diretamente de uma pasta.
- Mover várias fotos entre pastas.
- Enviar várias fotos para revisão.
- Retornar várias fotos para Não revisadas.
- Definição de capa da pasta.
- Indicador visual da foto utilizada como capa.

#### Changed

- Tela interna das pastas passou de grid simples para gerenciamento completo.
- Ações individuais e múltiplas passaram a utilizar o mesmo modelo de decisão das demais coleções.
- Popup individual foi mantido como ação secundária.

#### Fixed

- Corrigida referência de capa quando a fotografia utilizada sai da pasta.
- Corrigida atualização das coleções ao movimentar fotos.
- Corrigida sincronização entre Pastas, Favoritas e Revisão.
- Adicionadas transições suaves ao remover ou mover fotografias.

