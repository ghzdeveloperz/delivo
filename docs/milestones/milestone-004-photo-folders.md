# Milestone 004 — Photo Folders

## Funcionalidades

- Implementada organização lógica de fotos em pastas dentro do Delivo.
- Adicionada criação de novas pastas.
- Adicionada renomeação de pastas.
- Adicionada exclusão de pastas.
- Adicionada contagem de fotos por pasta.
- Adicionada navegação da Home para a área de Pastas.
- Integrado o swipe horizontal da triagem à seleção real de pastas.
- Adicionada criação de pasta diretamente durante a triagem.
- Implementada decisão `PhotoDecision.organized`.
- Adicionado desfazer após organizar uma foto.
- Implementada movimentação de fotos entre pastas.
- Implementada remoção de fotos de uma pasta.
- Adicionada opção para devolver fotos organizadas para Não revisadas.
- Adicionada definição de foto como capa da pasta.
- Implementada grid interna das pastas agrupada pela data original das fotos.
- Adicionado preview visual das pastas com mosaico das três fotos mais recentes.
- Adicionado campo de busca de pastas.
- Adicionado botão de criação de pasta integrado ao campo de busca quando já existem pastas.
- Mantido botão horizontal de criação quando ainda não existe nenhuma pasta.
- Adicionadas transições suaves nos resultados da busca.

## Melhorias Técnicas

- Centralizado o acesso ao SQLite através de `AppDatabase`.
- Atualizado o banco `delivo.db` para versão 2.
- Criada migration para suporte às pastas.
- Criada tabela `photo_folders`.
- Adicionado índice para consultas por `folder_id`.
- Criadas entidades `PhotoFolder` e `PhotoFolderItem`.
- Criado contrato `PhotoFolderRepository`.
- Implementado `SqflitePhotoFolderRepository`.
- Criados providers reativos para pastas, detalhes e itens.
- Integrado `PhotoFolderRepository` com o fluxo de triagem.
- Mantida a associação das fotos através de `assetId`.
- Implementado preview das pastas utilizando apenas referências às três fotos mais recentes.
- Mantida separação entre armazenamento de metadados e arquivos físicos da galeria.

## Performance

- Nenhuma imagem é armazenada no SQLite.
- Pastas utilizam apenas `assetId`, metadados e referências lógicas.
- Preview das pastas limitado às três fotos mais recentes.
- Grids construídas com builders e slivers.
- Busca executada localmente sobre a lista já carregada de pastas.
- Evitadas consultas à galeria a cada caractere digitado.
- Adicionados índices SQLite para consultas por pasta e decisão.
- Movimentação entre pastas realizada através de atualização lógica do vínculo.
- Mantido carregamento lazy de thumbnails.
- Evitada movimentação, cópia ou duplicação física das fotografias.

## Refatorações

- Repository de decisões passou a utilizar o banco centralizado do aplicativo.
- Separada a responsabilidade de banco da lógica dos repositories.
- Estruturada a feature `photo_folders` nas camadas data, domain e presentation.
- Substituído placeholder de organização horizontal por fluxo funcional.
- Refatorado card de pasta para suportar mosaico de thumbnails.
- Refatorada tela de Pastas para suportar busca.
- Refatorado seletor da triagem para suportar busca e criação integrada.
- Preparado o fluxo de organização para futuras funcionalidades de gerenciamento de fotos.

## Correções

- Corrigido preview das pastas para preencher corretamente cada célula do mosaico.
- Corrigido uso do aspect ratio original das fotos no preview.
- Corrigida integração dos callbacks da `TriageSwipeCard` após adoção de `Future<bool>`.
- Atualizados testes de swipe para a nova assinatura dos callbacks.
- Corrigido desfazer de uma decisão `organized`.
- Corrigida restauração de fotos de pastas para Não revisadas.
- Corrigida exclusão de pasta para devolver suas fotos sem apagar arquivos físicos.
- Corrigida atualização reativa após criar, renomear, excluir ou alterar uma pasta.
- Corrigida experiência de busca para evitar mudanças visuais abruptas.

## Testes

- Teste de criação de pasta.
- Teste de renomeação de pasta.
- Teste de exclusão de pasta.
- Teste de associação lógica de foto a pasta.
- Teste de remoção de foto da pasta.
- Testes atualizados da `TriageSwipeCard`.
- Validação manual do swipe horizontal.
- Validação manual de criação de pasta durante a triagem.
- Validação manual de mover fotos entre pastas.
- Validação manual de restauração para Não revisadas.
- Validação manual de persistência após reiniciar o aplicativo.
- Validação manual do mosaico de previews.
- Validação manual da busca de pastas.

## Status

Concluída.
