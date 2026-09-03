import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Verificador do PIN. Nunca guarda o PIN — guarda o resultado de
/// PBKDF2-HMAC-SHA256 sobre ele, com sal aleatório.
///
/// Formato serializado: `pbkdf2-sha256$<iteracoes>$<salBase64>$<hashBase64>`.
/// Ver [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class PinCredential {
  const PinCredential._({
    required this.iterations,
    required this.salt,
    required this.hash,
  });

  static const _algorithm = 'pbkdf2-sha256';

  /// Alto o bastante para tornar o brute force de um PIN de 6 dígitos custoso,
  /// baixo o bastante para não travar o desbloqueio num aparelho modesto.
  static const defaultIterations = 150000;

  static const _saltLengthBytes = 16;
  static const _hashLengthBits = 256;

  final int iterations;
  final List<int> salt;
  final List<int> hash;

  /// Deriva um verificador novo para [pin]. [random] só existe para os testes.
  static Future<PinCredential> create(
    String pin, {
    int iterations = defaultIterations,
    Random? random,
  }) async {
    final rng = random ?? Random.secure();
    final salt = List<int>.generate(_saltLengthBytes, (_) => rng.nextInt(256));
    final hash = await _derive(pin, salt, iterations);
    return PinCredential._(iterations: iterations, salt: salt, hash: hash);
  }

  /// Compara em tempo constante: não vaza quantos bytes bateram.
  Future<bool> matches(String pin) async {
    final candidate = await _derive(pin, salt, iterations);
    return _constantTimeEquals(candidate, hash);
  }

  String serialize() => [
    _algorithm,
    iterations,
    base64.encode(salt),
    base64.encode(hash),
  ].join(r'$');

  static PinCredential deserialize(String value) {
    final parts = value.split(r'$');
    if (parts.length != 4 || parts.first != _algorithm) {
      throw const FormatException('Verificador de PIN inválido.');
    }
    return PinCredential._(
      iterations: int.parse(parts[1]),
      salt: base64.decode(parts[2]),
      hash: base64.decode(parts[3]),
    );
  }

  static Future<List<int>> _derive(
    String pin,
    List<int> salt,
    int iterations,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _hashLengthBits,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
