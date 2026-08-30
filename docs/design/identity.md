# Identidade visual

## Status

Identidade aplicada no produto. O master atual foi produzido para o projeto por
geração assistida e refinado a partir da variação aprovada pelo responsável do
produto.

## Princípios

- profissional e moderna;
- limpa, calma e reverente;
- legível em telas pequenas;
- independente de marcas oficiais de terceiros;
- reconhecível dentro da família Apps Meu.

## Elemento recorrente

A letra `M` deve orientar o símbolo e a relação entre futuros produtos Apps Meu.
Ela não deve ser combinada com símbolos oficiais religiosos nem sugerir vínculo
institucional.

## Marca escolhida

O tile de navy profundo contém um `M` geométrico em teal e azul, uma arquitetura
branca abstrata e um arco teal. A arquitetura é original e genérica: não inclui
figura humana, estátua, cruz, logotipo ou ativo oficial de Igreja.

Fonte do app:
`assets/branding/meu_chamado_icon_master.png`.

O mesmo master alimenta o launcher Android, o splash nativo e a marca dentro do
Flutter, evitando variações acidentais entre superfícies.

## Paleta

- navy para estrutura e confiança;
- teal para ação e progresso;
- azul como apoio;
- superfícies claras e escuras com contraste verificável.

Os valores canônicos ficam em `lib/app/theme/app_tokens.dart`. Claro e escuro
usam degraus de superfície próprios; testes automatizados verificam contraste
WCAG AA e impedem que os temas voltem a compartilhar uma única superfície.

## Motion

Movimento explica mudança de estado e hierarquia. As durações ficam nos tokens
e são usadas em transições curtas de conteúdo e progresso. Não há animação
ornamental contínua, parallax ou interação dependente de hover.

## Ativos

Usar somente assets próprios ou com licença verificada. Ícones de interface são
os Material Icons distribuídos com Flutter. Dados e fotografias reais não
pertencem a fixtures, screenshots ou materiais públicos do repositório.
