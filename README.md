# Meu Chamado

Aplicativo mobile modular para organização e acompanhamento de chamados, com
suporte a múltiplos usuários e chamados.

> [!IMPORTANT]
> Meu Chamado é um projeto independente e não oficial. Não é afiliado,
> endossado ou patrocinado por A Igreja de Jesus Cristo dos Santos dos Últimos
> Dias.

## Status

**Fundação do produto em desenvolvimento (`0.1.0-alpha.1`).** O aplicativo
Flutter já inicia, persiste um Workspace local, cria o primeiro usuário como
`ADMIN`, oferece seleção de perfil e temas claro/escuro, e modela zero, um ou
vários chamados.

Ainda não existem Google Drive, módulos completos de chamado, distribuição ou
atualização automática. Itens do roadmap não devem ser interpretados como
funcionalidades entregues.

## Problema e objetivo

Pessoas podem acumular responsabilidades com rotinas e limites de acesso
distintos. Planilhas, papel e mensagens fragmentam esse acompanhamento.

O projeto busca oferecer uma base Android offline-first para organizar
Workspaces, usuários e chamados. O modo local funciona sem conta externa; o
compartilhamento futuro será opcional e projetado com privilégio mínimo.

## O que a fundação implementa

- aplicativo Flutter com Material 3 e identidade visual original da família
  Apps Meu;
- temas claro, escuro e preferência do sistema;
- onboarding para um Workspace `LOCAL`;
- persistência SQLite local com Drift;
- primeiro usuário criado como `ADMIN`;
- proteção de domínio contra remoção do último administrador;
- seleção de usuário e estrutura para foto de perfil local;
- estrutura persistente para múltiplos chamados `ACTIVE` ou `ARCHIVED`;
- estado assíncrono com Riverpod;
- testes de repositório e onboarding.

Foto de perfil, criação de usuários pela interface, gestão de chamados e
persistência da preferência de tema continuam incrementos futuros da série
`0.1.x`.

## Stack

- Flutter `3.47.1` e Dart `3.13.1`;
- Riverpod `3.4.2` para estado e injeção de dependências;
- Drift `2.34.x` sobre SQLite para persistência offline;
- Android como primeira plataforma.

As escolhas e seus trade-offs estão documentados em
[docs/adr/0009-flutter-foundation-dependencies.md](docs/adr/0009-flutter-foundation-dependencies.md).

## Modelo de domínio

```text
Workspace
User
Membership
Role
Calling
CallingModule
```

Workspaces podem ser `LOCAL` ou `SHARED`. Papéis previstos: `ADMIN`, `MODERATOR`
e `USER`. As regras completas estão em
[docs/product/domain-model.md](docs/product/domain-model.md).

## Como executar

Pré-requisitos: Flutter `3.47.1`, uma plataforma Flutter configurada e as
ferramentas indicadas por `flutter doctor -v`.

```bash
flutter pub get
dart run build_runner build
flutter run
```

Nenhum secret, conta Google ou serviço externo é necessário para a fundação
local.

## Testes e qualidade

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

O CI executa essas validações em pull requests para `main` e `develop`. O build
Android local requer o Android SDK; a análise e os testes de unidade/widget
podem ser executados sem dispositivo.

## Privacidade e segurança

Dados compartilháveis do Workspace e dados privados de chamado são limites
diferentes. Dados reais de membros, credenciais, tokens, keystore, pastas reais
do Drive e bancos locais nunca devem entrar neste repositório.

Somente dados fictícios podem aparecer em código, testes ou screenshots, como
`Administrador Demo` e `Usuário Demo`.

Veja [docs/privacy/data-boundaries.md](docs/privacy/data-boundaries.md) e
[docs/security/threat-model.md](docs/security/threat-model.md).

## Arquitetura e roadmap

- [Visão de arquitetura](docs/architecture/overview.md)
- [ADRs](docs/adr/)
- [Identidade visual](docs/design/identity.md)
- [Roadmap](ROADMAP.md)

Os ADRs distinguem decisões aceitas de propostas futuras. Uma decisão
documentada não significa que toda a funcionalidade relacionada já foi
implementada.

## Contribuição, licença e marca

As políticas padrão de contribuição, código de conduta e segurança são herdadas
do repositório público
[`guilhermegpo/.github`](https://github.com/guilhermegpo/.github).

O código é disponibilizado sob a [licença MIT](LICENSE). A licença do código
não concede automaticamente direitos sobre o nome, a identidade visual ou
ativos de marca. Consulte [BRAND.md](BRAND.md).
