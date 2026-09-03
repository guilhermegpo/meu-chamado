import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:meu_chamado/app/meu_chamado_app.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';

import '../../support/security_test_scope.dart';

void main() {
  testWidgets('conclui onboarding e apresenta seleção de usuário', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          ...unlockedSecurityOverrides(),
        ],
        child: const MeuChamadoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Organize seus chamados no seu ritmo.'), findsOneWidget);

    final nextButton = find.byKey(const Key('onboarding-next-button'));
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('workspace-name-field')),
      'Workspace Demo',
    );
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('administrator-name-field')),
      'Administrador Demo',
    );
    final createButton = find.byKey(const Key('create-workspace-button'));
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Quem está usando o Meu Chamado?'), findsOneWidget);
    expect(find.text('Administrador Demo'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
  });
}
