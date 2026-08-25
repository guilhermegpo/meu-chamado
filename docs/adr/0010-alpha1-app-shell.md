# 0010 — Fechar o app shell da primeira alpha

## Status

Aceito para a `0.1.0-alpha.1`, que permanece em desenvolvimento.

## Contexto

A primeira alpha precisa validar o uso local completo antes de adicionar
sincronização ou módulos especializados. O fluxo ainda é curto, mas a
persistência, a autorização e a evolução do schema precisam ser explícitas e
testáveis.

## Decisão

- manter o `Navigator` padrão do Flutter para splash, onboarding, seleção de
  usuário, home, perfis, chamados e configurações;
- usar um Workspace `LOCAL` como limite de dados da alpha;
- persistir usuários, chamados, referência da foto local e preferência de tema
  com Drift; copiar a imagem escolhida para o diretório do aplicativo e evoluir
  o schema por migrações versionadas;
- centralizar permissões de `ADMIN`, `MODERATOR` e `USER` abaixo da interface,
  negar operações não autorizadas por padrão e preservar ao menos um
  administrador;
- identificar os tipos do catálogo por chaves estáveis e representar o ciclo de
  vida do chamado por `ACTIVE` e `ARCHIVED`;
- mostrar os módulos especializados como **Em desenvolvimento**, sem simular
  rotinas ainda inexistentes.

## Consequências

O `Navigator` evita uma dependência de roteamento sem requisito atual. A decisão
deve ser revista quando deep links, restauração complexa ou navegação aninhada
trouxerem benefício verificável.

Mudanças de schema exigem migração e testes. A foto continua local e não implica
backup ou sincronização. RBAC precisa ser aplicado nos casos de uso, não apenas
na visibilidade dos controles. Google Drive, atualizador e distribuição não
fazem parte desta decisão.

Esta decisão complementa os ADRs
[0002](0002-workspace-model.md), [0003](0003-rbac.md),
[0004](0004-offline-first.md), [0008](0008-modular-calling-architecture.md) e
[0009](0009-flutter-foundation-dependencies.md).
