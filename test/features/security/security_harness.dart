import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/security/biometric_service.dart';

import '../../support/security_test_scope.dart';

export '../../support/security_test_scope.dart';

Future<void> pumpSecurity(
  WidgetTester tester,
  Widget child, {
  FakeSecureStore? store,
  BiometricService? biometrics,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: securityHarnessOverrides(store: store, biometrics: biometrics),
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  await tester.pumpAndSettle();
}

/// Digita [pin] no campo de PIN visível.
Future<void> enterPin(WidgetTester tester, String pin) async {
  await tester.enterText(find.byType(EditableText).first, pin);
  await tester.pumpAndSettle();
}
