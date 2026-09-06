# Regras permanentes do Meu Chamado

Fonte única das regras do projeto. Elas valem sem serem repetidas a cada
prompt, e não precisam ser reproduzidas nos relatórios.

## Git

- Conta obrigatória: `guilhermegpo`. Validar antes de todo push:
  `gh api user --jq .login`, `git config user.name`, `git config user.email`,
  `git remote -v`.
- `main` e `develop` são permanentes. Trabalhar sempre em feature branch com PR.
- Conventional Commits. Commits pequenos e coerentes.
- Nunca fazer merge automático — abrir o PR e parar.
- Nunca `force push`, nunca reescrever histórico publicado, nunca contornar
  ruleset ou proteção de branch.
- Nunca tocar `iZeneX` nem `KushyDev`.

## Segurança e privacidade

- Somente dados fictícios no repositório e nos testes (`Irmão A`,
  `Workspace Demo`). Nenhum nome, contato ou dado real de membro.
- Durante as alphas, não armazenar dados reais de membros sem security gate.
- Nunca versionar credenciais, keystore, tokens, `.env` ou dados confidenciais.
- Não usar logo, símbolos ou assets oficiais da Igreja.
- Meu Chamado é independente e **não oficial**.
- Screenshots com dados reais ficam em pasta temporária e nunca são commitados.

## Produto

- `ADMIN` do Workspace pode tudo tecnicamente; `MODERATOR` e `USER` seguem o
  RBAC central. Papel no app **≠** autoridade eclesiástica.
- Não acoplar comportamento a nomes de pessoas.
- Identidade de chamado é o `moduleKey`, nunca o título textual — título é
  texto livre e renomeá-lo não pode mudar comportamento.
- Procurar proativamente lacunas de produto, UX, integridade, segurança e
  acessibilidade. Não limitar a revisão ao que foi explicitamente pedido.

### Ministração (0.2.x)

- A entrevista não tem `status`: a existência da linha é o fato.
- Trimestre é derivado de `completedAt`, nunca persistido
  ([ADR 0012](docs/adr/0012-ministering-quarterly-model.md)).
- Várias entrevistas da mesma dupla no mesmo trimestre são válidas; o resumo
  conta duplas distintas.
- Identificação mínima do irmão
  ([ADR 0013](docs/adr/0013-ministering-minimal-identification.md)).
- Progresso nunca aparece como percentual isolado — mede trabalho
  administrativo, não desempenho espiritual.
- Quem conduz a entrevista é um líder cadastrado de propósito, separado do
  papel técnico do Workspace, nunca inferido do usuário logado
  ([ADR 0014](docs/adr/0014-ministering-leadership-domain.md)).
- O agendamento também não tem `status`: é linha própria em
  `ministering_appointments`; cancelar apaga, concluir cria a entrevista.
  Não se agenda no passado ([ADR 0015](docs/adr/0015-ministering-scheduling-model.md)).
- Trimestre encerrado tem o **escopo** congelado num snapshot (schema v5): o
  denominador do histórico é quem fazia parte do trimestre, não o estado atual
  das duplas. A entrevista segue como fonte de verdade — corrigi-la recalcula o
  numerador. Congelar é regra de domínio (roda antes de ler o módulo e de
  mudar o conjunto de duplas), nunca no trimestre corrente. Snapshot guarda só
  IDs. Dupla no escopo de um trimestre concluído não se apaga, só se desativa
  ([ADR 0017](docs/adr/0017-ministering-quarter-snapshots.md)).

## UX

O objetivo não é apenas funcionar. O app deve ser profissional, moderno,
dinâmico, intuitivo, mobile-first, consistente e acessível.

Para cada entidade manipulável, avaliar sempre: criar, visualizar, editar,
inativar/arquivar, excluir quando apropriado, confirmação destrutiva, feedback,
empty/error/loading states, navegação, teclado, back do Android, persistência,
acessibilidade, touch targets e dark/light.

- Nunca destruir histórico silenciosamente. Exclusão definitiva só quando não
  há vínculo; havendo vínculo, oferecer a ação segura e explicar por quê.
- Animação serve à compreensão, não à decoração. Sem visual gamer, sem excesso
  de gradiente, sem efeito lento.
- Dark e light devem parecer projetados, não invertidos. Paleta: navy, teal,
  azul, off-white, charcoal.
- Nunca mostrar stack trace ao usuário.

## Homologação

Dispositivo físico padrão: **Motorola Edge 30 Neo**, ADB `ZF5249MWVV`.

Conectado (`device`), alterações relevantes são instaladas e testadas nele com
seleção explícita: `flutter run -d ZF5249MWVV`.

**Emulador é proibido por padrão.** Não iniciar, listar, criar ou usar
AVD/emulator sem autorização explícita do usuário em um prompt. Se o Motorola
não estiver conectado: rodar build e testes normalmente, registrar a
homologação física como pendente e **não** abrir emulador como fallback.

Nota: o aparelho contém o Workspace real do usuário. Só cadastrar dados
fictícios e não apagar dados existentes sem autorização.

## Portão de qualidade

Antes de homologar ou abrir PR:

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Não reduzir testes existentes para obter verde.

## Fora de escopo até liberação explícita

`0.2.0-alpha.5` e além: Google Drive, sync, updater, Aprender, Escola Dominical
completa, relatório/visão para a liderança, recuperação de PIN pela internet.

Liderança/entrevistadores e agendamento entraram na `0.2.0-alpha.2`
([ADR 0014](docs/adr/0014-ministering-leadership-domain.md),
[ADR 0015](docs/adr/0015-ministering-scheduling-model.md)). Bloqueio por PIN,
biometria e banco criptografado entraram na `0.2.0-alpha.3`
([ADR 0016](docs/adr/0016-local-security-and-encrypted-storage.md)). O histórico
dos trimestres, com snapshot de escopo, entrou na `0.2.0-alpha.4`
([ADR 0017](docs/adr/0017-ministering-quarter-snapshots.md)).

### Segurança local (0.2.3+)

- O bloqueio é do app, não por irmão/chamado/usuário, e não se mistura com o
  RBAC do Workspace.
- Chave do banco ≠ PIN: chave aleatória só no secure storage; PIN é verificador
  derivado. Nunca guardar PIN em claro, nunca derivar a chave do PIN, nunca
  logar segredo.
- Nunca apagar dados por tentativas de PIN erradas.
- Biometria é opcional e nunca o único método — sempre há o PIN.
- Migração texto puro → criptografado é atômica e preserva o original até
  confirmar.

## Autoria, identidade Git e atribuição de ferramentas

Este repositório é mantido publicamente por `guilhermegpo`.

Antes de qualquer commit, push, PR ou release, confirme:

- GitHub account: `guilhermegpo`
- git user.name: `guilhermegpo`
- git user.email: `279581900+guilhermegpo@users.noreply.github.com`

É proibido adicionar qualquer atribuição automática a ferramentas de IA,
assistentes ou agentes.

Nunca incluir, em nenhum lugar público:

- `Generated with Claude Code`
- `Generated by Claude`
- `Generated by AI`
- `AI-assisted`
- `Co-Authored-By: Claude`
- `Co-Authored-By` de qualquer bot/agente
- links promocionais para Claude, Anthropic, Codex ou ferramentas equivalentes
- badges ou comentários indicando geração por IA
- comentários em código mencionando o agente
- notas em README, CHANGELOG, ADRs ou documentação sobre uso de IA
- rodapés automáticos em commits
- rodapés automáticos em Pull Requests
- rodapés automáticos em GitHub Releases

Commits devem conter apenas a mensagem técnica necessária ao projeto.

Pull Requests devem conter apenas:
- contexto;
- mudanças;
- validações;
- riscos;
- decisões;
- informações relevantes ao projeto.

Nenhum agente deve se apresentar como autor, coautor, colaborador ou contribuinte.

Se uma ferramenta tentar inserir atribuição automaticamente:
remova a atribuição antes de commit/push/PR.

Nunca alterar autoria histórica publicada apenas para esse fim.
Nunca usar force push ou reescrever histórico publicado.
