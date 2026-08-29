import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/home/presentation/home_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

import '../ministering/ministering_harness.dart';

/// A home decide se um chamado abre módulo pela chave, nunca pelo título.
/// Todos os dados são fictícios.
void main() {
  late AppDatabase database;

  const currentUser = UserProfile(
    id: 'user',
    name: 'Administrador Demo',
    role: UserRole.admin,
  );

  WorkspaceDashboard dashboardWith(List<CallingSummary> callings) =>
      WorkspaceDashboard(
        id: 'ws',
        name: 'Workspace Demo',
        type: WorkspaceType.local,
        users: const [currentUser],
        callings: callings,
      );

  setUp(() async {
    database = await openMinisteringTestDatabase();
  });

  tearDown(() async => database.close());

  testWidgets('o chamado de ministração abre o painel do módulo', (
    tester,
  ) async {
    await pumpMinisteringScreen(
      tester,
      database: database,
      child: HomeScreen(
        dashboard: dashboardWith(const [
          CallingSummary(
            id: ministeringTestCallingId,
            userId: 'user',
            // Título renomeado de propósito: a decisão é pela chave do módulo.
            title: 'Secretaria do quórum',
            moduleKey: 'ministering-secretary',
            status: CallingStatus.active,
          ),
        ]),
        currentUser: currentUser,
      ),
    );

    expect(find.text('Ativo • Abrir módulo'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const Key('calling-card-$ministeringTestCallingId')),
    );

    expect(find.text('Ministração'), findsOneWidget);
    expect(find.text('Secretaria do quórum'), findsOneWidget);
    expect(find.text('Comece por aqui'), findsOneWidget);
  });

  testWidgets('um chamado sem módulo pronto continua sem abrir nada', (
    tester,
  ) async {
    await pumpMinisteringScreen(
      tester,
      database: database,
      child: HomeScreen(
        dashboard: dashboardWith([
          CallingSummary(
            id: 'calling-sunday',
            userId: 'user',
            title: CallingCatalog.sundaySchoolSecretary.title,
            moduleKey: CallingCatalog.sundaySchoolSecretary.moduleKey,
            status: CallingStatus.active,
          ),
        ]),
        currentUser: currentUser,
      ),
    );

    expect(find.text('Ativo • Em desenvolvimento'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(
            find.byKey(const Key('calling-card-calling-sunday')),
          )
          .onTap,
      isNull,
    );
  });
}
