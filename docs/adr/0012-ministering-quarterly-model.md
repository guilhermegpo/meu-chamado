# 0012 — Derivar o trimestre e registrar apenas a entrevista realizada

## Status

Aceito.

## Contexto

O Secretário da Ministração acompanha entrevistas de ministração ao longo do
trimestre. O módulo precisa responder, a qualquer momento, quais duplas ainda
não foram entrevistadas no trimestre corrente.

Duas modelagens se ofereciam. A primeira guardaria, em cada entrevista, um
campo `status` (`pendente`, `agendada`, `realizada`) e as colunas `year` e
`quarter`. A segunda guardaria apenas o fato consumado, com a data, e derivaria
o resto.

O rascunho inicial também previa `UNIQUE (companionship_id, year, quarter)`,
proibindo uma segunda entrevista da mesma dupla no mesmo trimestre.

## Decisão

Persistir somente a entrevista realizada, com `completed_at` como única
referência temporal.

1. **Sem coluna de status.** A ausência da linha significa "ainda não
   entrevistada"; a presença significa "realizada". Não há terceiro estado
   possível, então não há estado a manter em sincronia.
2. **Sem colunas de ano e trimestre.** `Quarter.of(completedAt)` deriva o
   trimestre. Guardá-lo ao lado da data criaria dois valores que podem
   divergir — e, quando divergem, nada indica qual está certo.
3. **Janela meio aberta.** A contagem usa `start <= completedAt < nextStart`,
   com `nextStart` sendo o primeiro instante do trimestre seguinte. Assim o
   limite superior nunca precisa de aritmética de "último dia do mês", e o
   quarto trimestre vira o ano sem caso especial.
4. **Data de calendário normalizada.** A entrevista aconteceu num dia, não num
   instante: `calendarDate` normaliza para meia-noite UTC. Sem isso, uma
   entrevista registrada em 30/09 à noite poderia cair no trimestre seguinte
   dependendo do fuso do aparelho.
5. **Mais de uma entrevista por trimestre é permitida.** O Manual pede *pelo
   menos* uma; recusar a segunda apagaria trabalho que aconteceu de verdade. O
   resumo conta duplas distintas, não entrevistas, então o número do painel não
   muda por isso.
6. **Desativar em vez de apagar.** Irmãos e duplas têm `is_active`. Apagar um
   irmão levaria junto as entrevistas de que ele participou; inativo, ele sai
   das composições novas e permanece nas antigas. Dupla inativa sai do
   denominador do trimestre e mantém o histórico.

## Alternativas consideradas

- **`status` persistido**: necessário quando houver agendamento, na `0.2.x`
  posterior. Antes disso, seria uma coluna com um valor só, que o código teria
  de manter coerente com a existência da linha.
- **`year` e `quarter` materializados**: tornariam o índice de contagem trivial,
  ao custo de dois valores redundantes gravados por linha. O índice de faixa
  `(calling_id, completed_at)` atende a mesma consulta sem esse custo.
- **`UNIQUE (companionship_id, year, quarter)`**: proibiria registrar a segunda
  entrevista de uma dupla no trimestre, transformando uma regra de contagem em
  restrição de integridade e apagando histórico real.

## Consequências

O resumo do trimestre conta duplas distintas com `GROUP BY companionship_id`
sobre a faixa de datas, apoiado no índice
`(calling_id, completed_at)`. Nenhuma consulta precisa confiar em campo
derivado gravado.

Filtrar por trimestre em memória deixa de ser possível sem carregar as datas —
o que é aceitável no volume de uma ala e evita a duplicação de estado.

Esta ADR previa que o agendamento chegaria como colunas `status` e
`scheduled_at` nesta tabela. Na `0.2.0-alpha.2` a decisão foi outra: o
agendamento é uma linha própria em `ministering_appointments`, também sem
coluna de status — ver [ADR 0015](0015-ministering-scheduling-model.md). A
entrevista realizada continua sendo a linha que já existe aqui, agora com a
coluna `interviewer_id` da v4 ([ADR 0014](0014-ministering-leadership-domain.md)).

O progresso do trimestre nunca é exibido como percentual isolado: o número mede
o trabalho administrativo do secretário, não o desempenho espiritual de
ninguém. A interface mostra "1 de 2 duplas entrevistadas", com a barra apenas
como apoio visual da mesma contagem.
