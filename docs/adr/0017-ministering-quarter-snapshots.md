# 0017 — Congelar o escopo do trimestre encerrado num snapshot

## Status

Aceito.

## Contexto

Desde a [ADR 0012](0012-ministering-quarterly-model.md) o painel do trimestre
conta "X de Y duplas entrevistadas", onde **Y** é o número de duplas ativas
agora e **X** são as que têm ao menos uma entrevista na janela do trimestre.
Enquanto só existe o trimestre corrente, isso está correto: os dois números
descrevem o presente.

A `0.2.0-alpha.4` traz a tela de **Histórico**, que mostra também os trimestres
já encerrados. Aí o modelo do painel deixa de servir: **Y** é derivado do
estado atual das duplas, e o estado atual muda depois que o trimestre acaba.

- Uma dupla criada em janeiro de 2027 entraria no denominador do 3º trimestre
  de 2026, um período em que ela não existia.
- Desativar uma dupla hoje encolheria o denominador de todos os trimestres
  passados, como se ela nunca tivesse feito parte deles.
- Editar a composição de uma dupla reescreveria quem, no passado, era
  responsável por ministrar aquelas famílias.

O número de um trimestre encerrado precisa parar de se mover. Ao mesmo tempo,
**a entrevista continua sendo a fonte de verdade** — o secretário ainda tem de
poder registrar uma entrevista que esqueceu de lançar, corrigir a data de uma
que caiu no trimestre errado ou apagar uma lançada por engano, e o histórico
tem de refletir a correção.

## Decisão

Introduzir o **snapshot de trimestre**: uma fotografia do **escopo** — quais
duplas faziam parte daquele trimestre —, tirada uma vez, quando o trimestre
encerra. Schema local v5, três tabelas novas.

### 1. O snapshot congela o escopo, nunca as entrevistas

`ministering_quarter_snapshots` guarda `(calling_id, year, quarter)` e o
instante da finalização. `ministering_quarter_snapshot_companionships` lista as
duplas do escopo; `ministering_quarter_snapshot_members`, a composição de cada
uma naquele momento.

O **denominador histórico** é `COUNT` das duplas do snapshot. O **numerador
histórico** é `COUNT(DISTINCT companionship_id)` das duplas do snapshot que têm
ao menos uma entrevista na janela do trimestre — lido das entrevistas, ao vivo,
toda vez. Corrigir uma entrevista antiga muda o numerador; nada muda o
denominador de um trimestre já congelado.

### 2. O escopo é o que estava ativo, mais o que foi entrevistado

Ao finalizar o trimestre `T`, entram no escopo:

- as duplas **ativas** naquele instante; e
- qualquer dupla com ao menos uma entrevista dentro de `T`, mesmo que já esteja
  inativa (ela esteve no escopo de propósito).

O `IN (escopo)` no cálculo do numerador impede que uma entrevista de uma dupla
fora do snapshot — criada depois, retroagida por engano — infle o numerador
acima do denominador.

### 3. A finalização é regra de domínio, disparada por "antes de ler ou mexer"

`_finalizeExpiredQuarters` roda:

- **antes de toda leitura do módulo** (`loadModule`, `loadQuarterHistory`,
  `loadQuarterDetail`); e
- **no início de toda mutação que mexe no conjunto de duplas**
  (`createCompanionship`, `updateCompanionship`, `setCompanionshipActive`,
  `deleteCompanionship`).

Como o escopo é congelado **antes** de a mutação acontecer, o snapshot sempre
reflete o estado que valia enquanto o trimestre estava aberto. Não é preciso
reconstruir atividade histórica a partir de carimbos de tempo: a invariante
"finaliza primeiro" garante que o congelamento aconteça no primeiro instante
possível depois da virada.

Não é efeito de abrir a tela Histórico. Um secretário que nunca abre essa tela
ainda tem os trimestres congelados corretamente na primeira vez que cadastra
uma dupla no trimestre novo.

### 4. Nunca congela o trimestre corrente nem um futuro

O laço vai do trimestre relevante mais antigo — a entrevista mais antiga ou a
dupla criada há mais tempo — até o **anterior** ao corrente. O corrente
permanece "em andamento", com os números derivados do estado atual, como no
painel.

### 5. App fechado por vários trimestres

Se o app ficou fechado do 3º trimestre de 2026 ao 1º de 2028, a primeira
leitura em 2028 materializa 2026-T3, 2026-T4, 2027-T1…2027-T4 de uma vez, cada
um com o escopo que existe agora (nada mudou enquanto o app esteve fechado, então
esse escopo é o que valia em cada um). A virada 4º→1º atravessa o ano sem caso
especial.

### 6. O escopo é imutável depois de congelado

`UNIQUE (calling_id, year, quarter)` torna a finalização idempotente: a segunda
tentativa esbarra na restrição em vez de recongelar. Uma segunda leitura no
mesmo trimestre não altera o `finalized_at`.

### 7. Minimização de dados continua valendo no histórico

O snapshot referencia **IDs** (`companionship_id`, `brother_id`), nunca nomes.
Os rótulos — identificação mínima do irmão, rótulo próprio da dupla — são
resolvidos ao vivo pelo cadastro na hora de exibir. O que precisa ficar
imutável é o **conjunto**, não o texto
([ADR 0013](0013-ministering-minimal-identification.md)).

### 8. Uma dupla no escopo de um trimestre encerrado não pode ser apagada

FK `(companionship_id, calling_id)` → `ministering_companionships` com
`ON DELETE RESTRICT`. Apagar essa dupla encolheria o denominador histórico. A
verificação de remoção conta os snapshots; a ação segura oferecida é
**desativar**, que não toca no snapshot. Irmão no `snapshot_members` idem
(`ON DELETE RESTRICT` sobre `ministering_brothers`).

### 9. Relógio injetável

`MinisteringClock` (`typedef DateTime Function()`) é injetado no repositório. Em
produção é `DateTime.now`; nos testes, um valor mutável exercita a virada de
trimestre sem tocar no relógio do sistema.

## Alternativas consideradas

- **Materializar `year`/`quarter` na entrevista** (a hipótese descartada na
  ADR 0012). Resolveria o numerador, não o denominador: o "Y" continuaria
  derivado do estado atual das duplas.
- **Snapshot também das entrevistas.** Congelaria o erro junto com o acerto: um
  lançamento esquecido nunca poderia ser adicionado ao trimestre certo, uma
  data errada nunca poderia ser corrigida. A entrevista é a fonte de verdade
  por decisão da ADR 0012 e continua sendo.
- **Reconstruir o escopo histórico a partir dos carimbos de tempo**
  (`created_at`, `updated_at`, `is_active` com data). Exigiria uma trilha de
  auditoria de ativação/desativação que o módulo não guarda, e ainda assim
  seria uma reconstrução — frágil a cada mudança futura de modelagem. A
  invariante "finaliza primeiro" troca a reconstrução por um registro tirado no
  momento certo.
- **Congelar na hora em que o usuário abre a tela Histórico.** Faria o número
  do passado depender de alguém ter aberto uma tela específica. Um trimestre
  não congelado poderia ser corrompido por uma mutação antes da primeira
  visita.
- **Snapshot guardando nomes.** Contradiz a minimização de dados: manteria
  identificação pessoal fora do cadastro vivo, sem o secretário poder editá-la
  ou removê-la de um lugar só.

## Consequências

A migração v4 → v5 é **aditiva**: cria as três tabelas e os índices de
histórico, sem reescrever nenhuma linha existente. Vale para o banco em texto
puro da `alpha.2` e para o criptografado da `alpha.3`
([ADR 0016](0016-local-security-and-encrypted-storage.md)); um aparelho que
pule da `alpha.2` direto para a `alpha.4` roda v4 e v5 na mesma abertura.

O painel do trimestre corrente não muda: continua lendo o estado ao vivo. A
tela Histórico usa os snapshots para os trimestres encerrados e a mesma leitura
ao vivo para o corrente, marcado "em andamento".

O primeiro `loadModule` depois de uma virada de trimestre faz trabalho extra —
uma transação que insere o snapshot. É proporcional ao número de duplas de uma
ala e acontece uma vez por trimestre.

A regra de "não apagar o que tem histórico" ganha uma terceira origem, além de
entrevistas e agendamentos: o escopo de um trimestre concluído. A mensagem ao
usuário explica o motivo e aponta a desativação.
