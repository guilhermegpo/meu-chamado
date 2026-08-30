# Changelog

Todas as mudanças relevantes deste projeto serão documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
projeto pretende usar [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added

- exclusão definitiva e confirmada de irmãos e duplas que nunca foram usados,
  preservando qualquer cadastro com vínculo ou histórico;
- correção de data e participantes de uma entrevista existente, sem criar
  outro registro;
- nova marca original aplicada ao launcher, splash e superfícies internas.

### Changed

- home, painel trimestral, telas de Ministração, perfis, chamados e
  configurações passam a compartilhar tokens e componentes visuais do novo
  design system;
- ações de irmãos e duplas foram agrupadas em menus compactos para reduzir
  ruído visual em telas pequenas;
- reativar uma dupla agora exige que todos os integrantes estejam ativos.

## [0.2.0-alpha.1] — 2026-08-28

Primeira fatia funcional do módulo do Secretário da Ministração do Quórum de
Élderes: o app deixa de apenas organizar instâncias de chamado e passa a
atender a rotina de um deles.

### Added

- cadastro de irmãos ministradores com identificação mínima e ciclo
  ativo/inativo;
- composição de duplas de dois ou três integrantes, com rótulo próprio
  opcional;
- registro de entrevista realizada, com data e participantes;
- histórico de entrevistas por dupla, com remoção para corrigir engano;
- painel do trimestre corrente com duplas pendentes e entrevistadas;
- entrada no módulo pelo card do chamado na tela inicial, decidida pela chave
  do módulo;
- schema local v3 com cinco tabelas do módulo, integridade referencial
  composta por chamado e migração aditiva a partir da v2;
- idioma pt-BR no Material, incluindo o seletor de data.

### Changed

- `userErrorMessage` traduz também as exceções do módulo de ministração;
- o card de chamado ativo mostra "Abrir módulo" quando existe módulo pronto.

### Fixed

- a data da entrevista deixa de recuar um dia na leitura: o Drift devolvia
  `DateTime` no fuso do aparelho e desfazia a normalização UTC, o que também
  jogaria uma entrevista do primeiro dia do trimestre para o anterior;
- a tela de Configurações mostrava `0.1.0-alpha.1` com a `0.2.0-alpha.1`
  instalada; a versão passa a vir de `AppInfo`, com teste que a compara ao
  `pubspec.yaml`.

### Fora desta versão

- agendamento de entrevistas, `status` e data prevista;
- designações de famílias ou pessoas ministradas;
- relatórios para a liderança e visão de líderes;
- histórico de trimestres anteriores;
- sincronização, Workspace compartilhado ou Google Drive;
- atualização pelo aplicativo;
- APK de release assinado com chave de produção.

Continua sendo uma pré-versão alpha: schema local e interfaces ainda podem
mudar de forma incompatível.

## [0.1.0-alpha.1] — 2026-08-25

### Added

- fundação documental, identidade visual original e scaffold Flutter para
  Android;
- splash screen e onboarding do Workspace `LOCAL`;
- criação do primeiro usuário `ADMIN`, cadastro de múltiplos usuários e seleção
  de perfil;
- foto de perfil opcional mantida no armazenamento local do aplicativo;
- política central de RBAC para `ADMIN`, `MODERATOR` e `USER`, com proteção do
  último administrador;
- catálogo inicial e persistência de zero, um ou vários chamados por usuário;
- estados `ACTIVE` e `ARCHIVED` para o ciclo de vida de chamados;
- temas claro, escuro e preferência do sistema, com persistência da escolha;
- persistência SQLite com Drift, schema versionado e caminho de migração;
- testes automatizados, CI de pull requests e Dependabot.

### Fora desta versão

- sincronização ou integração com Google Drive;
- Workspace compartilhado entre dispositivos ou pessoas;
- atualização pelo aplicativo;
- módulo completo do Secretário da Ministração do Quórum de Élderes;
- módulo completo do Secretário da Escola Dominical;
- APK de release assinado com chave de produção e distribuição pública.

Esta é uma pré-versão alpha. A modelagem de dados, o schema local e as
interfaces ainda podem mudar de forma incompatível antes da `0.1.0` estável, e
não há caminho de atualização garantido entre pré-versões.

O número SemVer `0.1.0-alpha.1` identifica a pré-versão. O sufixo de build do
Flutter, como `+1`, corresponde ao `versionCode` do Android e evolui de forma
monotônica quando um novo pacote é publicado.

[Unreleased]: https://github.com/guilhermegpo/meu-chamado/compare/v0.1.0-alpha.1...develop
[0.1.0-alpha.1]: https://github.com/guilhermegpo/meu-chamado/releases/tag/v0.1.0-alpha.1
