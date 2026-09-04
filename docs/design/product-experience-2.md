# Product Experience 2.0

## Status

Refresh de apresentação aplicado entre a `0.2.0-alpha.3` e a `0.2.0-alpha.4`.
Milestone interno: **não** mexe em schema, migrações, RBAC, Ministração,
liderança, agendamento, PIN, biometria, banco criptografado, lifecycle lock
nem em nenhuma regra de domínio. Nenhuma feature nova.

A meta é um acabamento compatível com um app mobile comercial atual: rápido,
calmo, organizado, contextual, consistente e seguro.

## Princípio central

> A UI não reflete a estrutura do banco. Ela reflete a intenção do usuário.

Cada tela abre respondendo "o que a pessoa precisa resolver aqui agora?" — o
estado operacional antes da administração.

## Design system

Tudo em [`lib/app/theme/app_tokens.dart`](../../lib/app/theme/app_tokens.dart) e
[`app_theme.dart`](../../lib/app/theme/app_theme.dart).

- **Tipografia** — hierarquia editorial: Display 32/36 (único peso alto),
  Headline 26/30, Title 20/24, Body Large 16/24, Body 14/21, Label 12/16.
  Abaixo do Display o contraste vem do tamanho e da entrelinha, não de mais
  bold.
- **Spacing** — ritmo 4·8·12·16·20·24·32·40·48. Recuo de tela padrão 20dp
  (`Spacing.screenGutter`); telas mais densas podem ir a 24.
- **Raio** — `compact` (10), `control` (14), `surface` (20), `emphasis` (28).
- **Superfícies** — cinco degraus declarados nos dois temas; card não depende
  do tom que o Material derivaria sozinho. Menos "card dentro de card".
- **Cores** — navy/teal/azul/off-white/charcoal. Claro e escuro são
  construídos pelo mesmo caminho, com as superfícies explícitas nos dois;
  escuro não é o claro invertido.
- **Touch target** — 48 mínimo, 52 para controles primários.
- **Elevação** — `flat`/`raised`/`floating`/`overlay`; sombra vem de
  `AppShadows.soft`.

## Motion

`Motion` conceitual: `instant` 100ms · `micro` 180ms · `component` 240ms ·
`page` 300ms · `sheet` 320ms. `Motion.adaptive(context, d)` colapsa para
`Duration.zero` quando o sistema pede "reduzir movimento". A animação explica
estado ou navegação — nunca decora. Sem visual gamer, sem gradiente em excesso,
sem efeito lento.

## Haptics

Camada semântica em
[`lib/shared/feedback/app_haptics.dart`](../../lib/shared/feedback/app_haptics.dart).
As telas chamam a intenção, nunca o primitivo:

| Situação | Chamada |
| --- | --- |
| trocar aba, mover seleção | `selection()` |
| alternar switch/checkbox | `toggle()` |
| salvar cadastro / editar | `saved()` (light) |
| entrevista registrada / concluída, bloquear agora | `milestone()` (medium) |
| ação destrutiva confirmada | `destructive()` (medium) |
| PIN incorreto, validação que barra o envio | `warning()` |

## Componentes novos

- **`AppFormSheet` / `showAppFormSheet`** — folha inferior para operações
  rápidas (agendar, reagendar, registrar, corrigir, editar entidade). Ciente
  do teclado, largura própria constrangida, corpo rola, ações sempre
  alcançáveis via `OverflowBar`. Diálogos ficam só para confirmação curta e
  ação destrutiva.
- **`showAppActionSheet` / `AppAction`** — menu de ações contextuais de uma
  entidade, no lugar do menu de três pontos: alvos maiores e um título.
- **`AppSkeletonBox` / `AppSkeletonList`** — carregamento com a forma do
  conteúdo, no lugar do giro central. Pulsa devagar e para sob "reduzir
  movimento".
- **`AppInitialAvatar`** — inicial da pessoa em listas (Ministração guarda
  identificação mínima, sem foto).

## Telas

- **App shell** — navbar Início · Chamados · Perfil · Mais, sem botão central.
  Ícone outlined inativo / filled ativo, transição no token `component`,
  háptico de seleção ao trocar de aba.
- **Início** — saudação pelo período do dia, depois o estado operacional de
  cada chamado com módulo pronto (trimestre, `X de Y` duplas, próxima ação),
  carregado com esqueleto, e só então a lista administrativa. Não é um menu de
  atalhos.
- **Ministração** — o card do trimestre é um único herói (rótulo do chamado
  como sobrescrito, sem card sobre card). Ordem: trimestre → `X de Y` →
  próximas entrevistas → pendentes → entrevistadas → seção "Gerenciar"
  (Duplas, Irmãos, Liderança).
- **Listas (Irmãos, Duplas, Liderança)** — linha limpa: avatar/ícone, rótulo,
  estado; um toque abre a folha de ações. Ordem da liderança: Presidente,
  1º Conselheiro, 2º Conselheiro.
- **Configurações / Mais** — grupos rotulados: PREFERÊNCIAS (Aparência,
  Segurança), WORKSPACE (Gerenciar usuários), APLICATIVO (Privacidade,
  Versão). Segurança é parte das preferências — o bloqueio é do app.
- **Loading / Empty / Error** — esqueleto contextual; empty state aponta a
  próxima ação; erro permite retry e explica sem alarmismo, nunca stack trace.

## Responsividade e acessibilidade

Validado em teste de widget
([`test/design/responsive_a11y_test.dart`](../../test/design/responsive_a11y_test.dart)):
320 / 360 / 390 / 430px e escala de texto 1.5 sem overflow, e o esqueleto
estático sob "reduzir movimento". Nenhuma largura fixa que cause overflow — o
`width: 380` dos antigos diálogos saiu.

## Overrides das referências

O Reference Pack é contrato de linguagem visual, não de funcionalidade. O
código e os ADRs vencem a imagem. Não foi copiado das REFs:

- botão `+` central na navbar;
- percentual isolado como KPI (fica `X de Y duplas entrevistadas`; a barra é
  discreta e complementa);
- login por e-mail/senha, 2FA, convite online — a segurança é PIN local +
  biometria opcional + banco criptografado, sem recuperação pela internet;
- campos sensíveis extras na Ministração (telefone, e-mail, nascimento,
  endereço, notas, famílias ministradas, dados do LCR);
- Google Drive, sync, updater, notificações;
- logos, símbolos ou assets oficiais da Igreja — o app é independente e não
  oficial;
- nomes, cargos e números das imagens não viram regra de negócio.

## Decisões

- **Editores em folha, confirmações em diálogo.** Folha dá largura útil no
  celular e sobe do polegar; confirmação curta/destrutiva continua diálogo
  bloqueante.
- **Ações da entidade em folha, não em menu de três pontos.** Mesma folha no
  toque da linha e no ícone de overflow.
- **Trimestre como herói único.** A intro separada virava card sobre card.
- **"Gerenciar" como seção, não ícones no app bar.** Os três ícones eram
  crípticos; a seção fica depois do estado do trimestre — o "onde configuro"
  vem depois do "o que falta".
- **Voltar de uma subtela mantém a rolagem do painel.** O teste rola até o
  card do trimestre; um usuário faz o mesmo gesto. (Pendência conhecida:
  rolar o painel ao topo ao retornar seria mais gentil.)
