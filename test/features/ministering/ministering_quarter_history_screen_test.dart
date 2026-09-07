import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_quarter_history_screen.dart';

import 'ministering_harness.dart';

/// Telas do histórico trimestral. Dados fictícios: `Irmão A`, `Irmão B`…
///
/// O relógio do módulo é fixado nos dois lados — no repositório que semeia e no
/// `ProviderScope` que monta a tela — para a virada de trimestre acontecer sem
/// depender da data real em que a suíte roda.
void main() {
  late AppDatabase database;
  late DateTime seedClock;
  late MinisteringRepository repository;

  // Fim do Q3 2026: dá para semear entrevistas em datas anteriores do trimestre
  // sem esbarrar na trava de data futura.
  final endOfQ3 = DateTime.utc(2026, 9, 28);
  final inQ3 = DateTime.utc(2026, 8, 20);
  // Q4 2026: o momento em que a tela é aberta, já com o Q3 encerrado.
  final inQ4 = DateTime.utc(2026, 11, 10);

  setUp(() async {
    database = await openMinisteringTestDatabase();
    seedClock = endOfQ3;
    repository = MinisteringRepository(database, clock: () => seedClock);
  });

  tearDown(() async => database.close());

  Future<List<String>> seedBrothers(int count) async {
    final ids = <String>[];
    for (var i = 0; i < count; i++) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: 'Irmão ${String.fromCharCode(65 + i)}',
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

  Future<void> record(String companionshipId, DateTime on) async {
    final members = await database
        .customSelect(
          'SELECT brother_id FROM ministering_companionship_members '
          "WHERE companionship_id = '$companionshipId'",
        )
        .get();
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
      completedOn: on,
      participantBrotherIds: members
          .map((row) => row.read<String>('brother_id'))
          .toList(),
    );
  }

  Future<void> pumpHistory(
    WidgetTester tester, {
    required DateTime clock,
    ThemeMode themeMode = ThemeMode.light,
    Widget? wrap,
  }) => pumpMinisteringScreen(
    tester,
    database: database,
    clock: clock,
    themeMode: themeMode,
    child:
        wrap ??
        const MinisteringQuarterHistoryScreen(
          callingId: ministeringTestCallingId,
          callingTitle: 'Secretário da Ministração',
        ),
  );

  testWidgets('sem trimestres encerrados, explica quando o histórico aparece', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    await seedCompanionship(ids);

    await pumpHistory(tester, clock: endOfQ3);

    expect(find.text('Ainda não há trimestres encerrados'), findsOneWidget);
    // O trimestre corrente ainda assim aparece, em andamento.
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('3º trimestre'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
  });

  testWidgets('lista o trimestre encerrado com o denominador congelado', (
    tester,
  ) async {
    final ids = await seedBrothers(6);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await seedCompanionship([ids[4], ids[5]]);
    await record(a, inQ3);

    await pumpHistory(tester, clock: inQ4);

    // Ano corrente e ano do trimestre encerrado são o mesmo: um cabeçalho só.
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('4º trimestre'), findsOneWidget);
    expect(find.text('3º trimestre'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    // Q3 congelado: 1 de 3, mesmo com só uma entrevista.
    expect(find.text('1 de 3 duplas entrevistadas'), findsOneWidget);
  });

  testWidgets('abre o detalhe do trimestre encerrado com as duas listas', (
    tester,
  ) async {
    final ids = await seedBrothers(6);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await seedCompanionship([ids[4], ids[5]]);
    await record(a, inQ3);

    await pumpHistory(tester, clock: inQ4);
    await tapVisible(tester, find.byKey(const Key('history-quarter-2026-3')));

    expect(find.text('3º trimestre de 2026'), findsOneWidget);
    expect(find.text('Entrevistadas'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
    expect(find.text('Irmão C · Irmão D'), findsOneWidget);
  });

  testWidgets('o detalhe do trimestre corrente marca em andamento', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    await seedCompanionship(ids);

    await pumpHistory(tester, clock: endOfQ3);
    await tapVisible(tester, find.byKey(const Key('history-quarter-2026-3')));

    expect(find.text('3º trimestre de 2026'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(
      find.text('Nenhuma entrevista registrada neste trimestre.'),
      findsOneWidget,
    );
  });

  testWidgets('a dupla entrevistada abre o fluxo de correção da entrevista', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await record(a, inQ3);

    await pumpHistory(tester, clock: inQ4);
    await tapVisible(tester, find.byKey(const Key('history-quarter-2026-3')));
    await tapVisible(tester, find.byKey(Key('quarter-companionship-$a')));

    // Tela de entrevistas da dupla, com a entrevista já registrada à vista.
    expect(find.text('Entrevistas'), findsOneWidget);
    expect(find.text('Registradas'), findsOneWidget);
  });

  testWidgets('cabe em 320px com escala de texto 1.5', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ids = await seedBrothers(4);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await record(a, inQ3);

    await pumpHistory(
      tester,
      clock: inQ4,
      wrap: const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MinisteringQuarterHistoryScreen(
          callingId: ministeringTestCallingId,
          callingTitle: 'Secretário da Ministração',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('3º trimestre'), findsOneWidget);
  });

  testWidgets('renderiza no tema escuro sem exceção, lista e detalhe', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await record(a, inQ3);

    await pumpHistory(tester, clock: inQ4, themeMode: ThemeMode.dark);

    expect(tester.takeException(), isNull);
    await tapVisible(tester, find.byKey(const Key('history-quarter-2026-3')));
    expect(tester.takeException(), isNull);
    expect(find.text('3º trimestre de 2026'), findsOneWidget);
  });
}
