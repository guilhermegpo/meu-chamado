# 0006 — Distribuir atualizações pelo GitHub Releases

## Status

Proposto.

## Contexto

O aplicativo poderá ser distribuído fora de uma loja na fase inicial. Usuários
precisam identificar versões e verificar integridade sem usar o Google Drive
como canal de software.

## Decisão

Planejar consulta ao GitHub Releases para canais Stable e Beta. Uma atualização
baixará o APK completo, exibirá changelog, verificará SHA-256 e seguirá o fluxo
Android de instalação. Delta binário não entra no escopo inicial.

## Alternativas consideradas

- Google Drive: mistura dados do Workspace com distribuição e não oferece um
  fluxo de release adequado;
- servidor próprio: aumenta operação e custo;
- loja oficial: continua uma alternativa futura, sujeita a requisitos de conta,
  política e publicação.

## Consequências

Releases precisarão ser assinadas, reproduzíveis e protegidas. O keystore ficará
fora do Git, em secrets/environment apropriado. Este ADR só será aceito após
pesquisa do fluxo Android e modelo de confiança.
