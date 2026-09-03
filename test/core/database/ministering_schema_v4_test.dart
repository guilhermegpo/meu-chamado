import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';

/// Testes da migração v3 → v4 — liderança, entrevistador e agendamento.
///
/// A evolução é aditiva: cria `ministering_leaders` e `ministering_appointments`
/// e acrescenta `interviewer_id` a `ministering_interviews`. Os testes provam
/// que os dados da v3 continuam intactos e que as novas garantias por chamado
/// valem no banco, não só no repositório.
void main() {
  late Directory directory;
  late AppDatabase database;

  Future<void> openMigratedDatabase() async {
    directory = await Directory.systemTemp.createTemp('meu-chamado-v4-');
    final file = File(
      '${directory.path}${Platform.pathSeparator}database.sqlite',
    );

    final legacy = NativeDatabase(file);
    await legacy.ensureOpen(_VersionThreeSchema());
    await legacy.close();

    database = AppDatabase(NativeDatabase(file));
  }

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<int> countRows(String table) async {
    final row = await database
        .customSelect('SELECT COUNT(*) AS total FROM $table')
        .getSingle();
    return row.read<int>('total');
  }

  Future<void> seedLeader(String id, String callingId) =>
      database.customStatement('''
        INSERT INTO ministering_leaders
          (id, calling_id, display_label, role, is_active, created_at, updated_at)
        VALUES ('$id', '$callingId', 'Irmão $id', 'QUORUM_PRESIDENT', 1, 0, 0)
      ''');

  Future<void> seedAppointment(
    String id,
    String callingId,
    String companionshipId,
    String interviewerId,
  ) => database.customStatement('''
        INSERT INTO ministering_appointments
          (id, calling_id, companionship_id, interviewer_id, scheduled_at,
           created_at, updated_at)
        VALUES ('$id', '$callingId', '$companionshipId', '$interviewerId',
                0, 0, 0)
      ''');

  test('migra v3 para v4 preservando os dados existentes', () async {
    await openMigratedDatabase();

    expect(database.schemaVersion, 4);

    final calling = await database
        .customSelect(
          'SELECT module_key FROM callings WHERE id = ?',
          variables: [Variable.withString('calling-a')],
        )
        .getSingle();
    expect(calling.read<String>('module_key'), 'ministering-secretary');

    expect(await countRows('ministering_brothers'), 2);
    expect(await countRows('ministering_companionships'), 1);
    expect(await countRows('ministering_interviews'), 1);
    expect(await countRows('ministering_interview_participants'), 1);

    // A entrevista da v3 sobrevive e a coluna nova entra nula.
    final interview = await database
        .customSelect(
          'SELECT interviewer_id FROM ministering_interviews WHERE id = ?',
          variables: [Variable.withString('interview-1')],
        )
        .getSingle();
    expect(interview.data['interviewer_id'], isNull);
  });

  test('cria as duas tabelas novas, vazias', () async {
    await openMigratedDatabase();

    expect(await countRows('ministering_leaders'), 0);
    expect(await countRows('ministering_appointments'), 0);
  });

  test('mantém as chaves estrangeiras ligadas e o banco íntegro', () async {
    await openMigratedDatabase();

    final pragma = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(pragma.data.values.single, 1);

    final check = await database.customSelect('PRAGMA foreign_key_check').get();
    expect(check, isEmpty);
  });

  test('recusa agendamento apontando para dupla de outro chamado', () async {
    await openMigratedDatabase();

    await seedLeader('leader-a', 'calling-a');
    // companionship-1 pertence ao calling-a (vem da v3); o agendamento diz
    // calling-b.
    await expectLater(
      seedAppointment('appt-1', 'calling-b', 'companionship-1', 'leader-a'),
      throwsA(anything),
    );
  });

  test('recusa entrevistador de outro chamado no agendamento', () async {
    await openMigratedDatabase();

    await seedLeader('leader-b', 'calling-b');
    await expectLater(
      seedAppointment('appt-1', 'calling-a', 'companionship-1', 'leader-b'),
      throwsA(anything),
    );
  });

  test('recusa um segundo agendamento aberto para a mesma dupla', () async {
    await openMigratedDatabase();

    await seedLeader('leader-a', 'calling-a');
    await seedAppointment('appt-1', 'calling-a', 'companionship-1', 'leader-a');

    await expectLater(
      seedAppointment('appt-2', 'calling-a', 'companionship-1', 'leader-a'),
      throwsA(anything),
    );
  });

  test('recusa apagar líder que consta em um agendamento', () async {
    await openMigratedDatabase();

    await seedLeader('leader-a', 'calling-a');
    await seedAppointment('appt-1', 'calling-a', 'companionship-1', 'leader-a');

    // RESTRICT: a operação do produto é desativar o líder, não excluir.
    await expectLater(
      database.customStatement(
        "DELETE FROM ministering_leaders WHERE id = 'leader-a'",
      ),
      throwsA(anything),
    );
  });

  test('apagar o chamado leva liderança e agendamentos em cascata', () async {
    await openMigratedDatabase();

    await seedLeader('leader-a', 'calling-a');
    await seedAppointment('appt-1', 'calling-a', 'companionship-1', 'leader-a');

    await database.customStatement(
      "DELETE FROM callings WHERE id = 'calling-a'",
    );

    expect(await countRows('ministering_leaders'), 0);
    expect(await countRows('ministering_appointments'), 0);
    expect(await countRows('ministering_interviews'), 0);
  });

  test('cancelar o agendamento não toca na entrevista realizada', () async {
    await openMigratedDatabase();

    await seedLeader('leader-a', 'calling-a');
    await seedAppointment('appt-1', 'calling-a', 'companionship-1', 'leader-a');

    await database.customStatement(
      "DELETE FROM ministering_appointments WHERE id = 'appt-1'",
    );

    expect(await countRows('ministering_appointments'), 0);
    expect(await countRows('ministering_interviews'), 1);
  });
}

/// Banco na versão 3, com dados, para servir de ponto de partida da migração.
class _VersionThreeSchema extends QueryExecutorUser {
  static const _statements = [
    '''
      CREATE TABLE workspaces (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE users (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        photo_path TEXT NULL,
        created_at INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE memberships (
        workspace_id TEXT NOT NULL REFERENCES workspaces(id),
        user_id TEXT NOT NULL REFERENCES users(id),
        role TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (workspace_id, user_id)
      )
    ''',
    '''
      CREATE TABLE callings (
        id TEXT NOT NULL PRIMARY KEY,
        workspace_id TEXT NOT NULL REFERENCES workspaces(id),
        user_id TEXT NOT NULL REFERENCES users(id),
        title TEXT NOT NULL,
        module_key TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        archived_at INTEGER NULL,
        FOREIGN KEY (workspace_id, user_id)
          REFERENCES memberships (workspace_id, user_id) ON DELETE CASCADE
      )
    ''',
    '''
      CREATE TABLE app_preferences (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE ministering_brothers (
        id TEXT NOT NULL PRIMARY KEY,
        calling_id TEXT NOT NULL REFERENCES callings (id) ON DELETE CASCADE,
        display_label TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (id, calling_id)
      )
    ''',
    '''
      CREATE TABLE ministering_companionships (
        id TEXT NOT NULL PRIMARY KEY,
        calling_id TEXT NOT NULL REFERENCES callings (id) ON DELETE CASCADE,
        display_label TEXT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (id, calling_id)
      )
    ''',
    '''
      CREATE TABLE ministering_companionship_members (
        companionship_id TEXT NOT NULL,
        brother_id TEXT NOT NULL,
        calling_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (companionship_id, brother_id),
        FOREIGN KEY (companionship_id, calling_id)
          REFERENCES ministering_companionships (id, calling_id)
          ON DELETE CASCADE,
        FOREIGN KEY (brother_id, calling_id)
          REFERENCES ministering_brothers (id, calling_id) ON DELETE RESTRICT
      )
    ''',
    '''
      CREATE TABLE ministering_interviews (
        id TEXT NOT NULL PRIMARY KEY,
        calling_id TEXT NOT NULL REFERENCES callings (id) ON DELETE CASCADE,
        companionship_id TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE (id, calling_id),
        FOREIGN KEY (companionship_id, calling_id)
          REFERENCES ministering_companionships (id, calling_id)
          ON DELETE CASCADE
      )
    ''',
    '''
      CREATE TABLE ministering_interview_participants (
        interview_id TEXT NOT NULL,
        brother_id TEXT NOT NULL,
        calling_id TEXT NOT NULL,
        companionship_id TEXT NOT NULL,
        PRIMARY KEY (interview_id, brother_id),
        FOREIGN KEY (interview_id, calling_id)
          REFERENCES ministering_interviews (id, calling_id) ON DELETE CASCADE,
        FOREIGN KEY (brother_id, calling_id)
          REFERENCES ministering_brothers (id, calling_id) ON DELETE RESTRICT
      )
    ''',
    "INSERT INTO workspaces VALUES ('ws', 'Workspace v3', 'LOCAL', 0)",
    "INSERT INTO users VALUES ('user', 'Administrador v3', NULL, 0)",
    "INSERT INTO memberships VALUES ('ws', 'user', 'ADMIN', 0)",
    '''
      INSERT INTO callings VALUES (
        'calling-a', 'ws', 'user', 'Secretário da Ministração',
        'ministering-secretary', 'ACTIVE', 0, NULL
      )
    ''',
    '''
      INSERT INTO callings VALUES (
        'calling-b', 'ws', 'user', 'Outro chamado',
        'ministering-secretary', 'ACTIVE', 0, NULL
      )
    ''',
    '''
      INSERT INTO ministering_brothers
        (id, calling_id, display_label, is_active, created_at, updated_at)
      VALUES ('brother-1', 'calling-a', 'Irmão A', 1, 0, 0)
    ''',
    '''
      INSERT INTO ministering_brothers
        (id, calling_id, display_label, is_active, created_at, updated_at)
      VALUES ('brother-2', 'calling-a', 'Irmão B', 1, 0, 0)
    ''',
    '''
      INSERT INTO ministering_companionships
        (id, calling_id, display_label, is_active, created_at, updated_at)
      VALUES ('companionship-1', 'calling-a', NULL, 1, 0, 0)
    ''',
    '''
      INSERT INTO ministering_companionship_members
        (companionship_id, brother_id, calling_id, created_at)
      VALUES ('companionship-1', 'brother-1', 'calling-a', 0)
    ''',
    '''
      INSERT INTO ministering_companionship_members
        (companionship_id, brother_id, calling_id, created_at)
      VALUES ('companionship-1', 'brother-2', 'calling-a', 0)
    ''',
    '''
      INSERT INTO ministering_interviews
        (id, calling_id, companionship_id, completed_at, created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-1', 0, 0)
    ''',
    '''
      INSERT INTO ministering_interview_participants
        (interview_id, brother_id, calling_id, companionship_id)
      VALUES ('interview-1', 'brother-1', 'calling-a', 'companionship-1')
    ''',
  ];

  @override
  int get schemaVersion => 3;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {
    await executor.ensureOpen(this);
    for (final statement in _statements) {
      await executor.runCustom(statement, const []);
    }
  }
}
