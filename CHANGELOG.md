# Changelog

Todas as mudanças relevantes deste projeto serão documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
projeto pretende usar [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

Nenhuma mudança posterior à primeira alpha foi registrada.

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
