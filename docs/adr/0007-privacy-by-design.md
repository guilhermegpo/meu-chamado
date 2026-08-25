# 0007 — Tratar privacidade como limite arquitetural

## Status

Aceito.

## Contexto

Chamados podem envolver dados pessoais e religiosos. Um repositório público e um
Workspace compartilhado elevam o risco de coleta e exposição indevidas.

## Decisão

Separar `WorkspaceSharedData` de `PrivateCallingData`, minimizar dados, usar
fixtures fictícias e negar compartilhamento por padrão. Logs, backups, sync e
screenshots seguem o mesmo limite.

## Alternativas consideradas

- decidir privacidade apenas ao implementar sync: tarde demais para corrigir
  domínio e persistência;
- compartilhar todo o banco com controle por tela: não impede cópia ou acesso no
  provedor;
- anonimizar somente na UI: dados brutos continuariam expostos em storage/log.

## Consequências

Novas features precisam classificar seus dados e justificar coleta, retenção e
compartilhamento. Testes e revisão de código incluem vazamento em logs e fixtures.
Algumas conveniências podem ser rejeitadas quando não houver base segura.
