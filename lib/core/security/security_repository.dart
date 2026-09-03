import 'package:meu_chamado/core/security/database_key.dart';
import 'package:meu_chamado/core/security/pin_credential.dart';
import 'package:meu_chamado/core/security/pin_policy.dart';
import 'package:meu_chamado/core/security/secure_store.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';

export 'package:meu_chamado/core/security/security_exceptions.dart';

/// Guarda e confere o material de segurança local: a chave do banco, o
/// verificador do PIN e a preferência de biometria.
///
/// Não sabe nada de UI nem de ciclo de vida — só do que fica no armazenamento
/// seguro. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class SecurityRepository {
  SecurityRepository(this._store, {this._policy = const PinPolicy()});

  final SecureStore _store;
  final PinPolicy _policy;

  // O sufixo `.v1` deixa espaço para trocar o formato sem colidir.
  static const _databaseKeyEntry = 'mc.database_key.v1';
  static const _pinEntry = 'mc.pin_verifier.v1';
  static const _biometricEntry = 'mc.biometric_enabled.v1';

  /// A chave do banco. Cria e persiste na primeira chamada; devolve a mesma nas
  /// seguintes. Nunca é logada.
  Future<String> databaseKey() async {
    final existing = await _store.read(_databaseKeyEntry);
    if (existing != null && existing.isNotEmpty) return existing;

    final created = generateDatabaseKey();
    await _store.write(_databaseKeyEntry, created);
    return created;
  }

  Future<bool> hasDatabaseKey() async {
    final value = await _store.read(_databaseKeyEntry);
    return value != null && value.isNotEmpty;
  }

  Future<bool> isPinConfigured() async {
    final value = await _store.read(_pinEntry);
    return value != null && value.isNotEmpty;
  }

  /// Define ou substitui o PIN. Recusa PINs fracos com [WeakPinException].
  Future<void> setPin(String pin) async {
    final reason = _policy.validate(pin);
    if (reason != null) throw WeakPinException(reason);

    final credential = await PinCredential.create(pin);
    await _store.write(_pinEntry, credential.serialize());
  }

  /// `true` só quando [pin] confere. Lança [SecurityNotConfiguredException] se
  /// não há PIN definido.
  Future<bool> verifyPin(String pin) async {
    final raw = await _store.read(_pinEntry);
    if (raw == null || raw.isEmpty) {
      throw const SecurityNotConfiguredException();
    }
    return PinCredential.deserialize(raw).matches(pin);
  }

  /// Troca o PIN. Exige o atual correto.
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!await verifyPin(currentPin)) {
      throw const InvalidPinException();
    }
    await setPin(newPin);
  }

  Future<bool> isBiometricEnabled() async =>
      (await _store.read(_biometricEntry)) == 'true';

  Future<void> setBiometricEnabled({required bool enabled}) =>
      _store.write(_biometricEntry, enabled ? 'true' : 'false');
}
