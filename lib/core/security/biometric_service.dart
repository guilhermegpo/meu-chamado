import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// O que o app precisa saber sobre a biometria. Interface para testar sem
/// hardware.
///
/// O app recebe do sistema apenas sucesso ou falha — nunca a digital ou o
/// rosto. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
abstract interface class BiometricService {
  /// `true` quando o aparelho tem hardware e ao menos uma biometria cadastrada.
  Future<bool> isAvailable();

  /// Pede a biometria. Devolve `true` só num reconhecimento bem-sucedido.
  /// Cancelamento, indisponibilidade ou erro devolvem `false` — nunca lançam
  /// para fora, para o app poder cair no PIN.
  Future<bool> authenticate(String reason);
}

class SystemBiometricService implements BiometricService {
  SystemBiometricService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
