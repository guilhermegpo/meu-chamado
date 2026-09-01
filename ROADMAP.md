# Roadmap

Este roadmap comunica direção, não um contrato imutável. Escopo e ordem podem
mudar quando testes, pesquisa ou restrições reais indicarem uma opção melhor.
Itens de versões futuras são hipóteses e não representam funcionalidades já
entregues.

## 0.1.x — Fundação

### 0.1.0-alpha.1 — Entregue em 2026-08-25

Escopo entregue e verificado:

- app shell com splash screen e onboarding;
- Workspace `LOCAL` persistido;
- primeiro usuário `ADMIN`, múltiplos usuários e foto opcional local;
- RBAC central para `ADMIN`, `MODERATOR` e `USER`;
- proteção do último administrador;
- catálogo inicial de chamados;
- zero, um ou vários chamados por usuário;
- ativação e arquivamento de chamados;
- tema claro, escuro ou do sistema com preferência persistida;
- schema local versionado e migração testável;
- CI de pull requests e smoke test em Android.

Os módulos do catálogo permanecem com suas rotinas internas **não
implementadas**: a alpha organiza as instâncias de chamado, não o trabalho de
cada chamado. Não há APK de release assinado nesta versão — ver
[ADR 0011](docs/adr/0011-android-release-signing.md).

### Depois da primeira alpha

- corrigir achados de uso da primeira alpha;
- ampliar testes de autorização, persistência e migração;
- refinar acessibilidade, mensagens de erro e experiência offline;
- revisar navegação quando existirem rotas profundas ou fluxos aninhados reais.

## 0.2.x — Secretário da Ministração

### 0.2.0-alpha.1 — Entregue em 2026-08-28

Escopo entregue e verificado:

- cadastro de irmãos ministradores com identificação mínima;
- ciclo ativo/inativo para irmãos e duplas, sem exclusão que destrua histórico;
- duplas de dois ou três integrantes, com rótulo próprio opcional;
- registro de entrevista realizada, com data e participantes;
- histórico por dupla, com remoção para corrigir engano;
- painel do trimestre corrente separando pendentes e entrevistadas;
- schema local v3 com integridade composta por chamado e migração aditiva;
- idioma pt-BR no Material.

O trimestre é derivado da data da entrevista e não existe coluna de status: a
existência do registro é o fato — ver
[ADR 0012](docs/adr/0012-ministering-quarterly-model.md). A identificação
guardada é a mínima — ver
[ADR 0013](docs/adr/0013-ministering-minimal-identification.md).

### 0.2.0-alpha.2 — Entregue em 2026-09-01

Escopo entregue e verificado:

- liderança do Quórum de Élderes como cadastro próprio, com cargo e ciclo
  ativo/inativo, separada do papel técnico do Workspace;
- entrevistador registrado em cada entrevista, escolhido de propósito;
- agendamento de entrevista a partir de uma dupla pendente, com reagendar e
  cancelar; concluir cria a entrevista com o entrevistador do plano;
- recusa de agendamento no passado; agendamento cancelado ao desativar a dupla,
  com confirmação;
- schema local v4 com as tabelas de liderança e de agendamento, em migração
  aditiva a partir da v3;
- design system aplicado a home, painel, Ministração, perfis, chamados e
  configurações; marca original no launcher e na splash.

O agendamento é linha própria e também não tem coluna de status — ver
[ADR 0015](docs/adr/0015-ministering-scheduling-model.md). Quem conduz a
entrevista é um líder cadastrado de propósito — ver
[ADR 0014](docs/adr/0014-ministering-leadership-domain.md).

### Previsto para as próximas alphas da série

- `alpha.3`: revisão de segurança e proteção do banco local (PIN, biometria,
  criptografia);
- `alpha.4`: histórico de trimestres anteriores e relatório para a liderança;
- `alpha.5`: apoio ao "Aprender" da reunião do quórum.

Designações de famílias ou pessoas ministradas seguem fora da série enquanto o
tratamento desse dado não estiver documentado e justificado.

## 0.3.x — Secretário da Escola Dominical

- pesquisar classes, professores, participantes e frequência;
- avaliar designações, agenda e conselho de professores;
- implementar regras próprias sobre a infraestrutura compartilhada.

## 0.4.x — Workspace compartilhado / Google Drive

- pesquisar sincronização opcional e o modelo de conflitos;
- avaliar seleção explícita de pasta e privilégio mínimo;
- projetar migração do Workspace local sem perda silenciosa;
- manter dados privados fora do provedor compartilhado.

Esta seção é planejamento. Google Drive não está implementado na primeira
alpha.

## 0.5.x — Atualizações

- pesquisar canais Stable e Beta;
- avaliar consulta de versão, changelog e verificação de integridade;
- definir um fluxo Android seguro antes de qualquer distribuição.

Esta seção é planejamento. Atualização pelo aplicativo e distribuição pública
não estão implementadas na primeira alpha.

## 0.6.x — Segurança e refinamentos

- revisar o modelo de ameaças;
- ampliar testes de autorização, migração e persistência;
- refinar acessibilidade, performance e experiência offline;
- preparar um processo de release reproduzível apenas quando houver decisão de
  distribuição.

## 1.0.0 — Primeira versão estável

- escopo estável definido por evidência de uso e testes;
- documentação de operação, privacidade e recuperação;
- processo de release reproduzível e verificável, caso a distribuição seja
  aprovada no futuro.
