import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/features/security/presentation/security_setup_screen.dart';

import 'security_harness.dart';

void main() {
  testWidgets('cria o PIN, confirma e libera o app', (tester) async {
    final store = FakeSecureStore();
    await pumpSecurity(tester, const SecuritySetupScreen(), store: store);

    expect(find.text('Proteja seus dados'), findsOneWidget);

    await enterPin(tester, '481920');
    expect(find.text('Repita o PIN'), findsOneWidget);

    await enterPin(tester, '481920');
    await tester.pumpAndSettle();

    // Sem biometria disponível no harness, a configuração termina sozinha.
    expect(store.values.keys.any((k) => k.contains('pin_verifier')), isTrue);
    expect(store.values.values, isNot(contains('481920')));
  });

  testWidgets('PIN diferente na confirmação recomeça', (tester) async {
    await pumpSecurity(tester, const SecuritySetupScreen());

    await enterPin(tester, '481920');
    await enterPin(tester, '000000');
    await tester.pumpAndSettle();

    expect(find.textContaining('não são iguais'), findsOneWidget);
    expect(find.text('Proteja seus dados'), findsOneWidget);
  });

  testWidgets('recusa PIN fraco', (tester) async {
    await pumpSecurity(tester, const SecuritySetupScreen());

    await enterPin(tester, '111111');
    await tester.pumpAndSettle();

    expect(find.textContaining('fácil de adivinhar'), findsOneWidget);
    expect(find.text('Repita o PIN'), findsNothing);
  });
}
