# 0016 — Segurança local: bloqueio por PIN e banco criptografado

## Status

Aceito para a `0.2.0-alpha.3`.

## Contexto

Desde a `0.2.0-alpha.2` o app guarda, localmente e em texto puro, dados
administrativos de ministração: identificação mínima de irmãos e de liderança,
duplas, entrevistas realizadas e agendamentos. É pouco por linha
([ADR 0013](0013-ministering-minimal-identification.md)), mas somado é a agenda
administrativa de uma ala inteira, num contexto eclesiástico.

Hoje qualquer pessoa que abra o aparelho desbloqueado vê tudo, e uma cópia do
arquivo `meu_chamado.sqlite` (por backup, cabo ou extração do `/data`) revela o
banco inteiro. O [ADR 0011](0011-android-release-signing.md) trata de assinar o
APK — origem do código. Este ADR trata de outra coisa: proteger os **dados em
repouso** e o **acesso ao app**. São problemas independentes.

A segurança não pode ficar para depois de o histórico crescer: o volume de
dados sensíveis só aumenta.

## Decisão

### Modelo de ameaças

Protege contra:

- acesso casual ao app por outra pessoa com o aparelho desbloqueado;
- leitura do banco copiado do armazenamento (backup, `adb`, cópia de `/data`);
- exposição dos rótulos administrativos guardados no SQLite;
- retomada do app depois de algum tempo fora dele;
- PIN guardado em texto puro;
- chave de criptografia guardada em SQLite ou em preferências em texto puro.

**Não** promete proteção contra:

- aparelho com root ou bootloader comprometido;
- malware com privilégios de sistema;
- atacante com o processo do app comprometido em execução;
- atacante com acesso total ao sistema já desbloqueado e ao Keystore;
- análise forense de RAM com o app aberto.

O detalhe está em
[docs/security/threat-model.md](../security/threat-model.md).

### Chave do banco ≠ PIN

São dois materiais distintos:

1. **Chave do banco** — 32 bytes aleatórios de um CSPRNG (`Random.secure`),
   gerada **uma vez** na primeira execução, guardada **somente** no
   `flutter_secure_storage` (no Android: `EncryptedSharedPreferences` com
   AES-GCM sob chave do Android Keystore, hardware-backed onde houver
   StrongBox/TEE). Nunca derivada do PIN, nunca em `app_preferences`, nunca no
   nome do arquivo, nunca em log, nunca em exceção, nunca no código.

2. **PIN** — fator de desbloqueio da aplicação. Guardado como **verificador**
   PBKDF2-HMAC-SHA256 (150 000 iterações, sal aleatório de 16 bytes), também no
   `flutter_secure_storage`. Comparação em tempo constante. Nunca em texto puro;
   nunca MD5, SHA-1 ou `SHA-256(pin)` simples.

O PIN não desbloqueia o banco — o banco abre com a chave do secure storage. O
PIN protege a **interface**. Assim a biometria pode substituir o PIN sem que
seja preciso re-derivar a chave do banco, e não existe cenário em que esquecer
o PIN torne o banco irrecuperável por design (a recuperação por "redefinir
dados locais" é uma escolha de produto, não uma consequência criptográfica).

Uma versão futura pode envelopar a chave do banco com material derivado do PIN
para defesa em profundidade; a `alpha.3` fica no modelo acima por ser
verificável e por não criar um ponto de perda de dados.

### Banco criptografado

`package:sqlite3` 3.5.x já usa build hooks para embutir o SQLite. O define

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

troca o binário embutido por
[SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) —
implementação de criptografia mantida, auditada e testada. **Não se implementa
criptografia própria e não se aplica AES manual sobre o arquivo.**

`AppDatabase` deixa de usar o helper `driftDatabase(name:)` e passa a abrir um
`NativeDatabase.createInBackground(file, setup: (db) => db.execute("PRAGMA
key = ..."))`. A abertura verifica `PRAGMA cipher` — se o binário não tiver
cifra, é erro de build, não silêncio. Sem a chave correta o arquivo não expõe
tabelas.

### Migração texto puro → criptografado

Bancos `alpha.2` são texto puro no schema v4. A migração é **atômica** e nunca
apaga antes de confirmar:

1. detecta banco texto puro (arquivo abre sem `PRAGMA key`);
2. gera e guarda a chave do banco;
3. cria um arquivo criptografado **novo e temporário**;
4. copia via `ATTACH DATABASE ... KEY ...` + `sqlcipher_export` (do
   SQLite3 Multiple Ciphers); se indisponível, cópia tabela a tabela pelo Drift
   com `PRAGMA foreign_keys = OFF`;
5. abre o arquivo novo com a chave e valida contagem de linhas por tabela e
   `schemaVersion`;
6. só então: renomeia o texto puro para `.pre-encryption.bak`, promove o novo
   ao nome oficial;
7. reabre o oficial; em sucesso, apaga o `.bak`;
8. qualquer falha antes do passo 6 aborta e o banco texto puro original
   continua íntegro e utilizável; falha depois do passo 6 mantém o `.bak` para
   recuperação manual e mostra erro compreensível.

Nenhum segredo aparece em log em nenhum passo.

### Instalação nova

Não cria banco texto puro para depois criptografar: gera a chave e abre já
criptografado no primeiro acesso.

### Bloqueio e ciclo de vida

Estado `locked` quando:

- cold start com segurança configurada;
- retomada após **30 segundos** em segundo plano (padrão fixo nesta versão,
  configurável no futuro).

`AppLifecycleState.inactive` sozinho **não** bloqueia — o prompt de biometria e
o seletor de data deixam o app `inactive` e um lock aí criaria laço
biometria → inactive → lock → biometria. Só `paused` inicia a contagem; um
`resumed` dentro da janela não bloqueia.

### Biometria

Opcional, via `local_auth`. O app recebe do sistema apenas sucesso/falha —
nunca a digital ou o rosto. Sempre há alternativa "Usar PIN". Biometria
indisponível, sem cadastro, cancelada ou com erro nunca tranca o usuário para
fora: cai para o PIN. Ativável/desativável nas Configurações depois que o PIN
existe.

### Tentativas

Atraso progressivo simples, na memória do processo: até 4 erros, sem atraso; a
partir do 5º, atraso crescente com teto de poucos segundos. **Nunca** apagar
dados por tentativas erradas — nem "10 tentativas e apaga tudo".

### Escopo do bloqueio

O bloqueio é do **app**, para o Workspace local. Não há PIN por irmão, por
chamado nem por usuário. Não se mistura com o RBAC do Workspace
(`ADMIN`/`MODERATOR`/`USER`), que é autoridade técnica dentro do app, não
autenticação local.

### Recents / screenshots

As telas com dados sensíveis marcam a janela como segura (`FLAG_SECURE` no
Android) enquanto o app está desbloqueado, ocultando o conteúdo no seletor de
apps e bloqueando captura de tela. O trade-off — impede também screenshots
legítimos — é aceito nesta versão porque as telas mostram a agenda
administrativa da ala.

## Alternativas consideradas

- **Só bloqueio por PIN, banco em texto puro.** Rejeitado: seria segurança
  teatral. A cópia do arquivo continuaria revelando tudo.
- **Derivar a chave do banco direto do PIN.** Rejeitado: PIN de 6 dígitos tem
  10^6 combinações; a chave do banco ficaria tão fraca quanto o PIN, e trocar o
  PIN exigiria re-criptografar o banco inteiro.
- **`sqlcipher_flutter_libs` + `open.overrideFor`.** O pacote está EOL
  (`0.6.0+eol`); o caminho mantido hoje é o define de build do `package:sqlite3`.
- **Criptografia em nível de aplicação (cifrar campos antes de gravar).**
  Rejeitado: esconde só algumas colunas, quebra índices e ordenação, e é
  exatamente o "AES manual" que não se deve fazer.
- **Argon2id no lugar de PBKDF2.** Melhor contra brute force, mas adiciona
  dependência mais pesada. Para um PIN de 6 dígitos guardado sob o Keystore, o
  PBKDF2 com 150k iterações é adequado; a troca fica anotada para o futuro.
- **Apagar dados após N tentativas.** Rejeitado explicitamente: transforma um
  erro de digitação, ou uma criança com o telefone, em perda de dados.

## Consequências

- `AppDatabase` ganha um construtor que exige a chave; os testes passam a abrir
  o banco com uma chave fictícia de teste explícita.
- O primeiro acesso de um usuário `alpha.2` roda a migração antes de qualquer
  tela sensível; a migração é coberta por teste com banco v4 fictício realista,
  incluindo o caminho de falha com rollback.
- `flutter build` passa a baixar o binário do SQLite3 Multiple Ciphers no lugar
  do SQLite padrão — mesma etapa de build hook que já existe, outra origem.
- A documentação descreve exatamente o que o modelo protege e o que não
  protege. Não se diz "100% seguro", "criptografia militar" nem "impossível
  acessar".
- A decisão de assinatura de produção ([ADR 0011](0011-android-release-signing.md))
  continua independente e em aberto.
