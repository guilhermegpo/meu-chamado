import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';

/// Testes da migração v4 → v5 — histórico trimestral.
///
/// A evolução é aditiva: cria `ministering_quarter_snapshots`,
/// `ministering_quarter_snapshot_companionships` e
/// `ministering_quarter_snapshot_members`. Nada existente é alterado. Todos os
/// dados são fictícios (ADR 0013).
void main() {
  late Directory directory;
  late AppDatabase database;

  Future<void> openMigratedDatabase() async {
    directory = await Directory.systemTemp.createTemp('meu-chamado-v5-');
    final file = File(
      '${directory.path}${Platform.pathSeparator}database.sqlite',
    );

    final legacy = NativeDatabase(file);
    await legacy.ensureOpen(_VersionFourSchema());
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

  test('migra v4 para v5 preservando os dados existentes', () async {
    await openMigratedDatabase();

    expect(database.schemaVersion, 5);

    expect(await countRows('ministering_brothers'), 2);
    expect(await countRows('ministering_companionships'), 1);
    expect(await countRows('ministering_interviews'), 1);
    expect(await countRows('ministering_appointments'), 1);
    expect(await countRows('ministering_leaders'), 1);
  });

  test('cria as três tabelas de snapshot, vazias', () async {
    await openMigratedDatabase();

    expect(await countRows('ministering_quarter_snapshots'), 0);
    expect(await countRows('ministering_quarter_snapshot_companionships'), 0);
    expect(await countRows('ministering_quarter_snapshot_members'), 0);
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

  Future<void> seedSnapshot() async {
    await database.customStatement(
      "INSERT INTO ministering_quarter_snapshots "
      "(id, calling_id, year, quarter, finalized_at, created_at) "
      "VALUES ('snap-1', 'calling-a', 2026, 3, 0, 0)",
    );
    await database.customStatement(
      "INSERT INTO ministering_quarter_snapshot_companionships "
      "(snapshot_id, companionship_id, calling_id) "
      "VALUES ('snap-1', 'companionship-1', 'calling-a')",
    );
    await database.customStatement(
      "INSERT INTO ministering_quarter_snapshot_members "
      "(snapshot_id, companionship_id, brother_id, calling_id) "
      "VALUES ('snap-1', 'companionship-1', 'brother-1', 'calling-a')",
    );
  }

  test('recusa snapshot apontando para dupla de outro chamado', () async {
    await openMigratedDatabase();

    await expectLater(
      database
          .customStatement(
            "INSERT INTO ministering_quarter_snapshots "
            "(id, calling_id, year, quarter, finalized_at, created_at) "
            "VALUES ('snap-x', 'calling-a', 2026, 3, 0, 0)",
          )
          .then(
            (_) => database.customStatement(
              "INSERT INTO ministering_quarter_snapshot_companionships "
              "(snapshot_id, companionship_id, calling_id) "
              "VALUES ('snap-x', 'companionship-1', 'calling-b')",
            ),
          ),
      throwsA(anything),
    );
  });

  test('um snapshot por trimestre por chamado', () async {
    await openMigratedDatabase();
    await seedSnapshot();

    await expectLater(
      database.customStatement(
        "INSERT INTO ministering_quarter_snapshots "
        "(id, calling_id, year, quarter, finalized_at, created_at) "
        "VALUES ('snap-2', 'calling-a', 2026, 3, 0, 0)",
      ),
      throwsA(anything),
    );
  });

  test('a dupla do escopo congelado não pode ser apagada', () async {
    await openMigratedDatabase();
    await seedSnapshot();

    // RESTRICT: apagar encolheria o denominador histórico. Desativar continua
    // permitido.
    await expectLater(
      database.customStatement(
        "DELETE FROM ministering_companionships WHERE id = 'companionship-1'",
      ),
      throwsA(anything),
    );
  });

  test('apagar o chamado leva os snapshots em cascata', () async {
    await openMigratedDatabase();
    await seedSnapshot();

    await database.customStatement(
      "DELETE FROM callings WHERE id = 'calling-a'",
    );

    expect(await countRows('ministering_quarter_snapshots'), 0);
    expect(await countRows('ministering_quarter_snapshot_companionships'), 0);
    expect(await countRows('ministering_quarter_snapshot_members'), 0);
  });
}

/// Banco na versão 4, com dados, para servir de ponto de partida da migração.
class _VersionFourSchema extends QueryExecutorUser {
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
      CREATE TABLE ministering_leaders (
        id TEXT NOT NULL PRIMARY KEY,
        calling_id TEXT NOT NULL REFERENCES callings (id) ON DELETE CASCADE,
        display_label TEXT NOT NULL,
        role TEXT NOT NULL,
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
        interviewer_id TEXT NULL
          REFERENCES ministering_leaders (id) ON DELETE RESTRICT,
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
    '''
      CREATE TABLE ministering_appointments (
        id TEXT NOT NULL PRIMARY KEY,
        calling_id TEXT NOT NULL REFERENCES callings (id) ON DELETE CASCADE,
        companionship_id TEXT NOT NULL,
        interviewer_id TEXT NOT NULL,
        scheduled_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (companionship_id),
        FOREIGN KEY (companionship_id, calling_id)
          REFERENCES ministering_companionships (id, calling_id)
          ON DELETE CASCADE,
        FOREIGN KEY (interviewer_id, calling_id)
          REFERENCES ministering_leaders (id, calling_id) ON DELETE RESTRICT
      )
    ''',
    "INSERT INTO workspaces VALUES ('ws', 'Workspace v4', 'LOCAL', 0)",
    "INSERT INTO users VALUES ('user', 'Administrador v4', NULL, 0)",
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
      INSERT INTO ministering_leaders
        (id, calling_id, display_label, role, is_active, created_at, updated_at)
      VALUES ('leader-1', 'calling-a', 'Irmão P', 'QUORUM_PRESIDENT', 1, 0, 0)
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
        (id, calling_id, companionship_id, interviewer_id, completed_at,
         created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-1', 'leader-1', 0, 0)
    ''',
    '''
      INSERT INTO ministering_appointments
        (id, calling_id, companionship_id, interviewer_id, scheduled_at,
         created_at, updated_at)
      VALUES ('appt-1', 'calling-a', 'companionship-1', 'leader-1', 0, 0, 0)
    ''',
  ];

  @override
  int get schemaVersion => 4;

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
