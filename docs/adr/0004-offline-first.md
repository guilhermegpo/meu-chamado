# 0004 — Adotar offline-first

## Status

Aceito.

## Contexto

O uso principal não deve depender de conexão ou conta externa. Sincronização é
opcional e futura, enquanto rotinas locais precisam permanecer disponíveis.

## Decisão

O banco local será a fonte de trabalho. Casos de uso gravam localmente e não
esperam rede. Provedores compartilhados futuros sincronizam uma representação
permitida e versionada.

## Alternativas consideradas

- cloud-first: simplifica compartilhamento, mas bloqueia uso offline e aumenta
  dependência de autenticação;
- cache de uma API remota: ainda mantém o servidor como fonte obrigatória;
- arquivo SQLite em pasta sincronizada: sujeito a corrupção e conflitos sem
  semântica de merge.

## Consequências

Migrações locais, backup e resolução de conflitos tornam-se preocupações
explícitas. O produto precisa comunicar estado de sync no futuro. Testes devem
cobrir operação sem rede antes da integração externa.
