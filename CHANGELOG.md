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

- Home agora utiliza dados reais da galeria.
- Acesso à galeria foi desacoplado da camada de apresentação.

#### Fixed

- Corrigido tratamento de permissões do `photo_manager`.
- Corrigida atualização após fotos serem adicionadas ou removidas externamente.
