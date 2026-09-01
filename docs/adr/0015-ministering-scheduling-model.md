# 0015 — Agendamento como linha própria, não como estado da entrevista

## Status

Aceito.

## Contexto

A [ADR 0012](0012-ministering-quarterly-model.md) previu que, quando a
`0.2.x` trouxesse agendamento, `status` e `scheduled_at` entrariam como
colunas novas em `ministering_interviews`. Ao implementar o recurso na
`0.2.0-alpha.2`, essa previsão se mostrou o caminho errado.

Uma entrevista realizada é um fato consumado: aconteceu num dia, com
participantes. Um agendamento é um plano: muda de data, troca de
entrevistador, é cancelado. Guardar os dois na mesma linha, distinguidos por
`status`, recria exatamente os estados impossíveis que o módulo evita desde a
ADR 0012:

- `status = 'agendada'` com `completed_at` preenchido;
- `status = 'realizada'` sem nenhum participante;
- `status = 'cancelada'` pendurada na tabela, entrando na faixa de datas que
  o painel do trimestre varre.

## Decisão

Modelar o agendamento como tabela separada, `ministering_appointments`, no
schema local v4.

1. **Tabela própria.** `id`, `calling_id`, `companionship_id`,
   `interviewer_id`, `scheduled_at` e carimbos de tempo. FK composta
   `(companionship_id, calling_id)` para a dupla com `ON DELETE CASCADE`; FK
   composta `(interviewer_id, calling_id)` para a liderança
   ([ADR 0014](0014-ministering-leadership-domain.md)) com
   `ON DELETE RESTRICT`.
2. **Sem coluna de status, aqui também.** A existência da linha **é** o fato
   de haver uma entrevista planejada. Cancelar é apagar a linha. Concluir é
   criar a `MinisteringInterview` com o entrevistador do plano e apagar o
   agendamento, na mesma transação.
3. **Um agendamento aberto por dupla.** `UNIQUE (companionship_id)`.
   Reagendar edita a linha existente — nova data e/ou novo entrevistador —,
   não cria outra.
4. **`scheduled_at` tem hora do dia.** Ao contrário de
   `MinisteringInterviews.completedAt`, que é data de calendário. Um
   agendamento tem horário; uma entrevista aconteceu num dia. O instante é
   truncado no minuto (`scheduledInstant`), a precisão que os seletores
   oferecem, para voltar do banco idêntico ao que entrou.
5. **Não se agenda no passado.** O repositório recusa `scheduled_at` anterior
   ao minuto corrente, ao agendar e ao reagendar
   (`PastAppointmentDateTimeException`); o diálogo valida antes de habilitar o
   botão. Um plano é sempre para agora ou para frente.
6. **Desativar a dupla cancela o agendamento aberto.** Na mesma transação —
   o plano de entrevistar uma dupla inativa não significa nada. A interface
   confirma antes. Entrevistas já realizadas nunca são tocadas.
7. **Excluir a dupla é bloqueado enquanto houver agendamento aberto.** A
   verificação de remoção conta o agendamento; a ação segura oferecida é
   cancelar e depois desativar, com o motivo correto na mensagem.
8. **O entrevistador do plano é preservado na conclusão.** A entrevista
   guarda o líder que constava do agendamento, mesmo que ele fique inativo
   entre o agendamento e a realização.

## Alternativas consideradas

- **`status` + `scheduled_at` na entrevista** (a previsão da ADR 0012).
  Reintroduz os estados impossíveis descritos acima e força o código a
  manter `status` coerente com a existência da linha. Linhas "canceladas"
  poluiriam a consulta central do painel, que varre `completed_at` por
  faixa.
- **Manter o agendamento após concluir, como trilha de auditoria.**
  Duplicaria entrevistador e dupla, que já ficam na entrevista. A entrevista
  realizada **é** o registro; o agendamento cumpriu o papel dele.
- **Vários agendamentos abertos por dupla.** O painel e a checagem de "já
  agendada" precisariam desambiguar qual é o próximo. Uma dupla tem uma
  próxima entrevista.
- **Agendamento sem entrevistador, escolhido só na conclusão.** Tira do plano
  a informação mais útil para a liderança e deixa a lista de agendamentos sem
  responsável.

## Consequências

A consulta do painel do trimestre continua igual à da ADR 0012: os
agendamentos vivem na própria tabela e nunca entram na varredura de
`completed_at`. "Agendada" é um terceiro estado **de exibição** no painel
(pendente, agendada, entrevistada), derivado da presença de uma linha de
agendamento para uma dupla ainda pendente — não um estado persistido.

A migração v3 → v4 é aditiva: cria `ministering_appointments` e os índices de
operação, sem reescrever linha existente.

O parágrafo final da [ADR 0012](0012-ministering-quarterly-model.md), que
previa `status` e `scheduled_at` como colunas, fica **substituído** por esta
decisão. O resto da ADR 0012 — trimestre derivado, sem ano/quarter
materializados, mais de uma entrevista por trimestre — segue valendo.
