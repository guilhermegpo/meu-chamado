import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:meu_chamado/core/security/biometric_service.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';

/// `AppLock` que já começa liberado, sem tocar no armazenamento seguro nem no
/// banco. Para os testes de widget que não estão exercitando a segurança.
class UnlockedAppLock extends AppLock {
  @override
  Future<AppLockPhase> build() async => AppLockPhase.unlocked;
}

class _NoBiometrics implements BiometricService {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

/// Overrides que fazem o app entrar direto, já desbloqueado.
List<Override> unlockedSecurityOverrides() => [
  appLockProvider.overrideWith(UnlockedAppLock.new),
  biometricServiceProvider.overrideWithValue(_NoBiometrics()),
];
