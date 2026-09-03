import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/security/biometric_service.dart';
import 'package:meu_chamado/core/security/pin_credential.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/presentation/locked_screen.dart';

import 'security_harness.dart';

class _YesBiometrics implements BiometricService {
  const _YesBiometrics({this.succeeds = true});
  final bool succeeds;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> authenticate(String reason) async => succeeds;
}

void main() {
  Future<FakeSecureStore> storeWithPin({bool biometric = false}) async {
    final store = FakeSecureStore();
    store.values['mc.database_key.v1'] = 'k' * 64;
    final credential = await PinCredential.create('481920', iterations: 1000);
    store.values['mc.pin_verifier.v1'] = credential.serialize();
    if (biometric) store.values['mc.biometric_enabled.v1'] = 'true';
    return store;
  }

  Future<void> pump(
    WidgetTester tester, {
    required FakeSecureStore store,
    BiometricService? biometrics,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...securityHarnessOverrides(store: store, biometrics: biometrics),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const _Host()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('PIN correto libera, PIN errado mostra o aviso', (tester) async {
    await pump(tester, store: await storeWithPin());

    await tester.enterText(find.byType(EditableText).first, '000000');
    await tester.pumpAndSettle();
    expect(find.textContaining('PIN incorreto'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, '481920');
    await tester.pumpAndSettle();
    expect(find.text('LIBERADO'), findsOneWidget);
  });

  testWidgets('sem biometria ativada não mostra o atalho', (tester) async {
    await pump(tester, store: await storeWithPin());
    expect(find.byKey(const Key('locked-use-biometric')), findsNothing);
  });

  testWidgets('biometria ativada mostra o atalho', (tester) async {
    await pump(
      tester,
      store: await storeWithPin(biometric: true),
      biometrics: const _YesBiometrics(succeeds: false),
    );
    expect(find.byKey(const Key('locked-use-biometric')), findsOneWidget);
  });

  testWidgets('biometria bem-sucedida libera', (tester) async {
    await pump(
      tester,
      store: await storeWithPin(biometric: true),
      biometrics: const _YesBiometrics(),
    );
    await tester.pumpAndSettle();
    expect(find.text('LIBERADO'), findsOneWidget);
  });
}

class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(appLockProvider).value;
    if (phase == AppLockPhase.unlocked) {
      return const Scaffold(body: Center(child: Text('LIBERADO')));
    }
    return const LockedScreen();
  }
}
