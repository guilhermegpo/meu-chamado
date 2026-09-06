import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';

/// Armazenamento de segredos pequenos, respaldado pelo mecanismo seguro do
/// sistema operacional.
///
/// A interface existe para os testes: nenhum segredo real toca o disco durante
/// `flutter test`. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
abstract interface class SecureStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Implementação de produção: no Android, `flutter_secure_storage` guarda os
/// valores cifrados (RSA-OAEP + AES-GCM) sob uma chave do Android Keystore.
class SystemSecureStore implements SecureStore {
  SystemSecureStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _guard(() => _storage.read(key: key));

  @override
  Future<void> write(String key, String value) =>
      _guard(() => _storage.write(key: key, value: value));

  @override
  Future<void> delete(String key) => _guard(() => _storage.delete(key: key));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException {
      // A mensagem crua pode citar caminho ou detalhe de plataforma: troca por
      // uma genérica e não repassa o objeto original.
      throw const SecurityStorageException();
    }
  }
}
