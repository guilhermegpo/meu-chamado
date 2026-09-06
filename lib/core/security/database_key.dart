import 'dart:math';

/// Gera a chave do banco: 32 bytes de um CSPRNG, em hexadecimal (64 caracteres).
///
/// Vira a passphrase do SQLite3 Multiple Ciphers, que roda a própria KDF por
/// cima. Hexadecimal evita aspas e escaping no `PRAGMA key`. Nunca é derivada do
/// PIN e nunca aparece em log. [random] só existe para os testes.
String generateDatabaseKey([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
