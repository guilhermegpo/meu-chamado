# Meu Chamado

Aplicativo Android offline-first para organizar usuários e chamados em um
Workspace local, com uma base modular para evoluções futuras.

> [!IMPORTANT]
> Meu Chamado é um projeto independente e não oficial. Não é afiliado,
> endossado ou patrocinado por A Igreja de Jesus Cristo dos Santos dos Últimos
> Dias.

## Status

**`0.2.0-alpha.3` — Alpha.**

> [!WARNING]
> Pré-versão em desenvolvimento ativo. A modelagem de dados, o schema local e as
> interfaces podem mudar de forma incompatível antes da `1.0.0` estável, e não há
> caminho de atualização garantido entre pré-versões. Use apenas para avaliação,
> com dados fictícios.

Esta versão fecha a segurança local: o app pede um PIN antes de mostrar qualquer
dado, aceita biometria como atalho e passa a guardar o banco local
criptografado. Não é uma versão estável nem distribuída publicamente — não há
APK de release assinado com chave de produção, apenas artefatos de debug para
validação.

As duas listas abaixo são separadas de propósito. **Implementado** descreve o que
existe e pode ser usado nesta versão; **[Roadmap](ROADMAP.md)** descreve direção
futura e não deve ser lido como funcionalidade existente.

## Problema e objetivo

Pessoas podem acumular responsabilidades com rotinas e limites de acesso
distintos. Planilhas, papel e mensagens fragmentam esse acompanhamento.

O projeto busca oferecer uma base Android local para organizar Workspaces,
usuários e chamados. A primeira alpha funciona sem conta ou serviço externo e
mantém os dados no dispositivo.

## Implementado na `0.2.0-alpha.3`

Segurança local dos dados.

- bloqueio do app por PIN de seis dígitos antes de qualquer tela com dados; o
  PIN nunca é guardado em claro (verificador PBKDF2-HMAC-SHA256);
- biometria opcional como atalho para o PIN, ativável nas Configurações; o PIN
  continua sendo o método principal e sempre disponível;
- banco local criptografado (SQLite3 Multiple Ciphers); a chave é aleatória,
  criada uma vez e guardada só no armazenamento seguro do sistema, nunca
  derivada do PIN;
- migração do banco texto puro da `alpha.2` para o formato criptografado, sem
  perda: verifica, mantém backup e desfaz em caso de erro;
- relock no cold start e após 30 s em segundo plano; "Alterar PIN" e
  "Bloquear agora" nas Configurações;
- atraso progressivo após PINs errados, com teto, sem nunca apagar dados;
- `FLAG_SECURE` nas telas desbloqueadas em builds de release.

O que o modelo de ameaças protege e o que **não** protege está em
[docs/security/threat-model.md](docs/security/threat-model.md) e na
[ADR 0016](docs/adr/0016-local-security-and-encrypted-storage.md). Não existe
recuperação do PIN pela internet. A criptografia de dados é independente da
assinatura do APK ([ADR 0011](docs/adr/0011-android-release-signing.md)).

## Implementado na `0.2.0-alpha.2`

Operação das entrevistas de ministração: quem conduz e o que está agendado.

- liderança do Quórum de Élderes como cadastro próprio, com identificação
  mínima, cargo e ciclo ativo/inativo, separada do papel técnico do Workspace;
- entrevistador registrado em cada entrevista, sempre escolhido de propósito;
- agendamento de entrevista a partir de uma dupla pendente, com data, hora e
  entrevistador; reagendar edita a mesma linha, cancelar a remove;
- conclusão de um agendamento cria a entrevista com o entrevistador do plano;
- recusa de agendamento no passado; ao desativar a dupla, o agendamento aberto
  é cancelado após confirmação, sem tocar em entrevistas realizadas;
- schema local v4 com as tabelas de liderança e de agendamento, em migração
  aditiva a partir da v3;
- design system compartilhado por home, painel, telas de Ministração, perfis,
  chamados e configurações, com a marca original no launcher e na splash.

Quem conduz a entrevista é um líder cadastrado de propósito, nunca inferido do
usuário logado ([ADR 0014](docs/adr/0014-ministering-leadership-domain.md)). O
agendamento é uma linha própria e não tem coluna de status: cancelar é apagar,
concluir é criar a entrevista ([ADR 0015](docs/adr/0015-ministering-scheduling-model.md)).

## Implementado na `0.2.0-alpha.1`

Módulo do Secretário da Ministração do Quórum de Élderes, primeira fatia
funcional:

- cadastro de irmãos ministradores com identificação mínima e ciclo
  ativo/inativo;
- duplas de dois ou três integrantes, com rótulo próprio opcional;
- registro de entrevista realizada, com data e participantes;
- histórico por dupla, com remoção para corrigir engano;
- painel do trimestre corrente separando duplas pendentes e entrevistadas;
- schema local v3 com integridade referencial composta por chamado e migração
  aditiva a partir da v2;
- idioma pt-BR no Material, incluindo o seletor de data.

O trimestre é derivado da data da entrevista e não há coluna de status: a
existência do registro é o fato de a entrevista ter ocorrido
([ADR 0012](docs/adr/0012-ministering-quarterly-model.md)). O módulo guarda a
identificação mínima que permite reconhecer uma dupla, e nada além disso
([ADR 0013](docs/adr/0013-ministering-minimal-identification.md)).

## Implementado na `0.1.0-alpha.1`

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

Cada item acima foi verificado por testes automatizados e por um smoke test em
emulador Android, com instalação limpa e reabertura após `force-stop`.

### Fora desta versão

Os itens abaixo **não existem** nesta alpha, ainda que apareçam no roadmap ou em
decisões de arquitetura já registradas:

- sincronização e integração com Google Drive;
- Workspace compartilhado entre dispositivos ou pessoas;
- atualização pelo próprio aplicativo;
- recuperação do PIN pela internet;
- designações de famílias, relatórios para a liderança e histórico de
  trimestres anteriores;
- rotinas internas do módulo de Escola Dominical;
- APK de release assinado e distribuição pública.

## Catálogo inicial

O catálogo usa identificadores estáveis, independentes do texto mostrado na
interface. Ele permite associar e arquivar os chamados de Secretário da
Ministração do Quórum de Élderes e Secretário da Escola Dominical.

O chamado de Ministração abre o módulo a partir da `0.2.0-alpha.1`. A decisão
usa a chave do módulo, nunca o título: o título é texto livre e renomeá-lo não
muda comportamento. As rotinas da Escola Dominical continuam sinalizadas como
**Em desenvolvimento**.

## Stack

- Flutter `3.47.1` e Dart `3.13.1`;
- Riverpod para estado e injeção de dependências;
- Drift sobre SQLite para persistência offline;
- Android como primeira plataforma.

As escolhas e seus trade-offs estão documentados nos
[ADRs](docs/adr/), incluindo a decisão do
[app shell da primeira alpha](docs/adr/0010-alpha1-app-shell.md) e o motivo de
[adiar a chave de assinatura de release](docs/adr/0011-android-release-signing.md).

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

O projeto usa SemVer para a versão pública. Em `0.2.0-alpha.3+4`,
`0.2.0-alpha.3` identifica a pré-versão do aplicativo e o número após `+` é o
número de build. No Android, esse número de build alimenta o `versionCode`, que
deve crescer a cada pacote publicado, sem substituir o significado da versão
SemVer exibida ao usuário.

O status **Alpha** significa que a versão está fechada e marcada, mas continua
sujeita a mudanças incompatíveis. A publicação correspondente no GitHub é uma
pré-release: ela documenta o marco e não distribui um APK assinado para produção.
O que falta para isso está em
[ADR 0011](docs/adr/0011-android-release-signing.md).

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
