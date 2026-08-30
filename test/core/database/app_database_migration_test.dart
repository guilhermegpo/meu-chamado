import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

void main() {
  test(
    'migra schema v1 para v2 preservando dados e adicionando garantias',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'meu-chamado-migration-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );

      final legacy = NativeDatabase(file);
      await legacy.ensureOpen(_VersionOneSchema());
      await legacy.close();

      final database = AppDatabase(NativeDatabase(file));
      final repository = WorkspaceRepository(database);
      try {
        final dashboard = await repository.loadDashboard();
        expect(database.schemaVersion, 4);
        expect(dashboard, isNotNull);
        expect(dashboard!.users.single.name, 'Administrador v1');
        expect(dashboard.callings.single.title, 'Chamado v1');
        expect(dashboard.callings.single.userId, 'user-v1');
        expect(await repository.loadThemePreference(), ThemePreference.system);

        await repository.saveThemePreference(ThemePreference.dark);
        expect(await repository.loadThemePreference(), ThemePreference.dark);

        final foreignKeys = await database
            .customSelect('PRAGMA foreign_keys')
            .getSingle();
        expect(foreignKeys.data.values.single, 1);
        final integrity = await database
            .customSelect('PRAGMA foreign_key_check')
            .get();
        expect(integrity, isEmpty);

        const now = 1;
        await database.customStatement('''
        INSERT INTO workspaces (id, name, type, created_at)
        VALUES ('workspace-v2', 'Workspace v2', 'LOCAL', $now)
        ''');
        await database.customStatement('''
        INSERT INTO users (id, name, photo_path, created_at)
        VALUES ('user-v2', 'Usuário v2', NULL, $now)
        ''');
        await database.customStatement('''
        INSERT INTO memberships (workspace_id, user_id, role, created_at)
        VALUES ('workspace-v2', 'user-v2', 'ADMIN', $now)
        ''');
        await expectLater(
          database.customStatement('''
          INSERT INTO callings (
            id, workspace_id, user_id, title, module_key, status, created_at
          ) VALUES (
            'calling-invalid', 'workspace-v1', 'user-v2',
            'Chamado inválido', 'invalid-membership', 'ACTIVE', $now
          )
        '''),
          throwsA(anything),
        );
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );
}

class _VersionOneSchema extends QueryExecutorUser {
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
          archived_at INTEGER NULL
        )
    ''',
    '''
        INSERT INTO workspaces VALUES (
          'workspace-v1', 'Workspace v1', 'LOCAL', 0
        )
    ''',
    '''
        INSERT INTO users VALUES (
          'user-v1', 'Administrador v1', NULL, 0
        )
    ''',
    '''
        INSERT INTO memberships VALUES (
          'workspace-v1', 'user-v1', 'ADMIN', 0
        )
    ''',
    '''
        INSERT INTO callings VALUES (
          'calling-v1', 'workspace-v1', 'user-v1',
          'Chamado v1', 'legacy-module', 'ACTIVE', 0, NULL
        )
    ''',
  ];

  @override
  int get schemaVersion => 1;

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
