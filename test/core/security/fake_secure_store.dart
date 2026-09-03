import 'package:meu_chamado/core/security/secure_store.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';

/// `SecureStore` de teste: um mapa na memória. Nenhum segredo real toca o
/// disco durante `flutter test`.
class FakeSecureStore implements SecureStore {
  final Map<String, String> values = {};
  bool failing = false;

  @override
  Future<String?> read(String key) async {
    if (failing) throw const SecurityStorageException();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failing) throw const SecurityStorageException();
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failing) throw const SecurityStorageException();
    values.remove(key);
  }
}
