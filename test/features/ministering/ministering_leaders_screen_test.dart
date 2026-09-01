import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_leaders_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;
  late MinisteringRepository repository;

  setUp(() async {
    database = await openMinisteringTestDatabase();
    repository = MinisteringRepository(database);
  });

  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: const MinisteringLeadersScreen(callingId: ministeringTestCallingId),
  );

  testWidgets('cadastra uma liderança com identificação e cargo', (
    tester,
  ) async {
    await pump(tester);

    await tapVisible(tester, find.byKey(const Key('add-leader-button')));
    await tester.enterText(
      find.byKey(const Key('leader-label-field')),
      'Irmão P',
    );
    await tapVisible(tester, find.byKey(const Key('leader-role-field')));
    await tapVisible(tester, find.text('1º Conselheiro').last);
    await tapVisible(tester, find.byKey(const Key('leader-confirm')));

    expect(find.text('Liderança adicionada.'), findsOneWidget);
    await settleSnackBars(tester);
    expect(find.text('Irmão P'), findsOneWidget);
    expect(find.text('1º Conselheiro'), findsOneWidget);
  });

  testWidgets('editor cabe em tela estreita sem overflow horizontal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('add-leader-button')));
    await tester.pumpAndSettle();

    expect(find.text('Nova liderança'), findsOneWidget);
    expect(find.byKey(const Key('leader-role-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tela lembra a privacidade mínima da identificação', (
    tester,
  ) async {
    await pump(tester);

    expect(find.textContaining('nada de'), findsOneWidget);
    expect(find.textContaining('número de registro'), findsOneWidget);
  });

  testWidgets('desativar tira a liderança da seleção ativa sem apagar', (
    tester,
  ) async {
    await repository.createLeader(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão P',
      role: MinisteringLeadershipRole.quorumPresident,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Ações da liderança').first);
    await tapVisible(tester, find.text('Desativar').last);

    expect(find.text('Liderança desativada.'), findsOneWidget);
    await settleSnackBars(tester);
    // Continua na tela, agora na seção inativa.
    expect(find.text('Irmão P'), findsOneWidget);
  });

  testWidgets('não oferece exclusão de liderança com entrevista agendada', (
    tester,
  ) async {
    final leader = await repository.createLeader(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão P',
      role: MinisteringLeadershipRole.quorumPresident,
    );
    final ids = <String>[];
    for (final label in ['Irmão A', 'Irmão B']) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: label,
      );
      ids.add(brother.id);
    }
    final companionship = await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );
    await repository.scheduleInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      interviewerId: leader.id,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Ações da liderança').first);
    await tapVisible(tester, find.text('Verificar exclusão').last);

    expect(find.text('Exclusão indisponível'), findsOneWidget);
    expect(find.byKey(const Key('confirm-delete-leader')), findsNothing);
  });

  testWidgets('exclui liderança que nunca conduziu nem agendou', (
    tester,
  ) async {
    await repository.createLeader(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão P',
      role: MinisteringLeadershipRole.quorumPresident,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Ações da liderança').first);
    await tapVisible(tester, find.text('Verificar exclusão').last);
    expect(find.text('Excluir liderança?'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('confirm-delete-leader')));

    expect(find.text('Liderança excluída.'), findsOneWidget);
    await settleSnackBars(tester);
    expect(find.text('Irmão P'), findsNothing);
  });
}
