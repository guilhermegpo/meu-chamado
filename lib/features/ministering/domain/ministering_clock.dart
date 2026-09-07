/// Relógio injetável do módulo de ministração.
///
/// O histórico trimestral depende de "qual trimestre é hoje" para decidir o que
/// já pode ser congelado. Um `DateTime.now()` cravado no repositório tornaria a
/// virada de trimestre impossível de testar sem mexer no relógio do sistema.
/// É só um `typedef` — nenhuma dependência nova.
typedef MinisteringClock = DateTime Function();

/// Relógio padrão: a hora do aparelho.
DateTime systemClock() => DateTime.now();
