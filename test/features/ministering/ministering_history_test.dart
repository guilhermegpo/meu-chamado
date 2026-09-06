import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

import 'ministering_harness.dart';

/// Integridade do histórico trimestral: o denominador de um trimestre encerrado
/// não pode se mover, mesmo que o estado atual das duplas mude. Correções de
/// entrevista continuam recalculando o numerador. Todos os dados são fictícios.
void main() {
  late AppDatabase database;
  late DateTime clock;
  late MinisteringRepository repository;

  const q3 = Quarter(2026, 3); // Julho — Setembro
  const q4 = Quarter(2026, 4); // Outubro — Dezembro
  final inQ3 = DateTime.utc(2026, 8, 20);
  final inQ4 = DateTime.utc(2026, 11, 10);

  setUp(() async {
    database = await openMinisteringTestDatabase();
    // Fim do Q3 2026: dá para registrar entrevistas em datas anteriores do
    // trimestre sem esbarrar na trava de data futura.
    clock = DateTime.utc(2026, 9, 28);
    repository = MinisteringRepository(database, clock: () => clock);
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

  Future<MinisteringHistoricalQuarter> historyFor(Quarter quarter) async {
    final history = await repository.loadQuarterHistory(
      callingId: ministeringTestCallingId,
    );
    return history.firstWhere((q) => q.quarter == quarter);
  }

  test('o trimestre corrente aparece em andamento, sem snapshot', () async {
    final ids = await seedBrothers(4);
    await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);

    final history = await repository.loadQuarterHistory(
      callingId: ministeringTestCallingId,
    );

    expect(history, hasLength(1));
    expect(history.single.quarter, q3);
    expect(history.single.inProgress, isTrue);
    expect(history.single.eligible, 2);
    expect(history.single.interviewed, 0);

    final snapshots = await database
        .customSelect('SELECT COUNT(*) c FROM ministering_quarter_snapshots')
        .getSingle();
    expect(snapshots.read<int>('c'), 0);
  });

  test('vira o trimestre e congela o escopo uma única vez', () async {
    final ids = await seedBrothers(6);
    final a = await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);
    await seedCompanionship([ids[4], ids[5]]);
    await record(a, inQ3);

    clock = inQ4;
    var q3Summary = await historyFor(q3);
    expect(q3Summary.inProgress, isFalse);
    expect(q3Summary.eligible, 3);
    expect(q3Summary.interviewed, 1);

    final finalizedAt =
        (await database
                .customSelect(
                  'SELECT finalized_at FROM ministering_quarter_snapshots',
                )
                .getSingle())
            .read<int>('finalized_at');

    // Uma segunda leitura não recongela: o finalized_at não muda.
    clock = DateTime.utc(2026, 12, 20);
    q3Summary = await historyFor(q3);
    final again =
        (await database
                .customSelect(
                  'SELECT finalized_at FROM ministering_quarter_snapshots',
                )
                .getSingle())
            .read<int>('finalized_at');
    expect(again, finalizedAt);
    expect(q3Summary.eligible, 3);
  });

  test(
    'dupla criada depois não entra no denominador de um trimestre passado',
    () async {
      final ids = await seedBrothers(8);
      await seedCompanionship([ids[0], ids[1]]);
      await seedCompanionship([ids[2], ids[3]]);
      await seedCompanionship([ids[4], ids[5]]);

      clock = inQ4;
      // Congela Q3 com 3 duplas.
      await repository.loadModule(callingId: ministeringTestCallingId);
      // Uma quarta dupla nasce no Q4.
      await seedCompanionship([ids[6], ids[7]]);

      expect((await historyFor(q3)).eligible, 3);
      expect((await historyFor(q4)).eligible, 4);
      expect((await historyFor(q4)).inProgress, isTrue);
    },
  );

  test(
    'desativar dupla depois não muda o denominador do trimestre passado',
    () async {
      final ids = await seedBrothers(6);
      final a = await seedCompanionship([ids[0], ids[1]]);
      await seedCompanionship([ids[2], ids[3]]);
      await seedCompanionship([ids[4], ids[5]]);
      await record(a, inQ3);

      clock = inQ4;
      await repository.setCompanionshipActive(
        callingId: ministeringTestCallingId,
        companionshipId: a,
        isActive: false,
      );

      expect((await historyFor(q3)).eligible, 3);
      // A dupla inativa some do trimestre corrente, mas segue no histórico.
      expect((await historyFor(q4)).eligible, 2);
    },
  );

  test(
    'múltiplas entrevistas da mesma dupla contam uma vez no numerador',
    () async {
      final ids = await seedBrothers(4);
      final a = await seedCompanionship([ids[0], ids[1]]);
      await seedCompanionship([ids[2], ids[3]]);
      await record(a, inQ3);
      await record(a, DateTime.utc(2026, 9, 10));

      clock = inQ4;
      final summary = await historyFor(q3);
      expect(summary.eligible, 2);
      expect(summary.interviewed, 1);
    },
  );

  test(
    'adicionar uma entrevista omitida em trimestre passado sobe o numerador',
    () async {
      final ids = await seedBrothers(6);
      final a = await seedCompanionship([ids[0], ids[1]]);
      final b = await seedCompanionship([ids[2], ids[3]]);
      await seedCompanionship([ids[4], ids[5]]);
      await record(a, inQ3);
      await record(b, inQ3);

      clock = inQ4;
      expect((await historyFor(q3)).interviewed, 2);

      // A terceira dupla foi entrevistada no Q3, mas o registro só entra agora.
      final c =
          (await repository.loadModule(callingId: ministeringTestCallingId))
              .activeCompanionships
              .map((e) => e.id)
              .firstWhere((id) => id != a && id != b);
      await record(c, DateTime.utc(2026, 9, 25));

      final summary = await historyFor(q3);
      expect(summary.eligible, 3, reason: 'o escopo não muda');
      expect(summary.interviewed, 3, reason: 'o numerador recalcula');
    },
  );

  test(
    'remover uma entrevista de trimestre passado desce o numerador',
    () async {
      final ids = await seedBrothers(4);
      final a = await seedCompanionship([ids[0], ids[1]]);
      await seedCompanionship([ids[2], ids[3]]);
      final interview = await repository.recordInterview(
        callingId: ministeringTestCallingId,
        companionshipId: a,
        completedOn: inQ3,
        participantBrotherIds: [ids[0]],
      );

      clock = inQ4;
      expect((await historyFor(q3)).interviewed, 1);

      await repository.deleteInterview(
        callingId: ministeringTestCallingId,
        interviewId: interview.id,
      );

      final summary = await historyFor(q3);
      expect(summary.eligible, 2);
      expect(summary.interviewed, 0);
    },
  );

  test('materializa todos os trimestres pulados com o app fechado', () async {
    final ids = await seedBrothers(4);
    await seedCompanionship([ids[0], ids[1]]);
    await seedCompanionship([ids[2], ids[3]]);

    // Fecha no Q3 2026, reabre no Q1 2028.
    clock = DateTime.utc(2028, 2, 1);
    final history = await repository.loadQuarterHistory(
      callingId: ministeringTestCallingId,
    );

    // O primeiro da lista é o trimestre corrente, em andamento.
    expect(history.first.quarter, const Quarter(2028, 1));
    expect(history.first.inProgress, isTrue);

    final frozen = history
        .where((q) => !q.inProgress)
        .map((q) => q.quarter)
        .toList();
    expect(
      frozen,
      containsAll(const [
        Quarter(2026, 3),
        Quarter(2026, 4),
        Quarter(2027, 1),
        Quarter(2027, 2),
        Quarter(2027, 3),
        Quarter(2027, 4),
      ]),
    );
    // Nenhum trimestre futuro nem o corrente foi congelado.
    expect(frozen, isNot(contains(const Quarter(2028, 1))));
    expect(frozen, isNot(contains(const Quarter(2028, 2))));
    // Todos os snapshots com o mesmo escopo — nada mudou enquanto fechado.
    for (final q in history.where((q) => !q.inProgress)) {
      expect(q.eligible, 2, reason: q.quarter.label);
    }
  });

  test('o histórico de um chamado não enxerga o de outro', () async {
    final other = await openMinisteringTestDatabase(
      callingIds: const [ministeringTestCallingId, 'calling-b'],
    );
    addTearDown(other.close);
    final repo = MinisteringRepository(other, clock: () => clock);

    final aIds = <String>[];
    for (final l in ['A', 'B']) {
      aIds.add(
        (await repo.createBrother(
          callingId: ministeringTestCallingId,
          displayLabel: 'Irmão $l',
        )).id,
      );
    }
    await repo.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: aIds,
    );

    clock = inQ4;
    final aHistory = await repo.loadQuarterHistory(
      callingId: ministeringTestCallingId,
    );
    final bHistory = await repo.loadQuarterHistory(callingId: 'calling-b');

    expect((aHistory.firstWhere((q) => q.quarter == q3)).eligible, 1);
    // calling-b não tem duplas nem entrevistas: nada a congelar.
    expect(bHistory, hasLength(1));
    expect(bHistory.single.inProgress, isTrue);
  });
}
