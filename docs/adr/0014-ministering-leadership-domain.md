# 0014 — Registrar a liderança que conduz as entrevistas

## Status

Aceito.

## Contexto

A `0.2.0-alpha.1` registrava a entrevista realizada, mas não quem a conduziu.
O Manual atribui a entrevista de ministração à presidência do Quórum de
Élderes, e o Secretário — que organiza a agenda — normalmente não é quem
entrevista. Para agendar uma entrevista (ver
[ADR 0015](0015-ministering-scheduling-model.md)) e para dizer no histórico
quem a conduziu, o módulo precisa de uma noção própria de "líder".

O app já tem um domínio de papéis: `WorkspaceRole` (`ADMIN`, `MODERATOR`,
`USER`), definido pelo RBAC central. Esse papel é técnico — quem pode operar o
aplicativo — e não representa autoridade eclesiástica. Reaproveitá-lo para
dizer quem entrevista misturaria as duas coisas.

## Decisão

Modelar a liderança como entidade separada, no schema local v4.

1. **Tabela `ministering_leaders` própria.** `id`, `calling_id`,
   `display_label` (1 a 60 caracteres), `role`, `is_active` e carimbos de
   tempo. `UNIQUE (id, calling_id)` para ser alvo da FK composta do
   agendamento. Isolada por `calling_id` como todo o resto do módulo.
2. **`role` guardado como texto.** `QUORUM_PRESIDENT`, `FIRST_COUNSELOR` ou
   `SECOND_COUNSELOR`, pela mesma razão dos demais enums do app: a coluna
   descreve um cargo e um cargo novo entra sem migração de tipo. A ordem de
   declaração do enum é a hierarquia usada para ordenar a lista.
3. **O entrevistador é sempre escolhido de propósito.** Nunca inferido do
   usuário logado. Organizar a agenda não torna o Secretário entrevistador.
4. **Identificação mínima, igual à do irmão ministrador.** Só `display_label`,
   com orientação na tela: primeiro nome ou iniciais. Sem telefone, endereço,
   número de registro, cargo no sacerdócio ou notas — a mesma fronteira da
   [ADR 0013](0013-ministering-minimal-identification.md). As mensagens de
   erro descrevem a regra, não a pessoa.
5. **`interviewer_id` na entrevista realizada.** Coluna nova em
   `ministering_interviews`, `REFERENCES ministering_leaders (id)` com
   `ON DELETE RESTRICT`. É anulável **apenas** para as entrevistas gravadas
   antes da v4; todo caminho de gravação da v4 em diante informa o
   entrevistador. A FK é de coluna única, não composta por `calling_id` como
   as demais do módulo, porque `ALTER TABLE ADD COLUMN` do SQLite não aceita
   restrição composta e recriar a tabela de entrevistas — que
   `ministering_interview_participants` referencia — custaria mais do que a
   garantia vale. O repositório valida que o entrevistador é do mesmo
   chamado.
6. **Desativar em vez de apagar.** Um líder que sai da presidência fica
   `is_active = false`: sai da seleção de novos agendamentos e permanece no
   histórico das entrevistas que conduziu. Excluir de vez só quando o líder
   nunca foi usado — sem agendamento aberto e sem entrevista no histórico.
7. **`MinisteringLeader`, não `QuorumPresidency`.** A entidade nomeia a função
   no módulo (quem entrevista), não um órgão eclesiástico.

## Alternativas consideradas

- **Reusar `WorkspaceRole` ou inferir o entrevistador do usuário logado.**
  Acoplaria autoridade eclesiástica ao papel técnico e ao login. O Secretário
  costuma ser `ADMIN` ou `MODERATOR` e não é quem entrevista; um conselheiro
  pode nem usar o aplicativo.
- **`role` como inteiro.** Índice mais barato, ao custo de um valor opaco no
  banco e de uma migração de tipo a cada cargo novo. O volume é de três a
  quatro linhas por chamado — o índice não é o gargalo.
- **FK composta `(interviewer_id, calling_id)` na entrevista, como nas outras
  tabelas.** Impossível de adicionar por `ALTER TABLE` no SQLite; exigiria
  recriar `ministering_interviews` e a tabela de participantes que a
  referencia. A validação de chamado no repositório cobre o caso real.
- **Campo de texto livre "entrevistador" na entrevista.** Voltaria a guardar
  nome solto, sem ciclo ativo/inativo e sem impedir citar alguém de outro
  chamado.

## Consequências

O agendamento ([ADR 0015](0015-ministering-scheduling-model.md)) aponta para
um líder por FK composta, com o isolamento por chamado garantido no banco. A
entrevista realizada aponta por FK de coluna única, com o isolamento
garantido pelo repositório.

Entrevistas anteriores à v4 ficam com `interviewer_id` nulo e a interface as
mostra sem entrevistador — elas são anteriores ao recurso e não há dado a
inventar.

A migração v3 → v4 é aditiva: cria `ministering_leaders`, adiciona a coluna
`interviewer_id` quando o banco vem exatamente da v3 e cria
`ministering_appointments`. Nenhuma linha existente é reescrita.

Sem liderança ativa cadastrada, registrar ou agendar uma entrevista fica
indisponível e a interface direciona ao cadastro de liderança, em vez de
gravar uma entrevista sem responsável.
