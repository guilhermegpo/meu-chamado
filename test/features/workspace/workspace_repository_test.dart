import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

void main() {
  late AppDatabase database;
  late WorkspaceRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = WorkspaceRepository(database);
  });

  tearDown(() => database.close());

  Future<WorkspaceDashboard> createWorkspace() =>
      repository.createLocalWorkspace(
        workspaceName: 'Workspace Demo',
        administratorName: 'Administrador Demo',
        administratorPhotoPath: 'profiles/admin-demo.jpg',
      );

  test('cria Workspace LOCAL com o primeiro usuário como ADMIN', () async {
    final dashboard = await createWorkspace();

    expect(dashboard.type, WorkspaceType.local);
    expect(dashboard.users, hasLength(1));
    expect(dashboard.users.single.name, 'Administrador Demo');
    expect(dashboard.users.single.role, UserRole.admin);
    expect(dashboard.users.single.photoPath, 'profiles/admin-demo.jpg');
    expect(dashboard.callings, isEmpty);
  });

  test('persiste preferência de tema e usa SYSTEM como padrão', () async {
    expect(await repository.loadThemePreference(), ThemePreference.system);

    await repository.saveThemePreference(ThemePreference.dark);
    expect(await repository.loadThemePreference(), ThemePreference.dark);

    await repository.saveThemePreference(ThemePreference.light);
    expect(await repository.loadThemePreference(), ThemePreference.light);
    expect(await database.select(database.appPreferences).get(), hasLength(1));
  });

  test('impede rebaixar ou excluir o último ADMIN', () async {
    final dashboard = await createWorkspace();
    final administratorId = dashboard.users.single.id;

    await expectLater(
      repository.changeRole(
        actorId: administratorId,
        workspaceId: dashboard.id,
        userId: administratorId,
        newRole: UserRole.user,
      ),
      throwsA(isA<LastAdministratorException>()),
    );
    await expectLater(
      repository.deleteUser(
        actorId: administratorId,
        workspaceId: dashboard.id,
        targetUserId: administratorId,
      ),
      throwsA(isA<LastAdministratorException>()),
    );

    final unchanged = await repository.loadDashboard();
    expect(unchanged!.users.single.role, UserRole.admin);
  });

  test('permite rebaixar ADMIN quando outro administrador permanece', () async {
    final dashboard = await createWorkspace();
    final firstAdministratorId = dashboard.users.single.id;
    final secondAdministrator = await repository.createUser(
      actorId: firstAdministratorId,
      workspaceId: dashboard.id,
      name: 'Segundo Administrador',
      role: UserRole.admin,
    );

    await repository.changeRole(
      actorId: firstAdministratorId,
      workspaceId: dashboard.id,
      userId: secondAdministrator.id,
      newRole: UserRole.user,
    );

    final updated = await repository.loadDashboard();
    expect(
      updated!.users
          .singleWhere((user) => user.id == secondAdministrator.id)
          .role,
      UserRole.user,
    );
  });

  test('suporta 0, 1 e N chamados com vínculo explícito ao usuário', () async {
    final dashboard = await createWorkspace();
    final administratorId = dashboard.users.single.id;
    final user = await repository.createUser(
      actorId: administratorId,
      workspaceId: dashboard.id,
      name: 'Usuário Demo',
    );
    expect(dashboard.callings, isEmpty);

    await repository.createCalling(
      actorId: administratorId,
      workspaceId: dashboard.id,
      userId: user.id,
      title: 'Secretário de Ministração',
      moduleKey: 'ministering-secretary',
    );
    var updated = await repository.loadDashboard();
    expect(updated!.callings, hasLength(1));
    expect(updated.callings.single.userId, user.id);

    await repository.createCalling(
      actorId: user.id,
      workspaceId: dashboard.id,
      userId: user.id,
      title: 'Secretário da Escola Dominical',
      moduleKey: 'sunday-school-secretary',
    );
    updated = await repository.loadDashboard();
    expect(updated!.callings, hasLength(2));
    expect(
      updated.callings.every((calling) => calling.userId == user.id),
      isTrue,
    );
  });

  test('arquiva e restaura chamado sem alterar sua chave de módulo', () async {
    final dashboard = await createWorkspace();
    final administratorId = dashboard.users.single.id;
    final calling = await repository.createCalling(
      actorId: administratorId,
      workspaceId: dashboard.id,
      userId: administratorId,
      title: 'Secretário de Ministração',
      moduleKey: 'ministering-secretary',
    );

    await repository.archiveCalling(
      actorId: administratorId,
      workspaceId: dashboard.id,
      callingId: calling.id,
    );
    var stored = (await repository.loadDashboard())!.callings.single;
    expect(stored.status, CallingStatus.archived);
    expect(stored.archivedAt, isNotNull);
    expect(stored.moduleKey, 'ministering-secretary');

    await repository.restoreCalling(
      actorId: administratorId,
      workspaceId: dashboard.id,
      callingId: calling.id,
    );
    stored = (await repository.loadDashboard())!.callings.single;
    expect(stored.status, CallingStatus.active);
    expect(stored.archivedAt, isNull);
  });

  test('aplica as permissões de ADMIN, MODERATOR e USER', () async {
    final dashboard = await createWorkspace();
    final administratorId = dashboard.users.single.id;
    final moderator = await repository.createUser(
      actorId: administratorId,
      workspaceId: dashboard.id,
      name: 'Moderador Demo',
      role: UserRole.moderator,
    );
    final user = await repository.createUser(
      actorId: moderator.id,
      workspaceId: dashboard.id,
      name: 'Usuário Demo',
    );

    await repository.updateUser(
      actorId: moderator.id,
      workspaceId: dashboard.id,
      targetUserId: user.id,
      name: 'Usuário Atualizado',
    );
    await repository.updateUser(
      actorId: user.id,
      workspaceId: dashboard.id,
      targetUserId: user.id,
      photoPath: 'profiles/user-demo.jpg',
    );

    await expectLater(
      repository.changeRole(
        actorId: moderator.id,
        workspaceId: dashboard.id,
        userId: user.id,
        newRole: UserRole.moderator,
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
    await expectLater(
      repository.deleteUser(
        actorId: moderator.id,
        workspaceId: dashboard.id,
        targetUserId: user.id,
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
    await expectLater(
      repository.updateUser(
        actorId: user.id,
        workspaceId: dashboard.id,
        targetUserId: moderator.id,
        name: 'Alteração não autorizada',
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
    await expectLater(
      repository.createCalling(
        actorId: user.id,
        workspaceId: dashboard.id,
        userId: moderator.id,
        title: 'Chamado indevido',
        moduleKey: 'unauthorized-calling',
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );

    final updated = await repository.loadDashboard();
    final storedUser = updated!.users.singleWhere((item) => item.id == user.id);
    expect(storedUser.name, 'Usuário Atualizado');
    expect(storedUser.photoPath, 'profiles/user-demo.jpg');
  });

  test('rejeita ator que não pertence ao Workspace', () async {
    final dashboard = await createWorkspace();

    await expectLater(
      repository.createUser(
        actorId: 'user-externo',
        workspaceId: dashboard.id,
        name: 'Usuário Demo',
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
  });

  test(
    'ativa FKs e impede chamado sem membership no mesmo Workspace',
    () async {
      final first = await createWorkspace();
      final now = DateTime.utc(2026, 1, 1);

      await database
          .into(database.workspaces)
          .insert(
            WorkspacesCompanion.insert(
              id: 'workspace-secundario',
              name: 'Workspace Secundário',
              type: WorkspaceType.local.storageValue,
              createdAt: now,
            ),
          );
      await database
          .into(database.users)
          .insert(
            UsersCompanion.insert(
              id: 'user-secundario',
              name: 'Usuário Secundário',
              createdAt: now,
            ),
          );
      await database
          .into(database.memberships)
          .insert(
            MembershipsCompanion.insert(
              workspaceId: 'workspace-secundario',
              userId: 'user-secundario',
              role: UserRole.admin.storageValue,
              createdAt: now,
            ),
          );

      final pragma = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(pragma.data.values.single, 1);
      await expectLater(
        database
            .into(database.callings)
            .insert(
              CallingsCompanion.insert(
                id: 'calling-invalido',
                workspaceId: first.id,
                userId: 'user-secundario',
                title: 'Chamado inválido',
                moduleKey: 'invalid-membership',
                status: CallingStatus.active.storageValue,
                createdAt: now,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('excluir usuário remove seus chamados por cascata', () async {
    final dashboard = await createWorkspace();
    final administratorId = dashboard.users.single.id;
    final user = await repository.createUser(
      actorId: administratorId,
      workspaceId: dashboard.id,
      name: 'Usuário Temporário',
    );
    await repository.createCalling(
      actorId: administratorId,
      workspaceId: dashboard.id,
      userId: user.id,
      title: 'Chamado temporário',
      moduleKey: 'temporary-calling',
    );

    await repository.deleteUser(
      actorId: administratorId,
      workspaceId: dashboard.id,
      targetUserId: user.id,
    );

    final updated = await repository.loadDashboard();
    expect(updated!.users.where((item) => item.id == user.id), isEmpty);
    expect(updated.callings, isEmpty);
  });

  test('rejeita dados vazios ou identificador de módulo instável', () async {
    await expectLater(
      repository.createLocalWorkspace(
        workspaceName: '   ',
        administratorName: 'Administrador Demo',
      ),
      throwsA(isA<WorkspaceValidationException>()),
    );
    expect(await repository.loadDashboard(), isNull);

    final dashboard = await createWorkspace();
    await expectLater(
      repository.createCalling(
        actorId: dashboard.users.single.id,
        workspaceId: dashboard.id,
        userId: dashboard.users.single.id,
        title: 'Chamado Demo',
        moduleKey: 'Título visível não é chave',
      ),
      throwsA(isA<WorkspaceValidationException>()),
    );
  });
}
