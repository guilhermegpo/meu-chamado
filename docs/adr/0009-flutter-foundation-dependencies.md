# 0009 — Dependências da fundação Flutter

## Status

Aceito para a série `0.1.x`.

## Contexto

A fundação precisa persistir dados offline, carregar o estado antes de decidir
entre onboarding e aplicativo, e permanecer testável sem serviços externos.
Adicionar roteamento declarativo ou armazenamento seguro antes de existirem
rotas profundas e credenciais criaria dependências sem uso real.

## Decisão

- usar Drift sobre SQLite para schema tipado, transações e testes em memória;
- usar Riverpod para injeção do banco/repositório e estado assíncrono do bootstrap;
- manter `Navigator` do Flutter enquanto o fluxo possui somente onboarding,
  seleção, home e configurações;
- adiar armazenamento seguro até existir um dado que deva ser protegido por ele.

Versões iniciais verificadas: Riverpod `3.4.2`, Drift `2.34.3`,
`drift_flutter` `0.3.1` e `drift_dev` `2.34.5`.

## Alternativas consideradas

- SQLite manual: reduz uma dependência, mas transfere geração de SQL, mapping e
  migrações para código manual mais sujeito a erro;
- estado somente em widgets: suficiente para uma tela isolada, mas dificulta
  substituir persistência por banco em memória nos testes;
- `go_router`: estável e adequado a navegação maior, porém prematuro para o fluxo
  atual;
- `flutter_secure_storage`: apropriado para tokens e pequenos segredos, mas não
  substitui o banco e ainda não há credenciais no produto.

## Consequências

O schema gera código que deve permanecer sincronizado e validado no CI.
Riverpod adiciona um conceito de providers, limitado neste marco à composição e
ao bootstrap. Roteamento e armazenamento seguro deverão ser reavaliados quando
aparecerem requisitos concretos, sem compromisso de adotá-los automaticamente.
