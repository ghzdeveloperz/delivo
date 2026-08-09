# Milestone 007 — Home Redesign, Theme System e Identidade Visual

## Milestone

- Evoluída a Home do Delivo para uma interface mais premium, editorial e consistente.
- Criada identidade visual própria com background Aurora Smoke animado.
- Implementado suporte real a tema claro e escuro.
- Adicionado controle visual de alternância de tema no header.
- Adicionada logo SVG da marca ao lado do nome Delivo.
- Refinada a hierarquia dos cards, progresso e organização da Home.
- Preparado suporte ao ícone oficial do aplicativo para Android e iOS.

## Funcionalidades

- Adicionado switch de tema Light/Dark no header.
- Aplicativo inicia respeitando `ThemeMode.system`.
- Estado visual do switch acompanha o tema efetivo atual.
- Permitida alternância manual entre tema claro e escuro.
- Adicionado background Aurora Smoke animado.
- Aurora adaptada para Light e Dark Mode.
- Mantido grid pontilhado decorativo no background.
- Adicionado progresso real da galeria.
- Exibido percentual de progresso da triagem.
- Percentuais inferiores a 1% exibem `<1%`.
- Exibido total de fotos revisadas em relação ao total da galeria.
- Adicionada logo SVG oficial no header.
- Adicionado preview visual das pastas na Home.
- Exibida quantidade de pastas criadas.
- Mantidos acessos para Favoritas, Para revisar, Pastas e Triagem.
- Removido acesso duplicado para revisão de exclusão.
- Configurado suporte ao launcher icon para Android e iOS.

## Melhorias Técnicas

- Criado `themeModeProvider` com Riverpod.
- `DelivoApp` convertido para `ConsumerWidget`.
- Centralizado o controle de `ThemeMode`.
- Mantido suporte a `ThemeMode.system`.
- Tornado `DelivoAuroraBackground` sensível ao tema atual.
- Criadas variações específicas de background, grid, vignette, glass, bordas, sombras e contraste.
- `HomeSummary` expandido com:
  - `totalPhotoCount`;
  - `reviewedCount`;
  - `progress`;
  - `progressPercent`.
- Progresso baseado nos dados reais da galeria.
- Adicionado suporte a SVG com `flutter_svg`.
- Adicionado suporte a geração de launcher icon com `flutter_launcher_icons`.
- Organizados assets de marca em:
  - `assets/icons/brand/`;
  - `assets/icons/app/`.

## Performance

- Mantido `RepaintBoundary` no background Aurora.
- Grid e camada animada permanecem separados.
- Aurora utiliza um único `AnimationController`.
- Respeitado `MediaQuery.disableAnimations`.
- Reduzida intensidade de blur nos cards.
- Mantido carregamento limitado dos previews das pastas.
- Preservado refresh atrasado de 650 ms ao retornar das telas.
- Preservada animação de odômetro por dígito.

## Refatorações

- Reorganizada a hierarquia visual da Home.
- Header reduzido e simplificado.
- CTA de triagem compactado.
- Painel de progresso reduzido.
- Card `Não revisadas` transformado em destaque principal.
- Cards `Favoritas` e `Para revisar` mantidos lado a lado.
- Card `Espaço estimado` compactado.
- Removido container externo dos cards de estatísticas.
- Liquid Glass refinado.
- Ícones padronizados.
- Seção Pastas ganhou maior destaque.
- Logo e nome Delivo passaram a formar um único bloco visual no header.

## Correções

- Corrigida Home que permanecia visualmente escura no Light Mode.
- Corrigidos textos brancos hardcoded.
- Corrigidas superfícies e bordas do Liquid Glass no tema claro.
- Corrigido contraste do painel de progresso.
- Corrigido contraste dos cards de estatísticas.
- Corrigido contraste da seção Pastas.
- Corrigida Aurora para reagir corretamente ao tema atual.
- Corrigida baixa intensidade da Aurora no Light Mode.
- Corrigido percentual exibindo `0%` mesmo com progresso existente.
- Corrigidos testes após inclusão de `totalPhotoCount` e `reviewedCount`.
- Corrigido erro de build causado pela ausência temporária de `home_page.dart`.

## Status

Concluído.
