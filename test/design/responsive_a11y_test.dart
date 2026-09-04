import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/meu_chamado_app.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/home/presentation/home_screen.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_skeleton.dart';

import '../features/ministering/ministering_harness.dart';

/// A Product Experience 2.0 exige nenhum overflow entre 320 e 430px e com a
/// escala de texto do sistema em 1.5, além de respeitar "reduzir movimento".
/// Todos os dados são fictícios.
void main() {
  late AppDatabase database;

  const currentUser = UserProfile(
    id: 'user',
    name: 'Administrador Demo',
    role: UserRole.admin,
  );

  final dashboard = WorkspaceDashboard(
    id: 'ws',
    name: 'Workspace Demonstração da Ala',
    type: WorkspaceType.local,
    users: const [currentUser],
    callings: const [
      CallingSummary(
        id: ministeringTestCallingId,
        userId: 'user',
        title: 'Secretário da Ministração do Quórum de Élderes',
        moduleKey: 'ministering-secretary',
        status: CallingStatus.active,
      ),
    ],
  );

  setUp(() async {
    database = await openMinisteringTestDatabase();
    final repository = MinisteringRepository(database);
    final ids = <String>[];
    for (final label in ['Irmão A', 'Irmão B', 'Irmão C', 'Irmão D']) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: label,
      );
      ids.add(brother.id);
    }
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: [ids[0], ids[1]],
    );
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: [ids[2], ids[3]],
    );
  });

  tearDown(() async => database.close());

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget child, {
    double width = 390,
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = Size(width, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reduceMotion,
            ),
            child: widget!,
          ),
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget homeScreen() =>
      HomeScreen(dashboard: dashboard, currentUser: currentUser);

  Widget dashboardScreen() => const MinisteringDashboardScreen(
    callingId: ministeringTestCallingId,
    callingTitle: 'Secretário da Ministração do Quórum de Élderes',
  );

  for (final width in <double>[320, 360, 390, 430]) {
    testWidgets('a Home não estoura em ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, homeScreen(), width: width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('o painel de Ministração não estoura em ${width.toInt()}px', (
      tester,
    ) async {
      await pumpScreen(tester, dashboardScreen(), width: width);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a Home suporta escala de texto 1.5 sem overflow', (
    tester,
  ) async {
    await pumpScreen(tester, homeScreen(), width: 360, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o painel de Ministração suporta escala de texto 1.5', (
    tester,
  ) async {
    await pumpScreen(tester, dashboardScreen(), width: 360, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Home respeita "reduzir movimento" sem animação pendente', (
    tester,
  ) async {
    await pumpScreen(tester, homeScreen(), reduceMotion: true);
    // pumpAndSettle dentro de pumpScreen já teria estourado se algo animasse
    // para sempre.
    expect(tester.takeException(), isNull);
  });

  testWidgets('o esqueleto fica estático quando o movimento é reduzido', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppSkeletonList(rows: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppSkeletonBox), findsNWidgets(3));
  });
}
