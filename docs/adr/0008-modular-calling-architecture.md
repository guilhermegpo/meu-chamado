# 0008 — Isolar regras em módulos de chamado

## Status

Aceito.

## Contexto

Secretário da Ministração e Secretário da Escola Dominical possuem rotinas
diferentes. Um módulo único cheio de condicionais se tornaria difícil de
explicar, testar e estender.

## Decisão

Definir um contrato conceitual `CallingModule` e implementar cada tipo de
chamado como feature própria sobre infraestrutura genuinamente compartilhada.
O domínio nunca depende de nomes de usuários específicos.

## Alternativas consideradas

- um grande módulo com `if` por tipo: rápido no início, mas acopla regras e
  amplia regressões;
- aplicativo separado por chamado: duplica Workspace, perfil, tema e segurança;
- configuração totalmente dinâmica: flexível, mas não representa bem regras de
  domínio complexas na primeira versão.

## Consequências

Cada módulo declara capacidades, rotas e regras próprias e recebe testes
independentes. Infraestrutura compartilhada deve permanecer pequena. Diretórios
dos módulos só serão criados quando houver implementação real.
