import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/meu_chamado_app.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';

import 'ministering_harness.dart';

void main() {
  /// Monta uma tela cujo provedor de dados falha.
  Future<void> pumpBroken(WidgetTester tester, Widget child) async {
    final database = await openMinisteringTestDatabase();
    // Fechar antes de montar faz toda consulta lançar, que é a forma mais
    // direta de reproduzir uma falha de leitura sem simular o Drift inteiro.
    await database.close();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: appLocale,
          supportedLocales: const [appLocale],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('o painel com falha de leitura oferece tentar novamente', (
    tester,
  ) async {
    await pumpBroken(
      tester,
      const MinisteringDashboardScreen(
        callingId: ministeringTestCallingId,
        callingTitle: 'Secretário da Ministração',
      ),
    );

    expect(find.byKey(const Key('ministering-retry-button')), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    // Mensagem tratada, nunca o erro cru.
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('#0'), findsNothing);
  });

  testWidgets('a tela de irmãos com falha de leitura tem saída', (
    tester,
  ) async {
    await pumpBroken(
      tester,
      const MinisteringBrothersScreen(callingId: ministeringTestCallingId),
    );

    expect(find.byKey(const Key('ministering-retry-button')), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });
}
