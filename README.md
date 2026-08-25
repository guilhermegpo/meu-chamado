# Meu Chamado

Aplicativo Android offline-first para organizar usuários e chamados em um
Workspace local, com uma base modular para evoluções futuras.

> [!IMPORTANT]
> Meu Chamado é um projeto independente e não oficial. Não é afiliado,
> endossado ou patrocinado por A Igreja de Jesus Cristo dos Santos dos Últimos
> Dias.

## Status

**`0.1.0-alpha.1` — Em desenvolvimento.** O app shell desta versão está sendo
validado localmente e no CI. Ele reúne a experiência inicial, a persistência e
as regras mínimas necessárias para testar o produto no Android; não representa
uma versão estável ou pronta para distribuição.

Google Drive, sincronização, atualização pelo aplicativo, módulos completos de
chamado e distribuição pública não fazem parte desta entrega. Itens futuros do
roadmap não devem ser interpretados como funcionalidades existentes.

## Problema e objetivo

Pessoas podem acumular responsabilidades com rotinas e limites de acesso
distintos. Planilhas, papel e mensagens fragmentam esse acompanhamento.

O projeto busca oferecer uma base Android local para organizar Workspaces,
usuários e chamados. A primeira alpha funciona sem conta ou serviço externo e
mantém os dados no dispositivo.

## Escopo da `0.1.0-alpha.1`

- splash screen e onboarding guiado;
- criação de um Workspace `LOCAL` e do primeiro usuário como `ADMIN`;
- cadastro e seleção de múltiplos usuários;
- foto de perfil opcional armazenada localmente pelo aplicativo;
- RBAC centralizado para os papéis `ADMIN`, `MODERATOR` e `USER`, incluindo a
  proteção do último administrador;
- catálogo inicial de chamados, sem implementar ainda as rotinas internas de
  cada módulo;
- suporte a zero, um ou vários chamados por usuário, com estados `ACTIVE` e
  `ARCHIVED`;
- temas claro, escuro e preferência do sistema, com escolha persistida;
- banco SQLite local com Drift, schema versionado e migração explícita;
- estado assíncrono e injeção de dependências com Riverpod.

Os itens acima descrevem o escopo em fechamento. Enquanto a versão permanecer
marcada como **Em desenvolvimento**, alterações e validações ainda podem ocorrer
antes de seu encerramento.

## Catálogo inicial

O catálogo usa identificadores estáveis, independentes do texto mostrado na
interface. Nesta alpha, ele permite associar e arquivar os chamados de
Secretário da Ministração do Quórum de Élderes e Secretário da Escola Dominical.
As rotinas próprias desses módulos continuam sinalizadas como **Em
desenvolvimento**.

## Stack

- Flutter `3.47.1` e Dart `3.13.1`;
- Riverpod para estado e injeção de dependências;
- Drift sobre SQLite para persistência offline;
- Android como primeira plataforma.

As escolhas e seus trade-offs estão documentados nos
[ADRs](docs/adr/), incluindo a decisão do
[app shell da primeira alpha](docs/adr/0010-alpha1-app-shell.md).

## Modelo de domínio

```text
Workspace
User
Membership
Role
Calling
CallingModule
```

O modo entregue nesta alpha usa apenas Workspace `LOCAL`. Os papéis são
`ADMIN`, `MODERATOR` e `USER`; permissões são avaliadas no Workspace atual e
negadas por padrão quando não estiverem autorizadas. As regras completas estão
em [docs/product/domain-model.md](docs/product/domain-model.md).

## Como executar

Pré-requisitos: Flutter `3.47.1`, uma plataforma Flutter configurada e as
ferramentas indicadas por `flutter doctor -v`.

```bash
flutter pub get
dart run build_runner build
flutter run
```

Nenhum secret, conta Google ou serviço externo é necessário para o modo local.

## Testes e qualidade

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

O CI executa formatação, verificação de código gerado, análise, testes e build
do APK de debug em pull requests para `main` e `develop`. A execução no Android
requer SDK e dispositivo ou emulador configurado.

## Versionamento

O projeto usa SemVer para a versão pública. Em `0.1.0-alpha.1+1`,
`0.1.0-alpha.1` identifica a pré-versão do aplicativo e o número após `+` é o
número de build. No Android, esse número de build alimenta o `versionCode`, que
deve crescer a cada pacote publicado, sem substituir o significado da versão
SemVer exibida ao usuário.

O status **Em desenvolvimento** significa que ainda não há release pública
correspondente, mesmo que APKs de debug sejam construídos para validação.

## Privacidade e segurança

Nome, foto e dados de chamados permanecem no armazenamento local desta alpha.
Dados reais de membros, credenciais, tokens, keystore, pastas reais de serviços
externos e bancos locais nunca devem entrar neste repositório.

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

O código é disponibilizado sob a [licença MIT](LICENSE). A licença do código não
concede automaticamente direitos sobre o nome, a identidade visual ou ativos de
marca. Consulte [BRAND.md](BRAND.md).
