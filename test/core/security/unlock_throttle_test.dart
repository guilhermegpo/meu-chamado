import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/security/unlock_throttle.dart';

void main() {
  test('os primeiros quatro erros não impõem espera', () {
    final throttle = UnlockThrottle();
    for (var i = 0; i < 4; i++) {
      throttle.registerFailure();
      expect(throttle.isLockedOut, isFalse);
      expect(throttle.remainingLockout, Duration.zero);
    }
  });

  test('do quinto erro em diante há espera crescente com teto', () {
    var now = DateTime(2026, 9, 3, 12);
    final throttle = UnlockThrottle(clock: () => now);

    for (var i = 0; i < 5; i++) {
      throttle.registerFailure();
    }
    expect(throttle.isLockedOut, isTrue);
    expect(throttle.remainingLockout.inSeconds, 5);

    throttle.registerFailure();
    expect(throttle.remainingLockout.inSeconds, 10);

    for (var i = 0; i < 20; i++) {
      throttle.registerFailure();
    }
    expect(throttle.remainingLockout.inSeconds, lessThanOrEqualTo(30));
  });

  test('o relógio avançando limpa a espera', () {
    var now = DateTime(2026, 9, 3, 12);
    final throttle = UnlockThrottle(clock: () => now);
    for (var i = 0; i < 5; i++) {
      throttle.registerFailure();
    }
    expect(throttle.isLockedOut, isTrue);

    now = now.add(const Duration(seconds: 6));
    expect(throttle.isLockedOut, isFalse);
  });

  test('um acerto zera a contagem', () {
    final throttle = UnlockThrottle();
    for (var i = 0; i < 6; i++) {
      throttle.registerFailure();
    }
    expect(throttle.isLockedOut, isTrue);

    throttle.registerSuccess();
    expect(throttle.failures, 0);
    expect(throttle.isLockedOut, isFalse);
  });
}
