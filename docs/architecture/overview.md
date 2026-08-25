# Visão de arquitetura

## Status

Arquitetura conceitual. O scaffold Flutter ainda não foi criado e nenhum bloco
descrito aqui deve ser interpretado como implementado.

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

## Organização prevista

O código deverá crescer no formato feature-first. Uma estrutura possível:

```text
lib/
├── app/
├── core/
│   ├── database/
│   ├── routing/
│   ├── security/
│   ├── storage/
│   └── theme/
├── features/
│   ├── onboarding/
│   ├── workspace/
│   ├── users/
│   ├── callings/
│   └── settings/
└── shared/
```

Essa árvore não deve ser criada antecipadamente. Cada diretório nasce com código
e testes que justifiquem sua existência.

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

O primeiro CI real deverá validar formatação, análise, testes e um build Android
compatível com o estágio. Regras de domínio, RBAC e migração de Workspace têm
prioridade sobre testes puramente visuais.
