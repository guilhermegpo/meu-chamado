import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

void main() {
  test(
    'preserva Workspace, usuário, chamado e tema após reabrir o banco',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'meu-chamado-persistence-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );

      final firstDatabase = AppDatabase(NativeDatabase(file));
      final firstRepository = WorkspaceRepository(firstDatabase);
      final created = await firstRepository.createLocalWorkspace(
        workspaceName: 'Workspace Persistente',
        administratorName: 'Administrador Persistente',
      );
      await firstRepository.createCalling(
        actorId: created.users.single.id,
        workspaceId: created.id,
        userId: created.users.single.id,
        title: 'Secretário de Ministração',
        moduleKey: 'ministering-secretary',
      );
      await firstRepository.saveThemePreference(ThemePreference.dark);
      await firstDatabase.close();

      final reopenedDatabase = AppDatabase(NativeDatabase(file));
      final reopenedRepository = WorkspaceRepository(reopenedDatabase);
      try {
        final reopened = await reopenedRepository.loadDashboard();
        expect(reopened, isNotNull);
        expect(reopened!.name, 'Workspace Persistente');
        expect(reopened.users.single.name, 'Administrador Persistente');
        expect(reopened.users.single.role, UserRole.admin);
        expect(reopened.callings.single.moduleKey, 'ministering-secretary');
        expect(
          await reopenedRepository.loadThemePreference(),
          ThemePreference.dark,
        );
      } finally {
        await reopenedDatabase.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
