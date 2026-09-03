import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';

/// Testes da migração v2 → v3 (e adiante) — a fundação do módulo de ministração.
///
/// A migração só cria tabelas, o que a torna segura por construção. Justamente
/// por isso os testes precisam **provar** que os dados da v2 continuam
/// intactos, em vez de assumir. A evolução v3 → v4 tem cobertura própria em
/// `ministering_schema_v4_test.dart`.
void main() {
  late Directory directory;
  late AppDatabase database;

  Future<void> openMigratedDatabase() async {
    directory = await Directory.systemTemp.createTemp('meu-chamado-v3-');
    final file = File(
      '${directory.path}${Platform.pathSeparator}database.sqlite',
    );

    final legacy = NativeDatabase(file);
    await legacy.ensureOpen(_VersionTwoSchema());
    await legacy.close();

    database = AppDatabase(NativeDatabase(file));
  }

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<void> seedBrother(String id, String callingId) =>
      database.customStatement('''
        INSERT INTO ministering_brothers
          (id, calling_id, display_label, is_active, created_at, updated_at)
        VALUES ('$id', '$callingId', 'Irmão $id', 1, 0, 0)
      ''');

  Future<void> seedCompanionship(String id, String callingId) =>
      database.customStatement('''
        INSERT INTO ministering_companionships
          (id, calling_id, display_label, is_active, created_at, updated_at)
        VALUES ('$id', '$callingId', NULL, 1, 0, 0)
      ''');

  Future<void> seedMember(
    String companionshipId,
    String brotherId,
    String callingId,
  ) => database.customStatement('''
        INSERT INTO ministering_companionship_members
          (companionship_id, brother_id, calling_id, created_at)
        VALUES ('$companionshipId', '$brotherId', '$callingId', 0)
      ''');

  Future<int> countRows(String table) async {
    final row = await database
        .customSelect('SELECT COUNT(*) AS total FROM $table')
        .getSingle();
    return row.read<int>('total');
  }

  test('migra v2 para v3 preservando os dados existentes', () async {
    await openMigratedDatabase();

    expect(database.schemaVersion, 4);

    final workspace = await database
        .customSelect(
          'SELECT name FROM workspaces WHERE id = ?',
          variables: [Variable.withString('workspace-v2')],
        )
        .getSingle();
    expect(workspace.read<String>('name'), 'Workspace v2');

    final user = await database
        .customSelect(
          'SELECT name FROM users WHERE id = ?',
          variables: [Variable.withString('user-v2')],
        )
        .getSingle();
    expect(user.read<String>('name'), 'Administrador v2');

    final calling = await database
        .customSelect(
          'SELECT module_key FROM callings WHERE id = ?',
          variables: [Variable.withString('calling-a')],
        )
        .getSingle();
    expect(calling.read<String>('module_key'), 'ministering-secretary');

    final preference = await database
        .customSelect(
          'SELECT value FROM app_preferences WHERE key = ?',
          variables: [Variable.withString('theme')],
        )
        .getSingle();
    expect(preference.read<String>('value'), 'DARK');
  });

  test('cria as cinco tabelas do módulo, todas vazias', () async {
    await openMigratedDatabase();

    for (final table in const [
      'ministering_brothers',
      'ministering_companionships',
      'ministering_companionship_members',
      'ministering_interviews',
      'ministering_interview_participants',
    ]) {
      expect(await countRows(table), 0, reason: '$table deveria existir vazia');
    }
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

  test('recusa integrante de um chamado em dupla de outro chamado', () async {
    await openMigratedDatabase();

    await seedBrother('brother-b', 'calling-b');
    await seedCompanionship('companionship-a', 'calling-a');

    // O irmão pertence ao chamado B; a dupla, ao chamado A. A chave composta
    // torna a combinação impossível, não apenas indesejada.
    await expectLater(
      seedMember('companionship-a', 'brother-b', 'calling-a'),
      throwsA(anything),
    );
  });

  test('recusa o mesmo irmão duas vezes na mesma dupla', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');

    await expectLater(
      seedMember('companionship-a', 'brother-1', 'calling-a'),
      throwsA(anything),
    );
  });

  test('recusa entrevista apontando para dupla de outro chamado', () async {
    await openMigratedDatabase();

    await seedCompanionship('companionship-b', 'calling-b');

    await expectLater(
      database.customStatement('''
        INSERT INTO ministering_interviews
          (id, calling_id, companionship_id, completed_at, created_at)
        VALUES ('interview-1', 'calling-a', 'companionship-b', 0, 0)
      '''),
      throwsA(anything),
    );
  });

  test('recusa participante de outro chamado na entrevista', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedBrother('brother-b', 'calling-b');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');
    await database.customStatement('''
      INSERT INTO ministering_interviews
        (id, calling_id, companionship_id, completed_at, created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-a', 0, 0)
    ''');

    await expectLater(
      database.customStatement('''
        INSERT INTO ministering_interview_participants
          (interview_id, brother_id, calling_id, companionship_id)
        VALUES ('interview-1', 'brother-b', 'calling-a', 'companionship-a')
      '''),
      throwsA(anything),
    );
  });

  test('apagar o chamado remove os dados do módulo em cascata', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedBrother('brother-2', 'calling-a');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');
    await seedMember('companionship-a', 'brother-2', 'calling-a');
    await database.customStatement('''
      INSERT INTO ministering_interviews
        (id, calling_id, companionship_id, completed_at, created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-a', 0, 0)
    ''');
    await database.customStatement('''
      INSERT INTO ministering_interview_participants
        (interview_id, brother_id, calling_id, companionship_id)
      VALUES ('interview-1', 'brother-1', 'calling-a', 'companionship-a')
    ''');

    // Participantes e integrantes referenciam irmãos com RESTRICT, então a
    // cascata precisa limpá-los antes de chegar aos irmãos.
    await database.customStatement(
      "DELETE FROM callings WHERE id = 'calling-a'",
    );

    expect(await countRows('ministering_brothers'), 0);
    expect(await countRows('ministering_companionships'), 0);
    expect(await countRows('ministering_companionship_members'), 0);
    expect(await countRows('ministering_interviews'), 0);
    expect(await countRows('ministering_interview_participants'), 0);
  });

  test('recusa apagar irmão que ainda compõe uma dupla', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');

    // RESTRICT: apagar destruiria histórico. A operação do produto é desativar.
    await expectLater(
      database.customStatement(
        "DELETE FROM ministering_brothers WHERE id = 'brother-1'",
      ),
      throwsA(anything),
    );
  });

  test('apagar entrevista remove seus participantes', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');
    await database.customStatement('''
      INSERT INTO ministering_interviews
        (id, calling_id, companionship_id, completed_at, created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-a', 0, 0)
    ''');
    await database.customStatement('''
      INSERT INTO ministering_interview_participants
        (interview_id, brother_id, calling_id, companionship_id)
      VALUES ('interview-1', 'brother-1', 'calling-a', 'companionship-a')
    ''');

    await database.customStatement(
      "DELETE FROM ministering_interviews WHERE id = 'interview-1'",
    );

    expect(await countRows('ministering_interview_participants'), 0);
  });

  test('desativar dupla preserva entrevistas e integrantes', () async {
    await openMigratedDatabase();

    await seedBrother('brother-1', 'calling-a');
    await seedCompanionship('companionship-a', 'calling-a');
    await seedMember('companionship-a', 'brother-1', 'calling-a');
    await database.customStatement('''
      INSERT INTO ministering_interviews
        (id, calling_id, companionship_id, completed_at, created_at)
      VALUES ('interview-1', 'calling-a', 'companionship-a', 0, 0)
    ''');

    await database.customStatement(
      "UPDATE ministering_companionships SET is_active = 0 "
      "WHERE id = 'companionship-a'",
    );

    expect(await countRows('ministering_interviews'), 1);
    expect(await countRows('ministering_companionship_members'), 1);
  });
}

/// Banco na versão 2, com dados, para servir de ponto de partida da migração.
class _VersionTwoSchema extends QueryExecutorUser {
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
      INSERT INTO workspaces VALUES ('workspace-v2', 'Workspace v2', 'LOCAL', 0)
    ''',
    '''
      INSERT INTO users VALUES ('user-v2', 'Administrador v2', NULL, 0)
    ''',
    '''
      INSERT INTO memberships VALUES ('workspace-v2', 'user-v2', 'ADMIN', 0)
    ''',
    '''
      INSERT INTO callings VALUES (
        'calling-a', 'workspace-v2', 'user-v2',
        'Secretário da Ministração', 'ministering-secretary', 'ACTIVE', 0, NULL
      )
    ''',
    '''
      INSERT INTO callings VALUES (
        'calling-b', 'workspace-v2', 'user-v2',
        'Outro chamado', 'ministering-secretary', 'ACTIVE', 0, NULL
      )
    ''',
    '''
      INSERT INTO app_preferences VALUES ('theme', 'DARK', 0)
    ''',
  ];

  @override
  int get schemaVersion => 2;

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
