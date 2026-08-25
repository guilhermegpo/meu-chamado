# 0002 — Modelar o contexto por Workspace

## Status

Aceito.

## Contexto

O aplicativo precisa funcionar para uma pessoa localmente e, no futuro, para
várias pessoas compartilharem uma configuração. Usuários podem ter papéis
diferentes em contextos diferentes.

## Decisão

Usar `Workspace` como limite de dados e autorização, com tipos `LOCAL` e
`SHARED`. O primeiro usuário de um Workspace local é `ADMIN`. A conversão para
compartilhado será uma migração explícita e sem perda silenciosa.

## Alternativas consideradas

- um único banco global sem contexto: simplifica o início, mas mistura dados e
  inviabiliza autorização por ambiente;
- exigir conta e Workspace compartilhado desde o onboarding: cria dependência
  externa desnecessária para uso individual;
- manter aplicativos separados para modos local e compartilhado: duplica regras
  e dificulta migração.

## Consequências

Entidades e consultas relevantes carregam contexto de Workspace. Testes precisam
provar isolamento. Sync futuro opera sobre dados permitidos de um Workspace e
não sobre todo o banco local.
