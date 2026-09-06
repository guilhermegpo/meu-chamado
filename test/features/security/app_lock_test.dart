import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/security/pin_credential.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';

import 'security_harness.dart';

void main() {
  // O AppLock registra um observer no WidgetsBinding.
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> container({bool withPin = true}) async {
    final store = FakeSecureStore();
    store.values['mc.database_key.v1'] = 'k' * 64;
    if (withPin) {
      final credential = await PinCredential.create('481920', iterations: 1000);
      store.values['mc.pin_verifier.v1'] = credential.serialize();
    }
    final c = ProviderContainer(
      overrides: securityHarnessOverrides(store: store),
    );
    addTearDown(c.dispose);
    return c;
  }

  test('sem PIN começa em needsSetup; com PIN começa locked', () async {
    final withPin = await container();
    expect(await withPin.read(appLockProvider.future), AppLockPhase.locked);

    final noPin = await container(withPin: false);
    expect(await noPin.read(appLockProvider.future), AppLockPhase.needsSetup);
  });

  test('resume dentro da carência não tranca', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);

    var now = DateTime(2026, 9, 3, 12);
    lock.clock = () => now;
    lock.unlock();

    lock.onPaused();
    now = now.add(const Duration(seconds: 10));
    lock.onResumed();

    expect(c.read(appLockProvider).value, AppLockPhase.unlocked);
  });

  test('resume depois da carência tranca', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);

    var now = DateTime(2026, 9, 3, 12);
    lock.clock = () => now;
    lock.unlock();

    lock.onPaused();
    now = now.add(const Duration(seconds: 31));
    lock.onResumed();

    expect(c.read(appLockProvider).value, AppLockPhase.locked);
  });

  test('resume sem pause anterior (só inactive) não tranca', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);
    lock.unlock();

    lock.onResumed();
    expect(c.read(appLockProvider).value, AppLockPhase.unlocked);
  });

  test('lockNow tranca na hora, mas nunca volta de needsSetup', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);
    lock.unlock();
    lock.lockNow();
    expect(c.read(appLockProvider).value, AppLockPhase.locked);

    final setup = await container(withPin: false);
    await setup.read(appLockProvider.future);
    setup.read(appLockProvider.notifier).lockNow();
    expect(setup.read(appLockProvider).value, AppLockPhase.needsSetup);
  });

  test('submitPin certo libera na hora', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);

    expect(await lock.submitPin('481920'), isNull);
    expect(c.read(appLockProvider).value, AppLockPhase.unlocked);
  });

  test('submitPin errado devolve a razão e trava após cinco erros', () async {
    final c = await container();
    await c.read(appLockProvider.future);
    final lock = c.read(appLockProvider.notifier);

    for (var i = 0; i < 4; i++) {
      expect(await lock.submitPin('000000'), 'PIN incorreto.');
    }
    // O quinto erro liga o atraso; daí em diante até o PIN certo espera.
    expect(await lock.submitPin('000000'), contains('Aguarde'));
    expect(await lock.submitPin('481920'), contains('Aguarde'));
    expect(c.read(appLockProvider).value, AppLockPhase.locked);
  });
}
