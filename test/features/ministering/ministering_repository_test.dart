import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_exceptions.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

/// Todos os dados aqui são fictícios, como exige a política do módulo.
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

  group('irmãos ministradores', () {
    test('cria com identificação normalizada', () async {
      final brother = await repository.createBrother(
        callingId: callingA,
        displayLabel: '  Irmão A  ',
      );

      expect(brother.displayLabel, 'Irmão A');
      expect(brother.isActive, isTrue);
    });

    test('recusa identificação vazia', () async {
      await expectLater(
        repository.createBrother(callingId: callingA, displayLabel: '   '),
        throwsA(isA<InvalidMinisteringLabelException>()),
      );
    });

    test('recusa identificação com mais de 60 caracteres', () async {
      await expectLater(
        repository.createBrother(callingId: callingA, displayLabel: 'x' * 61),
        throwsA(isA<InvalidMinisteringLabelException>()),
      );
    });

    test('desativar preserva o irmão e o remove da seleção ativa', () async {
      final ids = await createBrothers(2);
      await repository.setBrotherActive(
        callingId: callingA,
        brotherId: ids.first,
        isActive: false,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.brothers, hasLength(2));
      expect(state.activeBrothers, hasLength(1));
    });

    test('não alcança irmão de outro chamado', () async {
      final ids = await createBrothers(1, calling: callingB);

      await expectLater(
        repository.updateBrother(
          callingId: callingA,
          brotherId: ids.single,
          displayLabel: 'Renomeado',
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });
  });

  group('duplas', () {
    test('cria dupla de dois integrantes', () async {
      final ids = await createBrothers(2);
      final id = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      final state = await repository.loadModule(callingId: callingA);
      final companionship = state.companionships.single;
      expect(companionship.id, id);
      expect(companionship.members, hasLength(2));
      expect(companionship.title, 'Irmão A · Irmão B');
    });

    test('cria dupla de três integrantes', () async {
      final ids = await createBrothers(3);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.companionships.single.members, hasLength(3));
    });

    test('recusa dupla com um só integrante', () async {
      final ids = await createBrothers(1);
      await expectLater(
        repository.createCompanionship(callingId: callingA, brotherIds: ids),
        throwsA(isA<InvalidCompanionshipSizeException>()),
      );
    });

    test('recusa dupla com quatro integrantes', () async {
      final ids = await createBrothers(4);
      await expectLater(
        repository.createCompanionship(callingId: callingA, brotherIds: ids),
        throwsA(isA<InvalidCompanionshipSizeException>()),
      );
    });

    test('recusa o mesmo irmão repetido', () async {
      final ids = await createBrothers(2);
      await expectLater(
        repository.createCompanionship(
          callingId: callingA,
          brotherIds: [ids.first, ids.first],
        ),
        throwsA(isA<InvalidCompanionshipSizeException>()),
      );
    });

    test('recusa irmão inativo em nova dupla', () async {
      final ids = await createBrothers(2);
      await repository.setBrotherActive(
        callingId: callingA,
        brotherId: ids.first,
        isActive: false,
      );

      await expectLater(
        repository.createCompanionship(callingId: callingA, brotherIds: ids),
        throwsA(isA<InactiveBrotherException>()),
      );
    });

    test('irmão inativo permanece nas duplas antigas', () async {
      final ids = await createBrothers(2);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );
      await repository.setBrotherActive(
        callingId: callingA,
        brotherId: ids.first,
        isActive: false,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.companionships.single.members, hasLength(2));
    });

    test('recusa irmão de outro chamado', () async {
      final local = await createBrothers(1);
      final foreign = await createBrothers(1, calling: callingB);

      await expectLater(
        repository.createCompanionship(
          callingId: callingA,
          brotherIds: [local.single, foreign.single],
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });

    test('falha na composição não deixa dupla órfã', () async {
      final ids = await createBrothers(1);

      await expectLater(
        repository.createCompanionship(callingId: callingA, brotherIds: ids),
        throwsA(isA<InvalidCompanionshipSizeException>()),
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.companionships, isEmpty);
    });

    test('trocar integrantes substitui a composição', () async {
      final ids = await createBrothers(3);
      final id = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: [ids[0], ids[1]],
      );

      await repository.updateCompanionship(
        callingId: callingA,
        companionshipId: id,
        brotherIds: [ids[0], ids[2]],
      );

      final state = await repository.loadModule(callingId: callingA);
      final labels = state.companionships.single.members
          .map((member) => member.displayLabel)
          .toList();
      expect(labels, ['Irmão A', 'Irmão C']);
    });

    test('usa o rótulo próprio quando informado', () async {
      final ids = await createBrothers(2);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
        displayLabel: 'Dupla 1',
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.companionships.single.title, 'Dupla 1');
    });
  });

  group('entrevistas e resumo do trimestre', () {
    Future<String> seedCompanionship({String calling = callingA}) async {
      final ids = await createBrothers(2, calling: calling);
      return repository.createCompanionship(
        callingId: calling,
        brotherIds: ids,
      );
    }

    test('chamado sem dados mostra zero de zero', () async {
      final state = await repository.loadModule(callingId: callingA);

      expect(state.summary.activeCompanionships, 0);
      expect(state.summary.interviewedCompanionships, 0);
      expect(state.summary.pending, 0);
      expect(state.pendingCompanionships, isEmpty);
    });

    test('dupla sem entrevista aparece como pendente', () async {
      await seedCompanionship();

      final state = await repository.loadModule(callingId: callingA);
      expect(state.summary.activeCompanionships, 1);
      expect(state.summary.interviewedCompanionships, 0);
      expect(state.pendingCompanionships, hasLength(1));
    });

    test('registrar entrevista move a dupla para entrevistada', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;

      await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.now(),
        participantBrotherIds: members.map((member) => member.id).toList(),
      );

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.summary.interviewedCompanionships, 1);
      expect(updated.pendingCompanionships, isEmpty);
      expect(updated.isInterviewed(id), isTrue);
    });

    test('entrevista com apenas um dos integrantes conta', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final first = state.companionships.single.members.first;

      final interview = await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.now(),
        participantBrotherIds: [first.id],
      );

      expect(interview.participantIds, [first.id]);

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.summary.interviewedCompanionships, 1);
    });

    test('duas entrevistas da mesma dupla contam a dupla uma vez', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;

      for (var index = 0; index < 2; index++) {
        await repository.recordInterview(
          callingId: callingA,
          companionshipId: id,
          completedOn: DateTime.now(),
          participantBrotherIds: [members.first.id],
        );
      }

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.summary.interviewedCompanionships, 1);

      // O histórico das duas permanece: contar uma vez não é apagar a segunda.
      final interviews = await repository.listInterviews(
        callingId: callingA,
        companionshipId: id,
      );
      expect(interviews, hasLength(2));
    });

    test('entrevista de outro trimestre não conta no atual', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;

      await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.utc(2020, 2, 10),
        participantBrotherIds: [members.first.id],
      );

      final current = await repository.loadModule(callingId: callingA);
      expect(current.summary.interviewedCompanionships, 0);

      final past = await repository.loadModule(
        callingId: callingA,
        quarter: const Quarter(2020, 1),
      );
      expect(past.summary.interviewedCompanionships, 1);
    });

    test('respeita os limites do trimestre', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;

      await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.utc(2020, 9, 30),
        participantBrotherIds: [members.first.id],
      );

      final third = await repository.loadModule(
        callingId: callingA,
        quarter: const Quarter(2020, 3),
      );
      expect(third.summary.interviewedCompanionships, 1);

      final fourth = await repository.loadModule(
        callingId: callingA,
        quarter: const Quarter(2020, 4),
      );
      expect(fourth.summary.interviewedCompanionships, 0);
    });

    test('dupla inativa sai do denominador mas guarda o histórico', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final members = state.companionships.single.members;

      await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.now(),
        participantBrotherIds: [members.first.id],
      );
      await repository.setCompanionshipActive(
        callingId: callingA,
        companionshipId: id,
        isActive: false,
      );

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.summary.activeCompanionships, 0);
      expect(updated.summary.interviewedCompanionships, 0);

      final interviews = await repository.listInterviews(
        callingId: callingA,
        companionshipId: id,
      );
      expect(interviews, hasLength(1));
    });

    test('não reativa dupla com integrante inativo', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final member = state.companionships.single.members.first;

      await repository.setCompanionshipActive(
        callingId: callingA,
        companionshipId: id,
        isActive: false,
      );
      await repository.setBrotherActive(
        callingId: callingA,
        brotherId: member.id,
        isActive: false,
      );

      await expectLater(
        repository.setCompanionshipActive(
          callingId: callingA,
          companionshipId: id,
          isActive: true,
        ),
        throwsA(isA<InactiveBrotherException>()),
      );

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.companionships.single.isActive, isFalse);
    });

    test('recusa entrevista sem participante', () async {
      final id = await seedCompanionship();

      await expectLater(
        repository.recordInterview(
          callingId: callingA,
          companionshipId: id,
          completedOn: DateTime.now(),
          participantBrotherIds: const [],
        ),
        throwsA(isA<InterviewWithoutParticipantsException>()),
      );
    });

    test('recusa participante que não compõe a dupla', () async {
      final id = await seedCompanionship();
      final outsider = await repository.createBrother(
        callingId: callingA,
        displayLabel: 'Irmão Z',
      );

      await expectLater(
        repository.recordInterview(
          callingId: callingA,
          companionshipId: id,
          completedOn: DateTime.now(),
          participantBrotherIds: [outsider.id],
        ),
        throwsA(isA<ParticipantOutsideCompanionshipException>()),
      );
    });

    test('recusa data futura', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);

      await expectLater(
        repository.recordInterview(
          callingId: callingA,
          companionshipId: id,
          completedOn: DateTime.now().add(const Duration(days: 1)),
          participantBrotherIds: [state.companionships.single.members.first.id],
        ),
        throwsA(isA<FutureInterviewDateException>()),
      );
    });

    test('recusa entrevista de dupla de outro chamado', () async {
      final foreign = await seedCompanionship(calling: callingB);
      final state = await repository.loadModule(callingId: callingB);

      await expectLater(
        repository.recordInterview(
          callingId: callingA,
          companionshipId: foreign,
          completedOn: DateTime.now(),
          participantBrotherIds: [state.companionships.single.members.first.id],
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });

    test('remover entrevista devolve a dupla para pendente', () async {
      final id = await seedCompanionship();
      final state = await repository.loadModule(callingId: callingA);
      final interview = await repository.recordInterview(
        callingId: callingA,
        companionshipId: id,
        completedOn: DateTime.now(),
        participantBrotherIds: [state.companionships.single.members.first.id],
      );

      await repository.deleteInterview(
        callingId: callingA,
        interviewId: interview.id,
      );

      final updated = await repository.loadModule(callingId: callingA);
      expect(updated.summary.interviewedCompanionships, 0);
      expect(updated.pendingCompanionships, hasLength(1));
    });
  });

  group('data da entrevista na ida e na volta', () {
    test('volta do banco em UTC, no dia que foi registrado', () async {
      final ids = await createBrothers(2);
      final companionship = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );
      // Primeiro dia de um trimestre: é onde um deslocamento de fuso na
      // leitura joga a entrevista para o trimestre anterior.
      await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.utc(2026, 7),
        participantBrotherIds: ids,
      );

      final interview = (await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      )).single;

      expect(interview.completedAt.isUtc, isTrue);
      expect(interview.completedAt, DateTime.utc(2026, 7));
      expect(interview.quarter, const Quarter(2026, 3));
    });
  });

  group('exclusão de irmão', () {
    test('irmão nunca usado pode ser excluído', () async {
      final ids = await createBrothers(1);

      final check = await repository.inspectBrotherRemoval(
        callingId: callingA,
        brotherId: ids.single,
      );
      expect(check.canDelete, isTrue);
      expect(check.hasHistory, isFalse);

      await repository.deleteBrother(
        callingId: callingA,
        brotherId: ids.single,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.brothers, isEmpty);
    });

    test('irmão que compõe dupla não pode ser excluído', () async {
      final ids = await createBrothers(2);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      final check = await repository.inspectBrotherRemoval(
        callingId: callingA,
        brotherId: ids.first,
      );
      expect(check.canDelete, isFalse);
      expect(check.companionships, 1);
      expect(check.hasHistory, isFalse);

      await expectLater(
        repository.deleteBrother(callingId: callingA, brotherId: ids.first),
        throwsA(isA<MinisteringRecordInUseException>()),
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.brothers, hasLength(2));
    });

    test('irmão com entrevista registrada não pode ser excluído', () async {
      final ids = await createBrothers(2);
      final companionship = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );
      await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.now(),
        participantBrotherIds: ids,
      );

      final check = await repository.inspectBrotherRemoval(
        callingId: callingA,
        brotherId: ids.first,
      );
      expect(check.hasHistory, isTrue);
      expect(check.interviews, 1);

      await expectLater(
        repository.deleteBrother(callingId: callingA, brotherId: ids.first),
        throwsA(isA<MinisteringRecordInUseException>()),
      );
    });

    test('a mensagem de recusa não nomeia ninguém', () async {
      final ids = await createBrothers(2);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      try {
        await repository.deleteBrother(callingId: callingA, brotherId: ids[0]);
        fail('deveria ter recusado');
      } on MinisteringRecordInUseException catch (error) {
        expect(error.message, isNot(contains('Irmão A')));
        expect(error.message, contains('dupla'));
      }
    });

    test('não exclui irmão de outro chamado', () async {
      final foreign = await createBrothers(1, calling: callingB);

      await expectLater(
        repository.deleteBrother(
          callingId: callingA,
          brotherId: foreign.single,
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });
  });

  group('exclusão de dupla', () {
    test('dupla sem entrevista pode ser excluída e os irmãos ficam', () async {
      final ids = await createBrothers(2);
      final companionship = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      final check = await repository.inspectCompanionshipRemoval(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(check.canDelete, isTrue);

      await repository.deleteCompanionship(
        callingId: callingA,
        companionshipId: companionship,
      );

      final state = await repository.loadModule(callingId: callingA);
      expect(state.companionships, isEmpty);
      expect(state.brothers, hasLength(2));
    });

    test('dupla com entrevista não pode ser excluída', () async {
      final ids = await createBrothers(2);
      final companionship = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );
      await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.now(),
        participantBrotherIds: ids,
      );

      await expectLater(
        repository.deleteCompanionship(
          callingId: callingA,
          companionshipId: companionship,
        ),
        throwsA(isA<MinisteringRecordInUseException>()),
      );

      // A FK dupla→entrevista é CASCADE: se a checagem falhasse, o histórico
      // teria sumido junto e sem aviso.
      final interviews = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(interviews, hasLength(1));
    });
  });

  group('correção de entrevista', () {
    late List<String> ids;
    late String companionship;
    late String interview;

    setUp(() async {
      ids = await createBrothers(2);
      companionship = await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );
      final recorded = await repository.recordInterview(
        callingId: callingA,
        companionshipId: companionship,
        completedOn: DateTime.utc(2026, 8, 10),
        participantBrotherIds: ids,
      );
      interview = recorded.id;
    });

    test('corrige a data sem criar outro registro', () async {
      await repository.updateInterview(
        callingId: callingA,
        interviewId: interview,
        completedOn: DateTime.utc(2026, 8, 12),
        participantBrotherIds: ids,
      );

      final list = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(list, hasLength(1));
      expect(list.single.id, interview);
      expect(list.single.completedAt, DateTime.utc(2026, 8, 12));
    });

    test('corrige os participantes', () async {
      await repository.updateInterview(
        callingId: callingA,
        interviewId: interview,
        completedOn: DateTime.utc(2026, 8, 10),
        participantBrotherIds: [ids.first],
      );

      final list = await repository.listInterviews(
        callingId: callingA,
        companionshipId: companionship,
      );
      expect(list.single.participantIds, [ids.first]);
    });

    test('recusa data futura na correção', () async {
      await expectLater(
        repository.updateInterview(
          callingId: callingA,
          interviewId: interview,
          completedOn: DateTime.now().add(const Duration(days: 1)),
          participantBrotherIds: ids,
        ),
        throwsA(isA<FutureInterviewDateException>()),
      );
    });

    test('recusa correção sem participante', () async {
      await expectLater(
        repository.updateInterview(
          callingId: callingA,
          interviewId: interview,
          completedOn: DateTime.utc(2026, 8, 10),
          participantBrotherIds: const [],
        ),
        throwsA(isA<InterviewWithoutParticipantsException>()),
      );
    });

    test('recusa participante fora da dupla', () async {
      final outsider = await createBrothers(3);

      await expectLater(
        repository.updateInterview(
          callingId: callingA,
          interviewId: interview,
          completedOn: DateTime.utc(2026, 8, 10),
          participantBrotherIds: [outsider.last],
        ),
        throwsA(isA<ParticipantOutsideCompanionshipException>()),
      );
    });

    test('não corrige entrevista de outro chamado', () async {
      await expectLater(
        repository.updateInterview(
          callingId: callingB,
          interviewId: interview,
          completedOn: DateTime.utc(2026, 8, 10),
          participantBrotherIds: ids,
        ),
        throwsA(isA<MinisteringRecordNotFoundException>()),
      );
    });
  });

  group('isolamento entre chamados', () {
    test('dados de um chamado não aparecem no outro', () async {
      final ids = await createBrothers(2);
      await repository.createCompanionship(
        callingId: callingA,
        brotherIds: ids,
      );

      final other = await repository.loadModule(callingId: callingB);
      expect(other.brothers, isEmpty);
      expect(other.companionships, isEmpty);
      expect(other.summary.activeCompanionships, 0);
    });
  });
}
