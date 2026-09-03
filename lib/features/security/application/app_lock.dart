import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/security/unlock_throttle.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';

/// Em que estado a proteção do app está.
enum AppLockPhase {
  /// Ainda não há PIN — a próxima tela é a configuração.
  needsSetup,

  /// Há PIN e o app está trancado.
  locked,

  /// Liberado: o resto do app pode aparecer.
  unlocked,
}

/// Tempo em segundo plano a partir do qual o app volta trancado.
const appLockGracePeriod = Duration(seconds: 30);

/// Controla o bloqueio do app e observa o ciclo de vida.
///
/// Só `paused` inicia a contagem de carência; `inactive` (seletor de data,
/// prompt de biometria) é ignorado, para não criar laço com a biometria.
/// Ver [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class AppLock extends AsyncNotifier<AppLockPhase> {
  final UnlockThrottle _throttle = UnlockThrottle();
  _LifecycleBridge? _bridge;
  DateTime? _pausedAt;

  /// Relógio — trocado só nos testes de ciclo de vida.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  UnlockThrottle get throttle => _throttle;

  @override
  Future<AppLockPhase> build() async {
    _bridge ??= _LifecycleBridge(this)..attach();
    ref.onDispose(() => _bridge?.detach());

    // Só libera o app depois que o banco criptografado abriu (o que inclui a
    // migração de um banco texto puro da alpha.2).
    await ref.watch(appDatabaseProvider.future);

    final configured = await ref
        .watch(securityRepositoryProvider)
        .isPinConfigured();
    return configured ? AppLockPhase.locked : AppLockPhase.needsSetup;
  }

  /// Chamado quando a configuração inicial do PIN termina.
  void completeSetup() {
    _throttle.registerSuccess();
    state = const AsyncData(AppLockPhase.unlocked);
  }

  void unlock() {
    _throttle.registerSuccess();
    state = const AsyncData(AppLockPhase.unlocked);
  }

  /// Desbloqueio por PIN. Devolve `null` em sucesso ou a frase da recusa.
  Future<String?> submitPin(String pin) async {
    if (_throttle.isLockedOut) {
      return _waitMessage();
    }
    final matched = await ref.read(securityRepositoryProvider).verifyPin(pin);
    if (matched) {
      unlock();
      return null;
    }
    _throttle.registerFailure();
    return _throttle.isLockedOut ? _waitMessage() : 'PIN incorreto.';
  }

  /// Desbloqueio por biometria. Devolve `true` só num reconhecimento válido;
  /// qualquer outra saída mantém a tela de PIN.
  Future<bool> submitBiometric() async {
    final security = ref.read(securityRepositoryProvider);
    if (!await security.isBiometricEnabled()) return false;
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate('Desbloquear o Meu Chamado');
    if (ok) unlock();
    return ok;
  }

  String _waitMessage() {
    final seconds = _throttle.remainingLockout.inSeconds + 1;
    return 'Muitas tentativas. Aguarde $seconds s e tente de novo.';
  }

  /// Volta imediatamente para a tela de bloqueio ("Bloquear agora").
  void lockNow() {
    if (state.value == AppLockPhase.needsSetup) return;
    state = const AsyncData(AppLockPhase.locked);
  }

  @visibleForTesting
  void onPaused() => _pausedAt = clock();

  @visibleForTesting
  void onResumed() {
    final since = _pausedAt;
    _pausedAt = null;
    if (since == null) return;
    if (state.value != AppLockPhase.unlocked) return;
    if (clock().difference(since) >= appLockGracePeriod) {
      state = const AsyncData(AppLockPhase.locked);
    }
  }
}

final appLockProvider = AsyncNotifierProvider<AppLock, AppLockPhase>(
  AppLock.new,
);

class _LifecycleBridge with WidgetsBindingObserver {
  _LifecycleBridge(this._lock);

  final AppLock _lock;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _lock.onPaused();
      case AppLifecycleState.resumed:
        _lock.onResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }
}
