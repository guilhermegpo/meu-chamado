import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_interviews_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;
  late MinisteringRepository repository;
  late List<String> brotherIds;
  late String companionshipId;
  late MinisteringLeader leader;

  setUp(() async {
    database = await openMinisteringTestDatabase();
    repository = MinisteringRepository(database);

    brotherIds = [];
    for (final label in ['Irmão A', 'Irmão B']) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: label,
      );
      brotherIds.add(brother.id);
    }
    companionshipId = await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: brotherIds,
    );
    leader = await repository.createLeader(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão P',
      role: MinisteringLeadershipRole.quorumPresident,
    );
  });

  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: MinisteringInterviewsScreen(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
    ),
  );

  Future<void> record(WidgetTester tester) async {
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));
    await tapVisible(tester, find.byKey(const Key('interview-confirm')));
  }

  testWidgets('mostra a dupla pendente e sem histórico', (tester) async {
    await pump(tester);

    final quarter = Quarter.of(DateTime.now());
    // Uma vez só: sem rótulo próprio, o título já é a lista de integrantes.
    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
    expect(find.text('Pendente no ${quarter.label}'), findsOneWidget);
    expect(
      find.text('Nenhuma entrevista registrada para esta dupla.'),
      findsOneWidget,
    );
  });

  testWidgets('sem liderança ativa direciona ao cadastro em vez de registrar', (
    tester,
  ) async {
    await repository.setLeaderActive(
      callingId: ministeringTestCallingId,
      leaderId: leader.id,
      isActive: false,
    );
    await pump(tester);

    expect(find.byKey(const Key('record-interview-button')), findsNothing);
    expect(
      find.byKey(const Key('open-leaders-for-record-button')),
      findsOneWidget,
    );
  });

  testWidgets('a data registrada é a data escolhida, sem deslocar o dia', (
    tester,
  ) async {
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
      completedOn: DateTime.utc(2026, 7),
      participantBrotherIds: brotherIds,
    );
    await pump(tester);

    final expected = MaterialLocalizations.of(
      tester.element(find.byType(MinisteringInterviewsScreen)),
    ).formatMediumDate(DateTime(2026, 7));
    expect(find.text(expected), findsOneWidget);
    expect(find.text('3º trimestre de 2026'), findsOneWidget);
  });

  testWidgets('registra a entrevista e a dupla deixa de ser pendente', (
    tester,
  ) async {
    await pump(tester);
    await record(tester);

    final quarter = Quarter.of(DateTime.now());
    expect(find.text('Entrevista registrada.'), findsOneWidget);
    expect(find.text('Entrevistada no ${quarter.label}'), findsOneWidget);
    expect(find.text(quarter.label), findsOneWidget);
    expect(
      find.text('Nenhuma entrevista registrada para esta dupla.'),
      findsNothing,
    );
  });

  testWidgets('marca todos os integrantes por padrão', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));

    for (final id in brotherIds) {
      final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(Key('interview-participant-$id')),
      );
      expect(checkbox.value, isTrue, reason: id);
    }
  });

  testWidgets('não permite registrar sem nenhum participante', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));

    for (final id in brotherIds) {
      await tapVisible(tester, find.byKey(Key('interview-participant-$id')));
    }

    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('interview-confirm')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('registra entrevista com um único participante', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));
    await tapVisible(
      tester,
      find.byKey(Key('interview-participant-${brotherIds[1]}')),
    );
    await tapVisible(tester, find.byKey(const Key('interview-confirm')));

    expect(find.text('Entrevista registrada.'), findsOneWidget);

    final interviews = await repository.listInterviews(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
    );
    expect(interviews.single.participantIds, [brotherIds[0]]);
  });

  testWidgets('duas entrevistas no trimestre ficam ambas no histórico', (
    tester,
  ) async {
    await pump(tester);
    await record(tester);
    await record(tester);

    expect(find.byTooltip('Remover entrevista'), findsNWidgets(2));
  });

  testWidgets('corrige participantes sem criar outra entrevista', (
    tester,
  ) async {
    final recorded = await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
      completedOn: DateTime.utc(2026, 8, 10),
      participantBrotherIds: brotherIds,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Corrigir entrevista'));
    expect(find.text('Corrigir entrevista'), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(Key('interview-participant-${brotherIds[1]}')),
    );
    await tapVisible(tester, find.byKey(const Key('interview-confirm')));

    expect(find.text('Entrevista corrigida.'), findsOneWidget);
    final interviews = await repository.listInterviews(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
    );
    expect(interviews, hasLength(1));
    expect(interviews.single.id, recorded.id);
    expect(interviews.single.participantIds, [brotherIds.first]);
  });

  testWidgets('remover pede confirmação e devolve a dupla para pendente', (
    tester,
  ) async {
    await pump(tester);
    await record(tester);
    await settleSnackBars(tester);

    await tapVisible(tester, find.byTooltip('Remover entrevista'));
    expect(find.text('Remover entrevista?'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('confirm-delete-interview')));

    final quarter = Quarter.of(DateTime.now());
    expect(find.text('Entrevista removida.'), findsOneWidget);
    expect(find.text('Pendente no ${quarter.label}'), findsOneWidget);
    expect(
      find.text('Nenhuma entrevista registrada para esta dupla.'),
      findsOneWidget,
    );
  });

  testWidgets('cancelar a remoção mantém o registro', (tester) async {
    await pump(tester);
    await record(tester);

    await tapVisible(tester, find.byTooltip('Remover entrevista'));
    await tapVisible(tester, find.text('Cancelar'));

    expect(find.byTooltip('Remover entrevista'), findsOneWidget);
  });

  testWidgets('agenda com o único entrevistador ativo', (tester) async {
    await pump(tester);

    await tapVisible(
      tester,
      find.byKey(const Key('schedule-interview-button')),
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('schedule-confirm')))
          .onPressed,
      isNotNull,
    );
    await tapVisible(tester, find.byKey(const Key('schedule-confirm')));

    expect(find.text('Entrevista agendada.'), findsOneWidget);
    await settleSnackBars(tester);
    expect(
      find.byKey(const Key('complete-appointment-button')),
      findsOneWidget,
    );

    final state = await repository.loadModule(
      callingId: ministeringTestCallingId,
    );
    expect(state.appointments.single.interviewerId, leader.id);
  });

  testWidgets('reagendar troca entrevistador inativo sem quebrar o editor', (
    tester,
  ) async {
    final appointment = await repository.scheduleInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionshipId,
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      interviewerId: leader.id,
    );
    await repository.setLeaderActive(
      callingId: ministeringTestCallingId,
      leaderId: leader.id,
      isActive: false,
    );
    final replacement = await repository.createLeader(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão C',
      role: MinisteringLeadershipRole.firstCounselor,
    );

    await pump(tester);
    await tapVisible(
      tester,
      find.byKey(const Key('reschedule-appointment-button')),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('schedule-confirm')))
          .onPressed,
      isNotNull,
    );
    await tapVisible(tester, find.byKey(const Key('schedule-confirm')));

    final state = await repository.loadModule(
      callingId: ministeringTestCallingId,
    );
    expect(state.appointments.single.id, appointment.id);
    expect(state.appointments.single.interviewerId, replacement.id);
  });

  testWidgets('dialogs operacionais cabem em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pump(tester);
    await tapVisible(
      tester,
      find.byKey(const Key('schedule-interview-button')),
    );
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Agendar entrevista')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('o seletor de data não oferece datas futuras', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));
    await tapVisible(tester, find.byKey(const Key('interview-date-field')));

    final dialog = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    final today = DateTime.now();
    expect(calendarDate(dialog.lastDate), calendarDate(today));
    expect(dialog.helpText, 'Data da entrevista');
  });
}
