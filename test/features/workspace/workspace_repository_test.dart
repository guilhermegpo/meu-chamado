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

  test('cria Workspace local com o primeiro usuário como ADMIN', () async {
    final dashboard = await repository.createLocalWorkspace(
      workspaceName: 'Workspace Demo',
      administratorName: 'Administrador Demo',
    );

    expect(dashboard.type, WorkspaceType.local);
    expect(dashboard.users, hasLength(1));
    expect(dashboard.users.single.name, 'Administrador Demo');
    expect(dashboard.users.single.role, UserRole.admin);
    expect(dashboard.callings, isEmpty);
  });

  test('impede remover o último ADMIN do Workspace', () async {
    final dashboard = await repository.createLocalWorkspace(
      workspaceName: 'Workspace Demo',
      administratorName: 'Administrador Demo',
    );

    expect(
      () => repository.changeRole(
        workspaceId: dashboard.id,
        userId: dashboard.users.single.id,
        newRole: UserRole.user,
      ),
      throwsA(isA<LastAdministratorException>()),
    );

    final unchanged = await repository.loadDashboard();
    expect(unchanged!.users.single.role, UserRole.admin);
  });

  test('aceita mais de um chamado para o mesmo usuário', () async {
    final dashboard = await repository.createLocalWorkspace(
      workspaceName: 'Workspace Demo',
      administratorName: 'Administrador Demo',
    );
    final userId = dashboard.users.single.id;

    await repository.createCalling(
      workspaceId: dashboard.id,
      userId: userId,
      title: 'Chamado Demo A',
      moduleKey: 'demo-a',
    );
    await repository.createCalling(
      workspaceId: dashboard.id,
      userId: userId,
      title: 'Chamado Demo B',
      moduleKey: 'demo-b',
    );

    final updated = await repository.loadDashboard();
    expect(updated!.callings, hasLength(2));
    expect(
      updated.callings.map((calling) => calling.title),
      containsAll(['Chamado Demo A', 'Chamado Demo B']),
    );
  });

  test('rejeita nomes vazios no onboarding', () async {
    expect(
      () => repository.createLocalWorkspace(
        workspaceName: '   ',
        administratorName: 'Administrador Demo',
      ),
      throwsA(isA<WorkspaceValidationException>()),
    );
    expect(await repository.loadDashboard(), isNull);
  });
}
