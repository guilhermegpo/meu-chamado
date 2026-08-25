# Modelo de ameaças inicial

## Status

Documento de fundação. Deve ser atualizado quando armazenamento, autenticação,
sincronização ou distribuição forem implementados.

## Ativos

- perfis e preferências dos usuários;
- dados privados de chamados;
- banco local e backups;
- papéis e permissões do Workspace;
- credenciais de provedores externos;
- integridade do APK e canal de atualização.

## Ameaças prioritárias

| Ameaça | Consequência | Controle planejado |
|---|---|---|
| elevação de papel | acesso administrativo indevido | autorização central, invariantes e testes |
| acesso cruzado entre perfis | exposição de dados privados | escopo por usuário/Workspace e deny by default |
| segredo versionado | comprometimento externo | `.gitignore`, revisão, secret scanning e CI |
| backup ou log com dados reais | vazamento indireto | sanitização, minimização e documentação |
| sync excessivo | dados privados no Drive | limites de dados e allowlist de campos |
| APK adulterado | execução de código não confiável | assinatura, SHA-256 e release protegido |
| remoção do último ADMIN | Workspace sem administração | invariante transacional |

## Fronteiras de confiança

- interface do usuário para casos de uso;
- casos de uso para banco local;
- banco local para backup;
- aplicativo para Google Drive futuro;
- aplicativo para GitHub Releases futuro;
- pipeline de CI para artefato assinado futuro.

## Controles de desenvolvimento

- nenhum secret, keystore ou dado real no Git;
- dependências fixadas e atualizadas por PR;
- permissões mínimas em workflows;
- testes de RBAC e rotas protegidas desde o início;
- mensagens e logs sanitizados;
- dados de teste sempre fictícios;
- revisão do modelo antes de cada integração externa.

## Fora do escopo atual

Não existe ainda autenticação Google, sincronização, updater ou release assinado.
Os controles correspondentes são requisitos de projeto, não garantias atuais.
