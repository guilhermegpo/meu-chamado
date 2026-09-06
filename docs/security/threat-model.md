# Modelo de ameaças inicial

## Status

Documento de fundação. Deve ser atualizado quando armazenamento, autenticação,
sincronização ou distribuição forem implementados.

A `0.2.0-alpha.3` implementa a seção **Segurança local** abaixo
([ADR 0016](../adr/0016-local-security-and-encrypted-storage.md)).

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

## Segurança local (`0.2.0-alpha.3`)

O app guarda localmente a agenda administrativa de ministração de uma ala:
identificação mínima de irmãos e liderança, duplas, entrevistas realizadas e
agendamentos. Pouco por linha, sensível no conjunto e no contexto.

### Protege contra

| Ameaça | Consequência | Controle |
|---|---|---|
| acesso casual com o aparelho desbloqueado | outra pessoa lê a agenda da ala | bloqueio do app por PIN antes de qualquer tela sensível |
| retomar o app depois de sair | sessão aberta esquecida | relock após 30 s em segundo plano e no cold start |
| cópia do banco (backup, `adb`, `/data`) | banco inteiro legível fora do app | banco criptografado com SQLite3 Multiple Ciphers |
| PIN em texto puro | brute force trivial do verificador | verificador PBKDF2-HMAC-SHA256, 150k iterações, sal aleatório |
| chave do banco em local acessível | criptografia inútil | chave aleatória só no `flutter_secure_storage` (Keystore) |
| conteúdo sensível no seletor de apps / screenshot | vazamento por captura | `FLAG_SECURE` nas telas desbloqueadas |
| brute force de PIN dentro do app | adivinhação do PIN de 6 dígitos | atraso progressivo após 5 erros, com teto |

### Não promete proteção contra

- aparelho com root ou bootloader comprometido;
- malware com privilégios de sistema;
- processo do app comprometido em execução;
- atacante com o sistema já desbloqueado e acesso ao Android Keystore;
- análise de RAM com o app aberto.

### Decisões

- **Chave do banco ≠ PIN.** Chave: 32 bytes de CSPRNG, gerada uma vez, só no
  secure storage. PIN: fator de desbloqueio da interface, guardado como
  verificador derivado.
- **Não apagar dados por tentativas erradas**, em hipótese alguma.
- **Biometria é opcional** e nunca é o único método: sempre há o PIN.
- Migração texto puro → criptografado é atômica, valida antes de promover e
  preserva o original até a confirmação.
- Nenhum segredo (PIN, chave, rótulos, conteúdo de entrevista, caminho com
  segredo) aparece em log ou exceção.

## Fora do escopo atual

Não existe ainda autenticação Google, sincronização, updater ou release
assinado. Os controles correspondentes são requisitos de projeto, não garantias
atuais. A criptografia de dados (este documento) é independente da assinatura do
APK ([ADR 0011](../adr/0011-android-release-signing.md)).
