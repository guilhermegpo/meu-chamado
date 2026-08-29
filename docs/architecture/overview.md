# Visão de arquitetura

## Status

Arquitetura incremental. O scaffold Flutter, o banco local, o onboarding e a
fundação de Workspace/RBAC estão implementados. Integrações externas,
sincronização e módulos especializados permanecem conceituais.

## Objetivos

- funcionar localmente sem autenticação externa;
- permitir evolução opcional para Workspace compartilhado;
- separar infraestrutura genérica de regras específicas de cada chamado;
- centralizar autorização em papéis e permissões verificáveis;
- manter dados privados de chamado fora de provedores compartilhados indevidos;
- crescer por features reais, sem diretórios ou abstrações vazias.

## Camadas conceituais

```text
Apresentação
  └── telas, navegação, temas e acessibilidade

Aplicação
  └── casos de uso, autorização e coordenação de operações

Domínio
  └── Workspace, User, Membership, Role, Calling e CallingModule

Infraestrutura
  └── banco local, armazenamento seguro, backup, sync e atualização
```

As dependências devem apontar para o domínio. Flutter, SQLite ou Google Drive
são detalhes externos e não devem definir as regras de autorização.

## Organização atual

O código deverá crescer no formato feature-first. Uma estrutura possível:

```text
lib/
├── app/
│   └── theme/
├── core/
│   ├── database/
│   └── errors/
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── workspace/
│   ├── callings/
│   ├── ministering/
│   │   ├── domain/
│   │   ├── data/
│   │   ├── application/
│   │   └── presentation/
│   ├── profile/
│   ├── splash/
│   └── settings/
└── shared/
```

Essa árvore não deve ser criada antecipadamente. Cada diretório nasce com código
e testes que justifiquem sua existência.

`features/ministering/` é o primeiro módulo de chamado com implementação real e
serve de referência para os próximos: `domain/` em Dart puro, sem dependência de
Flutter ou de banco; `data/` com o repositório sobre Drift; `application/` com os
provedores Riverpod; `presentation/` com as telas. Toda leitura e escrita é
filtrada por `callingId`, e alcançar registro de outro chamado responde
"registro não encontrado".

## Persistência e sincronização

O banco local é a fonte de trabalho do aplicativo. Um provedor compartilhado
futuro recebe somente dados permitidos e sincronizáveis; não recebe um arquivo
SQLite nem funciona como banco relacional remoto.

```text
StorageProvider
├── LocalStorageProvider
└── GoogleDriveStorageProvider (proposto)
```

## Qualidade

O CI valida formatação, código gerado, análise, testes e build Android debug em
pull requests. Regras de domínio, RBAC e migração de Workspace têm prioridade
sobre testes puramente visuais.
