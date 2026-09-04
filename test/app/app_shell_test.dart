import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/shell/app_shell.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

import '../features/ministering/ministering_harness.dart';

/// Todos os dados aqui são fictícios.
void main() {
  late AppDatabase database;

  const currentUser = UserProfile(
    id: 'user',
    name: 'Administrador Demo',
    role: UserRole.admin,
  );

  final dashboard = WorkspaceDashboard(
    id: 'ws',
    name: 'Workspace Demo',
    type: WorkspaceType.local,
    users: const [currentUser],
    callings: const [
      CallingSummary(
        id: ministeringTestCallingId,
        userId: 'user',
        title: 'Secretário da Ministração',
        moduleKey: 'ministering-secretary',
        status: CallingStatus.active,
      ),
    ],
  );

  setUp(() async {
    database = await openMinisteringTestDatabase();
  });

  tearDown(() async => database.close());

  Future<void> pumpShell(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: AppShell(dashboard: dashboard, currentUser: currentUser),
  );

  testWidgets('abre no Início com os quatro destinos disponíveis', (
    tester,
  ) async {
    await pumpShell(tester);

    for (final key in [
      'shell-tab-inicio',
      'shell-tab-chamados',
      'shell-tab-perfil',
      'shell-tab-mais',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.text('Meu Chamado'), findsWidgets);
  });

  testWidgets('cada destino leva à sua tela', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byKey(const Key('shell-tab-chamados')));
    await tester.pumpAndSettle();
    expect(find.text('Chamados'), findsWidgets);

    await tester.tap(find.byKey(const Key('shell-tab-perfil')));
    await tester.pumpAndSettle();
    expect(find.text('Editar meu perfil'), findsOneWidget);
    expect(find.text('Administrador Demo'), findsWidgets);

    await tester.tap(find.byKey(const Key('shell-tab-mais')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('more-settings')), findsOneWidget);
    expect(find.byKey(const Key('more-users')), findsOneWidget);
  });

  testWidgets('o estado da aba sobrevive à troca de destino', (tester) async {
    await pumpShell(tester);

    // O `IndexedStack` mantém as quatro telas vivas: sair e voltar não pode
    // recriar a aba do zero, senão rolagem e formulários se perderiam.
    await tester.tap(find.byKey(const Key('shell-tab-mais')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shell-tab-inicio')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('more-settings')), findsNothing);
    expect(find.byKey(const Key('home-greeting')), findsOneWidget);
  });

  testWidgets('o shell adota o Workspace relido por outra aba', (tester) async {
    // A aba abre com um dashboard sem o chamado; o banco de teste já tem o
    // chamado de Ministração. Ao ouvir o bootstrap, o shell adota o estado
    // atual e a Home passa a mostrar o módulo — sem cada aba avisar as outras.
    await pumpMinisteringScreen(
      tester,
      database: database,
      child: const AppShell(
        dashboard: WorkspaceDashboard(
          id: 'ws',
          name: 'Workspace Demo',
          type: WorkspaceType.local,
          users: [currentUser],
          callings: [],
        ),
        currentUser: currentUser,
      ),
    );

    expect(
      find.byKey(const Key('home-ministering-$ministeringTestCallingId')),
      findsOneWidget,
    );
  });

  testWidgets('o back do Android volta ao Início antes de sair', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.byKey(const Key('shell-tab-perfil')));
    await tester.pumpAndSettle();
    expect(find.text('Editar meu perfil'), findsOneWidget);

    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(popped, isTrue, reason: 'o gesto foi tratado pelo shell');
    expect(find.byKey(const Key('home-greeting')), findsOneWidget);
    expect(find.text('Editar meu perfil'), findsNothing);
  });
}
