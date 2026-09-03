# Modelo de domínio

## Workspace

Limite principal de organização e autorização. Possui identificador, nome, tipo
e membros. Tipos previstos:

- `LOCAL`: dados no aparelho, sem conta externa; o primeiro usuário é `ADMIN`;
- `SHARED`: compartilhamento opcional, com membros e provedor externo futuro.

Um Workspace local deve poder se tornar compartilhado por migração explícita,
auditável e sem perda silenciosa de dados.

## User

Identidade interna do aplicativo. Pode conter nome, foto, preferências e
referências aos chamados. Dados de demonstração e testes devem ser fictícios.

## Membership

Relaciona `User` e `Workspace` e carrega o papel naquele contexto. O mesmo
usuário pode participar de Workspaces diferentes com papéis diferentes.

## Role

### ADMIN

Administra membros, papéis, chamados, configurações, backup e sincronização. Um
Workspace deve conservar pelo menos um `ADMIN`.

### MODERATOR

Executa tarefas operacionais: criar usuário, editar nome/foto e adicionar ou
arquivar chamados. Não exclui usuários, não altera papéis e não obtém acesso
automático a conteúdo privado interno de chamado.

### USER

Acessa o próprio perfil, os próprios chamados e preferências. Em Workspace
compartilhado pode ver a existência dos perfis cadastrados, sem abrir conteúdo
privado de outra pessoa por padrão.

## Calling

Vínculo de uma pessoa com um tipo de chamado. Estados iniciais:

- `ACTIVE`;
- `ARCHIVED`.

Arquivar representa encerramento normal. Exclusão definitiva é operação
separada, explícita e sujeita a confirmação.

O modelo suporta zero, um ou vários chamados por usuário.

## CallingModule

Contrato conceitual para módulos que possuem regras próprias. Primeiros módulos
planejados:

```text
CallingModule
├── MinisteringSecretaryModule
├── SundaySchoolSecretaryModule
└── FutureCallingModule
```

Os módulos compartilham somente infraestrutura genuinamente genérica. Regras de
ministração não devem ser forçadas sobre Escola Dominical, e nenhuma regra pode
depender de nomes de pessoas específicas.

## Módulo do Secretário da Ministração

Implementado a partir da `0.2.0-alpha.1`. Todas as entidades pertencem a um
`Calling` e nenhuma consulta atravessa essa fronteira.

### MinisteringBrother

Irmão que pode compor uma dupla. Guarda apenas uma identificação curta e o
estado ativo/inativo — ver
[ADR 0013](../adr/0013-ministering-minimal-identification.md). Não é sinônimo
de membro do quórum: um jovem ordenado mestre ou sacerdote pode compor uma
dupla sem pertencer ao Quórum de Élderes.

### MinisteringCompanionship

Dupla de dois ou três integrantes, com rótulo próprio opcional. Inativa, sai do
denominador do trimestre e mantém as entrevistas que já teve.

### MinisteringInterview

Entrevista **realizada**. Não possui status: a existência do registro é o fato.
Não possui ano nem trimestre: ambos derivam de `completedAt` — ver
[ADR 0012](../adr/0012-ministering-quarterly-model.md). Mais de uma entrevista
da mesma dupla no mesmo trimestre é permitida, e o resumo conta duplas
distintas, não entrevistas.

### Quarter

Valor derivado, nunca persistido. Define a janela meio aberta
`start <= completedAt < nextStart` usada em toda contagem trimestral.

### Invariantes do módulo

- uma dupla tem de dois a três integrantes, sem repetição, todos ativos e do
  mesmo chamado;
- participante de entrevista compõe a dupla entrevistada;
- data de entrevista não está no futuro;
- irmão e dupla são desativados, nunca apagados;
- alcançar registro de outro chamado responde "registro não encontrado".

## Invariantes iniciais

- o primeiro usuário de um Workspace local recebe `ADMIN`;
- todo Workspace mantém ao menos um `ADMIN`;
- autorização é avaliada dentro do Workspace atual;
- `MODERATOR` não promove, rebaixa ou exclui membros;
- conteúdo privado de chamado não se torna compartilhado por associação;
- transições de status são explícitas e testáveis.
