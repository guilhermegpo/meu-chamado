# 0005 — Avaliar Google Drive como provedor de sync

## Status

Proposto.

## Contexto

Um Workspace compartilhado pode precisar de um meio acessível de troca de dados
sem operar um backend próprio. Os dados incluem limites de privacidade que não
podem ser ignorados.

## Decisão

Avaliar Google Drive como `GoogleDriveStorageProvider`, com privilégio mínimo,
escopo semelhante a `drive.file` e seleção explícita de pasta quando possível.
Apenas uma allowlist de `WorkspaceSharedData` poderá ser sincronizada.

## Alternativas consideradas

- backend próprio: oferece controle e concorrência, mas exige operação,
  autenticação e custo ainda não justificados;
- Firebase/Supabase: bons recursos, porém introduzem backend e modelo de conta
  antes de validar o produto;
- sincronizar o SQLite: rejeitado por risco de corrupção e conflito.

## Consequências

Antes de aceitar este ADR serão necessários protótipo, política de conflitos,
manifesto versionado, revogação, recuperação, análise de OAuth e revisão dos
dados permitidos. Google Drive não faz parte da primeira build.
