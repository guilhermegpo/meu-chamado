import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/core/security/biometric_service.dart';
import 'package:meu_chamado/core/security/secure_store.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';

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

class NoBiometrics implements BiometricService {
  const NoBiometrics();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

/// `AppLock` que já começa liberado, sem tocar no armazenamento seguro nem no
/// banco. Para os testes de widget que não estão exercitando a segurança.
class UnlockedAppLock extends AppLock {
  @override
  Future<AppLockPhase> build() async => AppLockPhase.unlocked;
}

/// Overrides que fazem o app entrar direto, já desbloqueado, sem plataforma.
List<Override> unlockedSecurityOverrides() => [
  appLockProvider.overrideWith(UnlockedAppLock.new),
  secureStoreProvider.overrideWithValue(FakeSecureStore()),
  biometricServiceProvider.overrideWithValue(const NoBiometrics()),
];

/// Overrides para exercitar o `AppLock` de verdade: armazenamento seguro e
/// biometria fingidos, e um banco em memória no lugar do criptografado.
List<Override> securityHarnessOverrides({
  FakeSecureStore? store,
  BiometricService? biometrics,
}) {
  // Cada teste tem seu banco em memória próprio; não há corrida de verdade.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final database = AppDatabase(NativeDatabase.memory());
  return [
    secureStoreProvider.overrideWithValue(store ?? FakeSecureStore()),
    biometricServiceProvider.overrideWithValue(
      biometrics ?? const NoBiometrics(),
    ),
    appDatabaseProvider.overrideWith((ref) async {
      ref.onDispose(database.close);
      return database;
    }),
  ];
}
