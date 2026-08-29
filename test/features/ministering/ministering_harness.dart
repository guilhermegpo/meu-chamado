import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/meu_chamado_app.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';

/// Chamado usado por todas as telas do módulo nos testes.
const ministeringTestCallingId = 'calling-a';

/// Banco em memória já com Workspace, usuário e chamado fictícios.
///
/// Nenhum dado aqui corresponde a pessoa real: o módulo trata informação
/// sensível e os testes não são exceção à regra.
Future<AppDatabase> openMinisteringTestDatabase({
  List<String> callingIds = const [ministeringTestCallingId],
}) async {
  final database = AppDatabase(NativeDatabase.memory());

  await database.customStatement(
    "INSERT INTO workspaces VALUES ('ws', 'Workspace Demo', 'LOCAL', 0)",
  );
  await database.customStatement(
    "INSERT INTO users VALUES ('user', 'Administrador Demo', NULL, 0)",
  );
  await database.customStatement(
    "INSERT INTO memberships VALUES ('ws', 'user', 'ADMIN', 0)",
  );
  for (final callingId in callingIds) {
    await database.customStatement('''
      INSERT INTO callings VALUES (
        '$callingId', 'ws', 'user', 'Secretário da Ministração',
        'ministering-secretary', 'ACTIVE', 0, NULL
      )
    ''');
  }

  return database;
}

/// Monta uma tela do módulo com o banco de teste no lugar do real.
Future<void> pumpMinisteringScreen(
  WidgetTester tester, {
  required AppDatabase database,
  required Widget child,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.light,
        // Mesma configuração do app: sem ela o seletor de data e as datas
        // formatadas apareceriam em inglês, e o teste validaria outra tela
        // que não a entregue ao usuário.
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

/// Toca em um alvo garantindo que ele esteja visível na rolagem.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Espera a fila de snack bars esvaziar.
///
/// O Material exibe um aviso por vez: sem isto, o segundo aviso de uma sequência
/// fica na fila e o teste procura um texto que ainda não foi para a tela.
Future<void> settleSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
