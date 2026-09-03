import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/security/pin_credential.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/presentation/locked_screen.dart';
import 'package:meu_chamado/features/security/presentation/security_gate.dart';
import 'package:meu_chamado/features/security/presentation/security_setup_screen.dart';

import 'security_harness.dart';

void main() {
  Future<void> pumpGate(WidgetTester tester, FakeSecureStore store) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: securityHarnessOverrides(store: store),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SecurityGate(child: Scaffold(body: Text('APP'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sem PIN mostra a configuração', (tester) async {
    final store = FakeSecureStore()..values['mc.database_key.v1'] = 'k' * 64;
    await pumpGate(tester, store);

    expect(find.byType(SecuritySetupScreen), findsOneWidget);
    expect(find.text('APP'), findsNothing);
  });

  testWidgets('com PIN mostra a tela de bloqueio e depois o app', (
    tester,
  ) async {
    final store = FakeSecureStore()..values['mc.database_key.v1'] = 'k' * 64;
    final credential = await PinCredential.create('481920', iterations: 1000);
    store.values['mc.pin_verifier.v1'] = credential.serialize();

    await pumpGate(tester, store);

    expect(find.byType(LockedScreen), findsOneWidget);
    expect(find.text('APP'), findsNothing);

    await tester.enterText(find.byType(EditableText).first, '481920');
    await tester.pumpAndSettle();

    expect(find.text('APP'), findsOneWidget);
    expect(find.byType(LockedScreen), findsNothing);
  });

  testWidgets('a tela de bloqueio cobre uma rota empilhada', (tester) async {
    final store = FakeSecureStore()..values['mc.database_key.v1'] = 'k' * 64;
    final credential = await PinCredential.create('481920', iterations: 1000);
    store.values['mc.pin_verifier.v1'] = credential.serialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: securityHarnessOverrides(store: store),
        child: MaterialApp(
          theme: AppTheme.light,
          home: SecurityGate(
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('SUBTELA')),
                    ),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Desbloqueia e abre uma subtela.
    await tester.enterText(find.byType(EditableText).first, '481920');
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('SUBTELA'), findsOneWidget);

    // Bloquear agora: a tela de bloqueio aparece por cima da subtela.
    final container = ProviderScope.containerOf(
      tester.element(find.text('SUBTELA')),
    );
    container.read(appLockProvider.notifier).lockNow();
    await tester.pumpAndSettle();

    expect(find.byType(LockedScreen), findsOneWidget);
    expect(find.text('SUBTELA'), findsNothing);
  });
}
