# 0013 — Guardar a identificação mínima dos irmãos ministradores

## Status

Aceito.

## Contexto

Para dizer quais duplas faltam entrevistar, o módulo precisa distinguir uma
dupla da outra. Distinguir pessoas dentro de uma ala é, por definição, tratar
dado pessoal — e o contexto é eclesiástico, o que agrava a sensibilidade de
qualquer vazamento.

O aplicativo é independente e não oficial. Não há integração com sistemas da
Igreja e nenhum dado vem de lá.

## Decisão

Guardar um único campo de texto por irmão, `display_label`, de 1 a 60
caracteres, sob orientação explícita na própria tela: primeiro nome ou
iniciais.

Ficam **fora** do schema, e não por esquecimento:

- telefone, endereço, e-mail;
- número de registro de membro ou qualquer identificador oficial;
- famílias e pessoas ministradas;
- conteúdo, anotações ou impressões sobre a entrevista;
- dados de saúde, financeiros ou de dignidade;
- cargo no sacerdócio, situação no quórum, datas de ordenação.

A entidade se chama `MinisteringBrother`, não `QuorumMember`: um jovem ordenado
mestre ou sacerdote pode compor uma dupla sem pertencer ao Quórum de Élderes,
e o nome da entidade não deve afirmar o contrário.

As mensagens de erro do módulo descrevem a regra violada, nunca a pessoa
envolvida. "Há um irmão inativo na seleção" em vez de nomear quem.

## Alternativas consideradas

- **Nome completo**: facilitaria a leitura em alas grandes, ao custo de tornar
  o banco local um cadastro nominal completo do quórum. A orientação na tela
  não impede alguém de digitar o nome inteiro, mas o padrão sugerido e o limite
  de 60 caracteres empurram para o mínimo.
- **Identificador opaco sem rótulo**: protegeria mais, mas o secretário não
  conseguiria usar a tela — ele precisa reconhecer de quem se trata.
- **Importar dados de sistema oficial**: fora de escopo e fora de autorização.

## Consequências

O módulo funciona com o mínimo que permite reconhecer uma dupla, e não mais.
Uma cópia do banco vazada revela rótulos curtos e a agenda administrativa de
entrevistas — não um cadastro nominal com contatos.

Fixtures, testes e capturas de tela usam somente dados fictícios
(`Irmão A`, `Irmão B`, `Workspace Demo`). Nenhum dado real entra no
repositório, conforme
[docs/privacy/data-boundaries.md](../privacy/data-boundaries.md).

O lembrete de privacidade aparece na tela onde a identificação é digitada, não
apenas nesta documentação: é ali que a decisão é tomada.
