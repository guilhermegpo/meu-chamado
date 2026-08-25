# Meu Chamado

Aplicativo mobile modular para organização e acompanhamento de chamados, com
suporte a múltiplos usuários e chamados.

> [!IMPORTANT]
> Meu Chamado é um projeto independente e não oficial. Não é afiliado,
> endossado ou patrocinado por A Igreja de Jesus Cristo dos Santos dos Últimos
> Dias.

## Status

**Fundação do produto.** O repositório contém decisões de arquitetura,
privacidade, segurança, identidade e roadmap. O aplicativo Flutter e suas
funcionalidades ainda não estão implementados.

Primeiro marco planejado: `0.1.0-alpha.1`.

## Problema

Pessoas podem acumular diferentes chamados e responsabilidades, cada um com
rotinas, informações e limites de acesso próprios. Planilhas, papel e mensagens
fragmentam esse acompanhamento e não oferecem um modelo consistente para uso
individual ou compartilhado.

## Objetivo

Construir um aplicativo Android offline-first que organize usuários, chamados e
rotinas dentro de um Workspace. O modo local deve funcionar sem conta externa;
o compartilhamento será opcional e projetado com privilégio mínimo.

## Escopo inicial

O marco `0.1.0-alpha.1` pretende entregar somente a fundação:

- inicialização do aplicativo;
- temas claro e escuro;
- onboarding;
- criação de Workspace local;
- primeiro usuário como `ADMIN`;
- seleção e foto de perfil;
- RBAC básico;
- estrutura para zero, um ou vários chamados;
- configurações essenciais.

Google Drive, módulos completos de chamado e atualização pelo GitHub Releases
permanecem planejados; não são funcionalidades atuais.

## Tecnologia planejada

- Flutter e Dart;
- Android como primeira plataforma;
- arquitetura preparada para avaliar iOS futuramente;
- banco local SQLite por meio de uma biblioteca a decidir;
- roteamento, estado e armazenamento seguro definidos após avaliação técnica.

Versões e dependências só serão registradas quando o scaffold Flutter existir.

## Modelo de domínio

```text
Workspace
User
Membership
Role
Calling
CallingModule
```

Workspaces poderão ser `LOCAL` ou `SHARED`. Papéis previstos: `ADMIN`,
`MODERATOR` e `USER`. As regras completas estão em
[docs/product/domain-model.md](docs/product/domain-model.md).

## Privacidade

Dados compartilháveis do Workspace e dados privados de chamado são limites
diferentes. Dados reais de membros, credenciais, tokens, keystore, pastas reais
do Drive e bancos locais nunca devem entrar neste repositório.

Veja [docs/privacy/data-boundaries.md](docs/privacy/data-boundaries.md) e
[docs/security/threat-model.md](docs/security/threat-model.md).

## Arquitetura e decisões

- [Visão de arquitetura](docs/architecture/overview.md)
- [ADRs](docs/adr/)
- [Identidade visual](docs/design/identity.md)
- [Roadmap](ROADMAP.md)

Os ADRs distinguem decisões aceitas de propostas futuras. Um documento não
significa que a funcionalidade já foi implementada.

## Como executar

Ainda não há aplicativo executável. Esta seção será atualizada junto com o
primeiro scaffold Flutter verificável.

## Testes e CI

Ainda não há código Flutter para analisar ou testar. Quando o scaffold existir,
o CI de pull requests deverá executar formatação, análise estática, testes e
build Android apropriado ao estágio do projeto.

## Dados de demonstração

Somente dados fictícios podem ser usados em código, documentação, screenshots e
testes, por exemplo: `Administrador Demo`, `Usuário Demo`, `João Exemplo` e
`Maria Exemplo`.

## Contribuição e segurança

As políticas padrão de contribuição, código de conduta e segurança são herdadas
do repositório público [`guilhermegpo/.github`](https://github.com/guilhermegpo/.github).

## Licença e marca

O código é disponibilizado sob a [licença MIT](LICENSE). A licença do código não
concede automaticamente direitos sobre o nome, a identidade visual ou ativos de
marca. Consulte [BRAND.md](BRAND.md).
