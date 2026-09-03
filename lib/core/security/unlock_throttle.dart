/// Atraso progressivo depois de PINs errados.
///
/// Vive só na memória do processo: fechar o app zera a contagem. **Nunca**
/// apaga dados — o pior que faz é obrigar a esperar alguns segundos. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class UnlockThrottle {
  UnlockThrottle({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// A partir daqui cada erro passa a impor espera.
  static const _freeAttempts = 4;

  /// Passo e teto da espera.
  static const _stepSeconds = 5;
  static const _maxSeconds = 30;

  int _failures = 0;
  DateTime? _blockedUntil;

  int get failures => _failures;

  /// Quanto ainda falta esperar antes da próxima tentativa.
  Duration get remainingLockout {
    final until = _blockedUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(_clock());
    return left.isNegative ? Duration.zero : left;
  }

  bool get isLockedOut => remainingLockout > Duration.zero;

  void registerFailure() {
    _failures++;
    if (_failures > _freeAttempts) {
      final seconds = ((_failures - _freeAttempts) * _stepSeconds).clamp(
        _stepSeconds,
        _maxSeconds,
      );
      _blockedUntil = _clock().add(Duration(seconds: seconds));
    }
  }

  void registerSuccess() {
    _failures = 0;
    _blockedUntil = null;
  }
}
