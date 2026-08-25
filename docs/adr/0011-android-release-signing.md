# 0011 — Adiar a chave de assinatura de release do Android

## Status

Aceito para a `0.1.0-alpha.1`. A decisão de qual chave usar em produção
permanece em aberto e deve ser retomada antes da primeira distribuição pública.

## Contexto

O Android exige que todo APK instalável esteja assinado. O template do Flutter
deixa `android/app/build.gradle.kts` com a configuração abaixo:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Ou seja, `flutter build apk --release` produz hoje um APK assinado com a **chave
de debug**. Ela é gerada automaticamente pelo SDK, é a mesma em qualquer máquina
que use o mesmo `debug.keystore` e não tem nenhuma propriedade de autenticidade.
Um APK assim instala, mas não identifica a origem e não pode ser atualizado por
um pacote assinado com outra chave.

Isso foi verificado, não apenas deduzido do Gradle. Rodando
`flutter build apk --release` e inspecionando o pacote:

```text
$ apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
```

O certificado é idêntico ao do `app-debug.apk`, incluindo o mesmo digest SHA-256.

A assinatura Android também é uma decisão irreversível na prática: depois que
usuários instalam uma versão, só um pacote assinado com a **mesma** chave pode
atualizá-la. Perder a chave significa não conseguir mais atualizar as instalações
existentes; vazá-la significa permitir que terceiros publiquem pacotes que o
sistema aceita como sendo deste aplicativo.

A `0.1.0-alpha.1` fecha o app shell e serve para avaliação, não para
distribuição. Criar uma chave de produção agora, sem definir onde ela é guardada,
quem tem acesso e como é rotacionada em caso de comprometimento, criaria um ativo
crítico sem custódia definida — pior do que não ter chave.

## Decisão

- **Não gerar chave de produção nesta versão.** A configuração de release
  continua apontando para a chave de debug, com o `TODO` do template preservado
  como sinalização explícita.
- **Não publicar APK como se fosse de produção.** A release da
  `0.1.0-alpha.1` no GitHub é marcada como pré-release e serve como registro do
  marco. O APK de debug permanece apenas como artefato de verificação do CI.
- **Nunca versionar keystore, senha ou `key.properties`.** Esses arquivos ficam
  fora do Git; `android/local.properties` e `android/key.properties` já estão
  ignorados.
- Retomar esta decisão antes da primeira distribuição pública, respondendo:
  onde a chave é custodiada, quem tem acesso, como o CI assina sem expor o
  segredo e qual o procedimento em caso de perda ou vazamento.

## Alternativas consideradas

- **Gerar a chave agora e guardar no repositório**: descartado. Chave em
  repositório público é chave comprometida, e mesmo em repositório privado
  mistura ativo de segurança com código.
- **Gerar a chave agora e guardar só na máquina local**: descartado por ora.
  Resolve a assinatura, mas cria ponto único de falha sem backup nem custódia
  definida — exatamente o cenário em que a perda inviabiliza atualizações.
- **Play App Signing** (o Google custodia a chave de upload e assina os
  pacotes): candidato forte quando houver distribuição pela Play Store, porque
  transfere a custódia para um mecanismo com recuperação. Não decidido aqui
  porque a distribuição fora da loja, por GitHub Releases, ainda está em
  avaliação no [ADR 0006](0006-github-releases-updater.md).
- **Assinar no CI com o keystore em GitHub Secrets**: viável e provavelmente o
  caminho quando a chave existir. Depende de decidir antes a custódia, não o
  contrário.

## Consequências

Enquanto esta decisão estiver em aberto:

- não há APK distribuível desta versão, e a documentação não pode sugerir que
  haja;
- quem quiser executar o aplicativo compila a partir do código-fonte;
- o updater descrito no [ADR 0006](0006-github-releases-updater.md) permanece
  bloqueado, porque verificar a origem de uma atualização exige justamente a
  assinatura que ainda não existe.

Quando a chave for criada, o primeiro pacote assinado com ela define a
identidade do aplicativo para sempre nas instalações que o receberem. Por isso a
criação deve vir acompanhada de backup, e não como passo isolado de um build.
