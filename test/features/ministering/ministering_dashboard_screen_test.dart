import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;
  late MinisteringRepository repository;

  setUp(() async {
    database = await openMinisteringTestDatabase();
    repository = MinisteringRepository(database);
  });

  tearDown(() async => database.close());

  Future<List<String>> seedBrothers(int count) async {
    final ids = <String>[];
    for (var index = 0; index < count; index++) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: 'Irmão ${String.fromCharCode(65 + index)}',
      );
      ids.add(brother.id);
    }
    return ids;
  }

  Future<String> seedCompanionship(List<String> brotherIds) =>
      repository.createCompanionship(
        callingId: ministeringTestCallingId,
        brotherIds: brotherIds,
      );

  Future<void> pump(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: const MinisteringDashboardScreen(
      callingId: ministeringTestCallingId,
      callingTitle: 'Secretário da Ministração',
    ),
  );

  double progressValue(WidgetTester tester) => tester
      .widget<LinearProgressIndicator>(
        find.byKey(const Key('quarter-progress')),
      )
      .value!;

  testWidgets('primeiro uso indica cadastrar irmãos antes de montar duplas', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Comece por aqui'), findsOneWidget);
    expect(
      find.textContaining('Cadastre os irmãos ministradores'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('start-companionships-button')),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Nenhuma dupla ativa'), findsOneWidget);
  });

  testWidgets('com irmãos cadastrados libera o caminho para as duplas', (
    tester,
  ) async {
    await seedBrothers(2);
    await pump(tester);

    expect(
      find.textContaining('Os irmãos já estão cadastrados'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('start-companionships-button')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('abre o trimestre corrente com todas as duplas pendentes', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await pump(tester);

    expect(find.text(Quarter.of(DateTime.now()).label), findsOneWidget);
    expect(find.text('0 de 2 duplas entrevistadas'), findsOneWidget);
    expect(
      find.text('2 duplas ainda sem entrevista neste trimestre.'),
      findsOneWidget,
    );
    expect(progressValue(tester), 0);

    await scrollTo(
      tester,
      find.text('Nenhuma entrevista registrada neste trimestre.'),
    );
    expect(
      find.text('Nenhuma entrevista registrada neste trimestre.'),
      findsOneWidget,
    );
  });

  testWidgets('a dupla entrevistada troca de seção e move a contagem', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    final first = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: first,
      completedOn: DateTime.now(),
      participantBrotherIds: [ids[0]],
    );
    await pump(tester);

    expect(find.text('1 de 2 duplas entrevistadas'), findsOneWidget);
    expect(
      find.text('1 dupla ainda sem entrevista neste trimestre.'),
      findsOneWidget,
    );
    expect(progressValue(tester), closeTo(0.5, 0.0001));

    await scrollTo(tester, find.byKey(Key('dashboard-companionship-$first')));
    expect(
      find.text('Nenhuma entrevista registrada neste trimestre.'),
      findsNothing,
    );
  });

  testWidgets('duas entrevistas da mesma dupla contam uma vez só', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    final companionship = await seedCompanionship(ids);
    for (var index = 0; index < 2; index++) {
      await repository.recordInterview(
        callingId: ministeringTestCallingId,
        companionshipId: companionship,
        completedOn: DateTime.now(),
        participantBrotherIds: ids,
      );
    }
    await pump(tester);

    expect(find.text('1 de 1 dupla entrevistada'), findsOneWidget);
    expect(find.text('Nada pendente por aqui.'), findsOneWidget);
    expect(progressValue(tester), 1);
  });

  testWidgets('trimestre completo mostra que nada ficou pendente', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    final companionship = await seedCompanionship(ids);
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
      completedOn: DateTime.now(),
      participantBrotherIds: ids,
    );
    await pump(tester);

    expect(
      find.text(
        'Todas as duplas ativas já foram entrevistadas neste trimestre.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('entrevista de outro trimestre não conta no atual', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    final companionship = await seedCompanionship(ids);
    final quarter = Quarter.of(DateTime.now());
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
      completedOn: quarter.start.subtract(const Duration(days: 1)),
      participantBrotherIds: ids,
    );
    await pump(tester);

    expect(find.text('0 de 1 dupla entrevistada'), findsOneWidget);
    expect(
      find.text('1 dupla ainda sem entrevista neste trimestre.'),
      findsOneWidget,
    );
  });

  testWidgets('dupla inativa sai do painel sem apagar o registro', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    final first = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await repository.setCompanionshipActive(
      callingId: ministeringTestCallingId,
      companionshipId: first,
      isActive: false,
    );
    await pump(tester);

    expect(find.text('0 de 1 dupla entrevistada'), findsOneWidget);
    expect(find.byKey(Key('dashboard-companionship-$first')), findsNothing);
  });

  testWidgets('tocar numa dupla abre o histórico dela', (tester) async {
    final ids = await seedBrothers(2);
    final companionship = await seedCompanionship(ids);
    await pump(tester);

    await tapVisible(
      tester,
      find.byKey(Key('dashboard-companionship-$companionship')),
    );

    expect(find.text('Entrevistas'), findsOneWidget);
    expect(
      find.text('Nenhuma entrevista registrada para esta dupla.'),
      findsOneWidget,
    );
  });
}
