# 0001 — Usar Flutter

## Status

Aceito.

## Contexto

O produto começa no Android, precisa de uma interface mobile consistente e deve
manter aberta a possibilidade de avaliar iOS sem duplicar toda a aplicação. O
projeto também precisa ser compreensível e testável por um desenvolvedor júnior.

## Decisão

Usar Flutter e Dart para o aplicativo. Android é a primeira plataforma; suporte
a iOS não faz parte do primeiro marco.

## Alternativas consideradas

- Android nativo com Kotlin: integração excelente, mas sem reutilização futura
  de interface para iOS;
- React Native: ecossistema maduro, porém adicionaria a ponte e decisões do
  ecossistema JavaScript a um produto ainda em fundação;
- aplicação web/PWA: não atende da mesma forma persistência local, integração e
  distribuição Android planejadas.

## Consequências

O ambiente Flutter passa a ser pré-requisito de desenvolvimento. Dependências e
arquitetura devem seguir o ecossistema Dart, e o CI deverá analisar, testar e
construir o aplicativo. Recursos específicos de plataforma continuam possíveis
por plugins ou código nativo quando houver justificativa.
