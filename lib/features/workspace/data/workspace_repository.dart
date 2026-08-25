import 'package:drift/drift.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._database);

  final AppDatabase _database;

  Future<WorkspaceDashboard?> loadDashboard() async {
    final workspace = await (_database.select(
      _database.workspaces,
    )..limit(1)).getSingleOrNull();
    if (workspace == null) return null;

    final memberships = await (_database.select(
      _database.memberships,
    )..where((row) => row.workspaceId.equals(workspace.id))).get();
    final profiles = <UserProfile>[];

    for (final membership in memberships) {
      final user = await (_database.select(
        _database.users,
      )..where((row) => row.id.equals(membership.userId))).getSingle();
      profiles.add(
        UserProfile(
          id: user.id,
          name: user.name,
          role: _roleFromStorage(membership.role),
          photoPath: user.photoPath,
        ),
      );
    }

    final callingRows = await (_database.select(
      _database.callings,
    )..where((row) => row.workspaceId.equals(workspace.id))).get();

    return WorkspaceDashboard(
      id: workspace.id,
      name: workspace.name,
      type: workspace.type == WorkspaceType.shared.storageValue
          ? WorkspaceType.shared
          : WorkspaceType.local,
      users: List.unmodifiable(profiles),
      callings: List.unmodifiable(
        callingRows.map(
          (calling) => CallingSummary(
            id: calling.id,
            title: calling.title,
            moduleKey: calling.moduleKey,
            status: calling.status == CallingStatus.archived.storageValue
                ? CallingStatus.archived
                : CallingStatus.active,
          ),
        ),
      ),
    );
  }

  Future<WorkspaceDashboard> createLocalWorkspace({
    required String workspaceName,
    required String administratorName,
  }) async {
    final safeWorkspaceName = workspaceName.trim();
    final safeAdministratorName = administratorName.trim();
    if (safeWorkspaceName.isEmpty || safeAdministratorName.isEmpty) {
      throw const WorkspaceValidationException(
        'Informe o nome do Workspace e do primeiro usuário.',
      );
    }

    if (await loadDashboard() != null) {
      throw const WorkspaceValidationException(
        'Este dispositivo já possui um Workspace configurado.',
      );
    }

    final now = DateTime.now().toUtc();
    final suffix = now.microsecondsSinceEpoch.toString();
    final workspaceId = 'workspace-$suffix';
    final administratorId = 'user-$suffix';

    await _database.transaction(() async {
      await _database
          .into(_database.workspaces)
          .insert(
            WorkspacesCompanion.insert(
              id: workspaceId,
              name: safeWorkspaceName,
              type: WorkspaceType.local.storageValue,
              createdAt: now,
            ),
          );
      await _database
          .into(_database.users)
          .insert(
            UsersCompanion.insert(
              id: administratorId,
              name: safeAdministratorName,
              createdAt: now,
            ),
          );
      await _database
          .into(_database.memberships)
          .insert(
            MembershipsCompanion.insert(
              workspaceId: workspaceId,
              userId: administratorId,
              role: UserRole.admin.storageValue,
              createdAt: now,
            ),
          );
    });

    return (await loadDashboard())!;
  }

  Future<void> changeRole({
    required String workspaceId,
    required String userId,
    required UserRole newRole,
  }) async {
    await _database.transaction(() async {
      final membership =
          await (_database.select(_database.memberships)..where(
                (row) =>
                    row.workspaceId.equals(workspaceId) &
                    row.userId.equals(userId),
              ))
              .getSingleOrNull();
      if (membership == null) {
        throw const WorkspaceValidationException('Usuário não encontrado.');
      }

      final removesAdministrator =
          membership.role == UserRole.admin.storageValue &&
          newRole != UserRole.admin;
      if (removesAdministrator) {
        final administrators =
            await (_database.select(_database.memberships)..where(
                  (row) =>
                      row.workspaceId.equals(workspaceId) &
                      row.role.equals(UserRole.admin.storageValue),
                ))
                .get();
        if (administrators.length == 1) {
          throw const LastAdministratorException();
        }
      }

      await (_database.update(_database.memberships)..where(
            (row) =>
                row.workspaceId.equals(workspaceId) & row.userId.equals(userId),
          ))
          .write(MembershipsCompanion(role: Value(newRole.storageValue)));
    });
  }

  Future<void> createCalling({
    required String workspaceId,
    required String userId,
    required String title,
    required String moduleKey,
  }) async {
    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      throw const WorkspaceValidationException('Informe o nome do chamado.');
    }

    final now = DateTime.now().toUtc();
    await _database
        .into(_database.callings)
        .insert(
          CallingsCompanion.insert(
            id: 'calling-${now.microsecondsSinceEpoch}',
            workspaceId: workspaceId,
            userId: userId,
            title: safeTitle,
            moduleKey: moduleKey,
            status: CallingStatus.active.storageValue,
            createdAt: now,
          ),
        );
  }

  UserRole _roleFromStorage(String value) => UserRole.values.firstWhere(
    (role) => role.storageValue == value,
    orElse: () => UserRole.user,
  );
}

class WorkspaceValidationException implements Exception {
  const WorkspaceValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LastAdministratorException extends WorkspaceValidationException {
  const LastAdministratorException()
    : super('Todo Workspace precisa manter ao menos um administrador.');
}
