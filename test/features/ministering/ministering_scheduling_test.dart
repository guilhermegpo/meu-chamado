import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_exceptions.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

/// Liderança, entrevistador e agendamento (schema v4). Todos os dados são
/// fictícios, como exige a política do módulo.
void main() {
  late AppDatabase database;
  late MinisteringRepository repository;

  const callingA = 'calling-a';
  const callingB = 'calling-b';

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = MinisteringRepository(database);

    await database.customStatement(
      "INSERT INTO workspaces VALUES ('ws', 'Workspace Demo', 'LOCAL', 0)",
    );
    await database.customStatement(
      "INSERT INTO users VALUES ('user', 'Administrador Demo', NULL, 0)",
    );
    await database.customStatement(
      "INSERT INTO memberships VALUES ('ws', 'user', 'ADMIN', 0)",
    );
    for (final calling in [callingA, callingB]) {
      await database.customStatement('''
        INSERT INTO callings VALUES (
          '$calling', 'ws', 'user', 'Secretário da Ministração',
          'ministering-secretary', 'ACTIVE', 0, NULL
        )
      ''');
    }
  });

  tearDown(() async => database.close());

  Future<List<String>> createBrothers(
    int count, {
    String calling = callingA,
  }) async {
    final ids = <String>[];
    for (var index = 0; index < count; index++) {
      final brother = await repository.createBrother(
        callingId: calling,
        displayLabel: 'Irmão ${String.fromCharCode(65 + index)}',
      );
      ids.add(brother.id);
    }
    return ids;
  }

  Future<String> seedCompanionship({String calling = callingA}) async {
    final ids = await createBrothers(2, calling: calling);
    return repository.createCompanionship(callingId: calling, brotherIds: ids);
  }

  Future<MinisteringLeader> seedLeader({
    String calling = callingA,
    MinisteringLeadershipRole role = MinisteringLeadershipRole.quorumPresident,
    String label = 'Irmão P',
  }) => repository.createLeader(
    callingId: calling,
    displayLabel: label,
    role: role,
  );

  group('liderança', () {
    test('cria com identificação normalizada e papel', () async {
      final leader = await repository.createLeader(
        callingId: callingA,
        displayLabel: '  Irmão P  ',
        role: MinisteringLeadershipRole.firstCounselor,
      );

      expect(leader.displayLabel, 'Irmão P');
      expect(leader.role, MinisteringLeadershipRole.firstCounselor);
      expect(leader.isActive, isTrue);

      final state = await repository.loadModule(callingId: callingA);
      expect(
        state.leaders.single.role,
        MinisteringLeadershipRole.firstCounselor,
      );
    });

    test('recusa identificação vazia', () async {
      await expectLater(
        repository.createLeader(
          callingId: callingA,
          displayLabel: '   ',
          role: MinisteringLeadershipRole.quorumPresident,
        ),
        throwsA(isA<InvalidMinisteringLabelException>()),
      );
    });

    test('a lista segue a hierarquia da presidência', () async {
      await seedLeader(
        role: MinisteringLeadershipRole.secondCounselor,
        label: 'Irmão S',
      );
      await seedLeader(
        role: MinisteringLeadershipRole.quorumPresident,
        label: 'Irmão P',
      );
      await seedLeader(
        role: MinisteringLeadershipRole.firstCounselor,
        label: 'Irmão C',
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.leaders.map((leader) => leader.role.storageValue).toList(), [
        'QUORUM_PRESIDENT',
        'FIRST_COUNSELOR',
        'SECOND_COUNSELOR',
      ]);
    });

    test('desativar preserva o líder e o tira da seleção ativa', () async {
      final leader = await seedLeader();
      await repository.setLeaderActive(
        callingId: callingA,
        leaderId: leader.id,
        isActive: false,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.leaders, hasLength(1));
      expect(state.activeLeaders, isEmpty);
    });

    test('não alcança líder de outro chamado', () async {
      final foreign = await seedLeader(calling: callingB);

      await expectLater(
        repository.updateLeader(
          callingId: callingA,
          leaderId: foreign.id,
          displayLabel: 'Renomeado',
          role: MinisteringLeadershipRole.quorumPresident,
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });

    test('líder nunca usado pode ser excluído', () async {
      final leader = await seedLeader();

      final check = await repository.inspectLeaderRemoval(
        callingId: callingA,
        leaderId: leader.id,
      );
      expect(check.canDelete, isTrue);

      await repository.deleteLeader(callingId: callingA, leaderId: leader.id);
      final state = await repository.loadModule(callingId: callingA);
      expect(state.leaders, isEmpty);
    });

    test('líder com agendamento aberto não pode ser excluído', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      final check = await repository.inspectLeaderRemoval(
        callingId: callingA,
        leaderId: leader.id,
      );
      expect(check.appointments, 1);
      expect(check.canDelete, isFalse);

      await expectLater(
        repository.deleteLeader(callingId: callingA, leaderId: leader.id),
        throwsA(isA<MinisteringRecordInUseException>()),
      );
    });

    test('líder no histórico de entrevistas não pode ser excluído', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.now(),
        participantBrotherIds: [state.companionships.single.members.first.id],
        interviewerId: leader.id,
      );

      final check = await repository.inspectLeaderRemoval(
        callingId: callingA,
        leaderId: leader.id,
      );
      expect(check.hasHistory, isTrue);

      try {
        await repository.deleteLeader(callingId: callingA, leaderId: leader.id);
        fail('deveria ter recusado');
      } on MinisteringRecordInUseException catch (error) {
        expect(error.message, isNot(contains('Irmão P')));
        expect(error.message, contains('histórico'));
      }
    });
  });

  group('agendamento', () {
    test('agenda a partir de uma dupla pendente', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final when = DateTime.now().add(const Duration(days: 2));

      final appointment = await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: when,
        interviewerId: leader.id,
      );

      expect(appointment.interviewerId, leader.id);

      final state = await repository.loadModule(callingId: callingA);
      expect(state.appointments, hasLength(1));
      expect(state.isScheduled(companionship), isTrue);
      // Agendada sai de "pendentes" e vai para "próximas".
      expect(state.pendingCompanionships, isEmpty);
      expect(
        state.appointmentFor(companionship)!.scheduledAt,
        scheduledInstant(when),
      );
    });

    test('não conta a dupla como entrevistada só por estar agendada', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.summary.interviewedCompanionships, 0);
      expect(state.isInterviewed(companionship), isFalse);
    });

    test('recusa agendamento no passado', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();

      await expectLater(
        repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().subtract(const Duration(minutes: 5)),
          interviewerId: leader.id,
        ),
        throwsA(isA<PastAppointmentDateTimeException>()),
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.appointments, isEmpty);
    });

    test('recusa segundo agendamento aberto para a mesma dupla', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      await expectLater(
        repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 3)),
          interviewerId: leader.id,
        ),
        throwsA(isA<CompanionshipAlreadyScheduledException>()),
      );
    });

    test('recusa entrevistador inativo', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.setLeaderActive(
        callingId: callingA,
        leaderId: leader.id,
        isActive: false,
      );

      await expectLater(
        repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          interviewerId: leader.id,
        ),
        throwsA(isA<InactiveInterviewerException>()),
      );
    });

    test('recusa entrevistador de outro chamado', () async {
      final foreignLeader = await seedLeader(calling: callingB);
      final companionship = await seedCompanionship();

      await expectLater(
        repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          interviewerId: foreignLeader.id,
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });

    test('recusa agendar dupla inativa', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.setCompanionshipActive(
        callingId: callingA,
        companionshipId: companionship,
        isActive: false,
      );

      await expectLater(
        repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          interviewerId: leader.id,
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });

    test('reagendar muda data e entrevistador na mesma linha', () async {
      final president = await seedLeader(label: 'Irmão P');
      final counselor = await seedLeader(
        role: MinisteringLeadershipRole.firstCounselor,
        label: 'Irmão C',
      );
      final companionship = await seedCompanionship();
      final appointment = await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: president.id,
      );

      final newWhen = DateTime.now().add(const Duration(days: 5));
      await repository.rescheduleInterview(
        callingId: callingA,
        appointmentId: appointment.id,
        scheduledAt: newWhen,
        interviewerId: counselor.id,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.appointments, hasLength(1));
      expect(state.appointments.single.id, appointment.id);
      expect(state.appointments.single.interviewerId, counselor.id);
      expect(state.appointments.single.scheduledAt, scheduledInstant(newWhen));
    });

    test('recusa reagendamento para o passado e mantém o original', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final originalWhen = DateTime.now().add(const Duration(days: 1));
      final appointment = await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: originalWhen,
        interviewerId: leader.id,
      );

      await expectLater(
        repository.rescheduleInterview(
          callingId: callingA,
          appointmentId: appointment.id,
          scheduledAt: DateTime.now().subtract(const Duration(minutes: 5)),
          interviewerId: leader.id,
        ),
        throwsA(isA<PastAppointmentDateTimeException>()),
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.appointments, hasLength(1));
      expect(
        state.appointments.single.scheduledAt,
        scheduledInstant(originalWhen),
      );
    });

    test(
      'cancelar apaga o agendamento e devolve a dupla para pendente',
      () async {
        final leader = await seedLeader();
        final companionship = await seedCompanionship();
        final appointment = await repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          interviewerId: leader.id,
        );

        await repository.cancelAppointment(
          callingId: callingA,
          appointmentId: appointment.id,
        );

        final state = await repository.loadModule(callingId: callingA);
        expect(state.appointments, isEmpty);
        expect(state.pendingCompanionships, hasLength(1));
      },
    );

    test('desativar a dupla cancela o agendamento aberto', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      await repository.setCompanionshipActive(
        callingId: callingA,
        companionshipId: companionship,
        isActive: false,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.appointments, isEmpty);
    });
  });

  group('conclusão do agendamento', () {
    test('concluir cria a entrevista com o entrevistador do plano', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;
      final appointment = await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      final interview = await repository.completeAppointment(
        callingId: callingA,
        appointmentId: appointment.id,
        completedOn: DateTime.now(),
        participantBrotherIds: members.map((member) => member.id).toList(),
      );

      expect(interview.interviewerId, leader.id);

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.appointments, isEmpty);
      expect(updated.summary.interviewedCompanionships, 1);
      expect(updated.isInterviewed(companionship), isTrue);

      final history = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(history.single.interviewerId, leader.id);
    });

    test(
      'concluir mantém o entrevistador mesmo que ele fique inativo',
      () async {
        final leader = await seedLeader();
        final companionship = await seedCompanionship();
        final state = await repository.loadModule(callingId: callingA);
        final members = state.companionships.single.members;
        final appointment = await repository.scheduleInterview(
          callingId: callingA,
          companionshipId: companionship,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          interviewerId: leader.id,
        );
        await repository.setLeaderActive(
          callingId: callingA,
          leaderId: leader.id,
          isActive: false,
        );

        final interview = await repository.completeAppointment(
          callingId: callingA,
          appointmentId: appointment.id,
          completedOn: DateTime.now(),
          participantBrotherIds: [members.first.id],
        );
        expect(interview.interviewerId, leader.id);
      },
    );

    test('concluir recusa data futura e não apaga o agendamento', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final appointment = await repository.scheduleInterview(
        callingId: callingA,
        companionshipId: companionship,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        interviewerId: leader.id,
      );

      await expectLater(
        repository.completeAppointment(
          callingId: callingA,
          appointmentId: appointment.id,
          completedOn: DateTime.now().add(const Duration(days: 1)),
          participantBrotherIds: [state.companionships.single.members.first.id],
        ),
        throwsA(isA<FutureInterviewDateException>()),
      );

      final after = await repository.loadModule(callingId: callingA);
      expect(after.appointments, hasLength(1));
    });

    test('registro direto aceita entrevistador e o guarda', () async {
      final leader = await seedLeader();
      final companionship = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);

      await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.now(),
        participantBrotherIds: [state.companionships.single.members.first.id],
        interviewerId: leader.id,
      );

      final history = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(history.single.interviewerId, leader.id);
    });

    test('corrigir troca o entrevistador sem criar outro registro', () async {
      final president = await seedLeader(label: 'Irmão P');
      final counselor = await seedLeader(
        role: MinisteringLeadershipRole.firstCounselor,
        label: 'Irmão C',
      );
      final companionship = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final recorded = await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.utc(2026, 8, 10),
        participantBrotherIds: [state.companionships.single.members.first.id],
        interviewerId: president.id,
      );

      await repository.updateInterview(
        callingId: callingA,
        interviewId: recorded.id,
        completedOn: DateTime.utc(2026, 8, 10),
        participantBrotherIds: [state.companionships.single.members.first.id],
        interviewerId: counselor.id,
      );

      final history = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(history, hasLength(1));
      expect(history.single.id, recorded.id);
      expect(history.single.interviewerId, counselor.id);
    });
  });
}
