import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/security/biometric_service.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/presentation/change_pin_screen.dart';
import 'package:meu_chamado/features/security/presentation/security_settings_section.dart';

import 'security_harness.dart';

class _YesBiometrics implements BiometricService {
  const _YesBiometrics();
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> authenticate(String reason) async => true;
}

void main() {
  Future<void> pump(WidgetTester tester, {BiometricService? biometrics}) async {
    final store = FakeSecureStore()
      ..values['mc.database_key.v1'] = 'k' * 64
      ..values['mc.pin_verifier.v1'] = 'pbkdf2-sha256\$1000\$aa\$bb';

    await tester.pumpWidget(
      ProviderScope(
        overrides: securityHarnessOverrides(
          store: store,
          biometrics: biometrics ?? const NoBiometrics(),
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(child: SecuritySettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra o estado do PIN e as ações, sem recuperação online', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Proteção por PIN'), findsOneWidget);
    expect(find.byKey(const Key('security-change-pin')), findsOneWidget);
    expect(find.byKey(const Key('security-lock-now')), findsOneWidget);
    expect(find.textContaining('Não há recuperação'), findsOneWidget);
  });

  testWidgets('sem suporte a biometria não há switch', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('security-biometric-switch')), findsNothing);
  });

  testWidgets('com suporte a biometria há switch', (tester) async {
    await pump(tester, biometrics: const _YesBiometrics());
    expect(find.byKey(const Key('security-biometric-switch')), findsOneWidget);
  });

  testWidgets('"Alterar PIN" abre a tela de troca', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('security-change-pin')));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePinScreen), findsOneWidget);
  });

  testWidgets('"Bloquear agora" tranca o app', (tester) async {
    await pump(tester);

    final element = tester.element(find.byType(SecuritySettingsSection));
    final container = ProviderScope.containerOf(element);
    container.read(appLockProvider.notifier).unlock();
    expect(container.read(appLockProvider).value, AppLockPhase.unlocked);

    await tester.tap(find.byKey(const Key('security-lock-now')));
    await tester.pump();
    expect(container.read(appLockProvider).value, AppLockPhase.locked);
  });
}
