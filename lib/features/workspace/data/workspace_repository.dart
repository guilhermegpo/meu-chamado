import 'package:drift/drift.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

export 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._database);

  static const _themePreferenceKey = 'theme_preference';

  final AppDatabase _database;
  final WorkspaceAuthorizationService _authorization =
      const WorkspaceAuthorizationService();
  int _lastIdentifier = 0;

  Future<WorkspaceDashboard?> loadDashboard({String? workspaceId}) async {
    final workspaceQuery = _database.select(_database.workspaces)
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    if (workspaceId != null) {
      workspaceQuery.where((row) => row.id.equals(workspaceId));
    } else {
      workspaceQuery.limit(1);
    }

    final workspace = await workspaceQuery.getSingleOrNull();
    if (workspace == null) return null;

    final memberships =
        await (_database.select(_database.memberships)
              ..where((row) => row.workspaceId.equals(workspace.id))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
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

    final callingRows =
        await (_database.select(_database.callings)
              ..where((row) => row.workspaceId.equals(workspace.id))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();

    return WorkspaceDashboard(
      id: workspace.id,
      name: workspace.name,
      type: workspace.type == WorkspaceType.shared.storageValue
          ? WorkspaceType.shared
          : WorkspaceType.local,
      users: List.unmodifiable(profiles),
      callings: List.unmodifiable(callingRows.map(_callingFromRow)),
    );
  }

  Future<WorkspaceDashboard> createLocalWorkspace({
    required String workspaceName,
    required String administratorName,
    String? administratorPhotoPath,
  }) async {
    final safeWorkspaceName = _validatedName(
      workspaceName,
      fieldLabel: 'Workspace',
    );
    final safeAdministratorName = _validatedName(
      administratorName,
      fieldLabel: 'primeiro usuário',
    );

    if (await loadDashboard() != null) {
      throw const WorkspaceValidationException(
        'Este dispositivo já possui um Workspace configurado.',
      );
    }

    final now = DateTime.now().toUtc();
    final suffix = _nextIdentifier();
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
              photoPath: Value(_normalizePhotoPath(administratorPhotoPath)),
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

    return (await loadDashboard(workspaceId: workspaceId))!;
  }

  Future<UserProfile> createUser({
    required String actorId,
    required String workspaceId,
    required String name,
    UserRole role = UserRole.user,
    String? photoPath,
  }) async {
    final safeName = _validatedName(name, fieldLabel: 'usuário');
    final now = DateTime.now().toUtc();
    final userId = 'user-${_nextIdentifier()}';

    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      _authorization.require(
        _roleFromStorage(actor.role),
        WorkspacePermission.createUser,
      );
      if (role != UserRole.user) {
        _authorization.require(
          _roleFromStorage(actor.role),
          WorkspacePermission.assignRole,
        );
      }

      await _database
          .into(_database.users)
          .insert(
            UsersCompanion.insert(
              id: userId,
              name: safeName,
              photoPath: Value(_normalizePhotoPath(photoPath)),
              createdAt: now,
            ),
          );
      await _database
          .into(_database.memberships)
          .insert(
            MembershipsCompanion.insert(
              workspaceId: workspaceId,
              userId: userId,
              role: role.storageValue,
              createdAt: now,
            ),
          );
    });

    return UserProfile(
      id: userId,
      name: safeName,
      role: role,
      photoPath: _normalizePhotoPath(photoPath),
    );
  }

  Future<void> updateUser({
    required String actorId,
    required String workspaceId,
    required String targetUserId,
    String? name,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    if (name == null && photoPath == null && !removePhoto) {
      throw const WorkspaceValidationException(
        'Informe ao menos uma alteração para o usuário.',
      );
    }
    if (photoPath != null && removePhoto) {
      throw const WorkspaceValidationException(
        'Escolha uma nova foto ou remova a atual.',
      );
    }

    final safeName = name == null
        ? null
        : _validatedName(name, fieldLabel: 'usuário');
    final safePhotoPath = photoPath == null
        ? null
        : _validatedPhotoPath(photoPath);

    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      await _loadTargetMembership(workspaceId, targetUserId);
      final permission = actorId == targetUserId
          ? WorkspacePermission.updateOwnUser
          : WorkspacePermission.updateAnyUser;
      _authorization.require(_roleFromStorage(actor.role), permission);

      await (_database.update(
        _database.users,
      )..where((row) => row.id.equals(targetUserId))).write(
        UsersCompanion(
          name: safeName == null ? const Value.absent() : Value(safeName),
          photoPath: removePhoto
              ? const Value(null)
              : safePhotoPath == null
              ? const Value.absent()
              : Value(safePhotoPath),
        ),
      );
    });
  }

  Future<void> deleteUser({
    required String actorId,
    required String workspaceId,
    required String targetUserId,
  }) async {
    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      _authorization.require(
        _roleFromStorage(actor.role),
        WorkspacePermission.deleteUser,
      );
      final target = await _loadTargetMembership(workspaceId, targetUserId);
      await _ensureAdministratorRemains(workspaceId, target);

      await (_database.delete(_database.memberships)..where(
            (row) =>
                row.workspaceId.equals(workspaceId) &
                row.userId.equals(targetUserId),
          ))
          .go();

      final remainingMembership = await (_database.select(
        _database.memberships,
      )..where((row) => row.userId.equals(targetUserId))).getSingleOrNull();
      if (remainingMembership == null) {
        await (_database.delete(
          _database.users,
        )..where((row) => row.id.equals(targetUserId))).go();
      }
    });
  }

  Future<void> changeRole({
    required String actorId,
    required String workspaceId,
    required String userId,
    required UserRole newRole,
  }) async {
    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      _authorization.require(
        _roleFromStorage(actor.role),
        WorkspacePermission.assignRole,
      );
      final membership = await _loadTargetMembership(workspaceId, userId);
      if (membership.role == newRole.storageValue) return;

      await _ensureAdministratorRemains(workspaceId, membership);

      await (_database.update(_database.memberships)..where(
            (row) =>
                row.workspaceId.equals(workspaceId) & row.userId.equals(userId),
          ))
          .write(MembershipsCompanion(role: Value(newRole.storageValue)));
    });
  }

  Future<CallingSummary> createCalling({
    required String actorId,
    required String workspaceId,
    required String userId,
    required String title,
    required String moduleKey,
  }) async {
    final safeTitle = _validatedCallingTitle(title);
    final safeModuleKey = _validatedModuleKey(moduleKey);
    final now = DateTime.now().toUtc();
    final callingId = 'calling-${_nextIdentifier()}';

    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      await _loadTargetMembership(workspaceId, userId);
      final permission = actorId == userId
          ? WorkspacePermission.createOwnCalling
          : WorkspacePermission.createAnyCalling;
      _authorization.require(_roleFromStorage(actor.role), permission);

      await _database
          .into(_database.callings)
          .insert(
            CallingsCompanion.insert(
              id: callingId,
              workspaceId: workspaceId,
              userId: userId,
              title: safeTitle,
              moduleKey: safeModuleKey,
              status: CallingStatus.active.storageValue,
              createdAt: now,
            ),
          );
    });

    return CallingSummary(
      id: callingId,
      userId: userId,
      title: safeTitle,
      moduleKey: safeModuleKey,
      status: CallingStatus.active,
    );
  }

  Future<void> archiveCalling({
    required String actorId,
    required String workspaceId,
    required String callingId,
  }) async {
    await _setCallingArchived(
      actorId: actorId,
      workspaceId: workspaceId,
      callingId: callingId,
      archived: true,
    );
  }

  Future<void> restoreCalling({
    required String actorId,
    required String workspaceId,
    required String callingId,
  }) async {
    await _setCallingArchived(
      actorId: actorId,
      workspaceId: workspaceId,
      callingId: callingId,
      archived: false,
    );
  }

  Future<ThemePreference> loadThemePreference() async {
    final preference = await (_database.select(
      _database.appPreferences,
    )..where((row) => row.key.equals(_themePreferenceKey))).getSingleOrNull();
    if (preference == null) return ThemePreference.system;

    return ThemePreference.values.firstWhere(
      (value) => value.storageValue == preference.value,
      orElse: () => ThemePreference.system,
    );
  }

  Future<void> saveThemePreference(ThemePreference preference) async {
    await _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            key: _themePreferenceKey,
            value: preference.storageValue,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> _setCallingArchived({
    required String actorId,
    required String workspaceId,
    required String callingId,
    required bool archived,
  }) async {
    await _database.transaction(() async {
      final actor = await _loadActorMembership(workspaceId, actorId);
      final calling =
          await (_database.select(_database.callings)..where(
                (row) =>
                    row.workspaceId.equals(workspaceId) &
                    row.id.equals(callingId),
              ))
              .getSingleOrNull();
      if (calling == null) {
        throw const WorkspaceValidationException('Chamado não encontrado.');
      }

      final permission = actorId == calling.userId
          ? WorkspacePermission.archiveOwnCalling
          : WorkspacePermission.archiveAnyCalling;
      _authorization.require(_roleFromStorage(actor.role), permission);

      await (_database.update(
        _database.callings,
      )..where((row) => row.id.equals(callingId))).write(
        CallingsCompanion(
          status: Value(
            archived
                ? CallingStatus.archived.storageValue
                : CallingStatus.active.storageValue,
          ),
          archivedAt: Value(archived ? DateTime.now().toUtc() : null),
        ),
      );
    });
  }

  Future<MembershipRow> _loadActorMembership(
    String workspaceId,
    String actorId,
  ) async {
    final membership = await _findMembership(workspaceId, actorId);
    if (membership == null) {
      throw const WorkspaceAuthorizationException();
    }
    return membership;
  }

  Future<MembershipRow> _loadTargetMembership(
    String workspaceId,
    String userId,
  ) async {
    final membership = await _findMembership(workspaceId, userId);
    if (membership == null) {
      throw const WorkspaceValidationException(
        'Usuário não encontrado neste Workspace.',
      );
    }
    return membership;
  }

  Future<MembershipRow?> _findMembership(String workspaceId, String userId) =>
      (_database.select(_database.memberships)..where(
            (row) =>
                row.workspaceId.equals(workspaceId) & row.userId.equals(userId),
          ))
          .getSingleOrNull();

  Future<void> _ensureAdministratorRemains(
    String workspaceId,
    MembershipRow target,
  ) async {
    if (target.role != UserRole.admin.storageValue) return;

    final administrators =
        await (_database.select(_database.memberships)..where(
              (row) =>
                  row.workspaceId.equals(workspaceId) &
                  row.role.equals(UserRole.admin.storageValue),
            ))
            .get();
    if (administrators.length <= 1) {
      throw const LastAdministratorException();
    }
  }

  CallingSummary _callingFromRow(CallingRow calling) => CallingSummary(
    id: calling.id,
    userId: calling.userId,
    title: calling.title,
    moduleKey: calling.moduleKey,
    status: calling.status == CallingStatus.archived.storageValue
        ? CallingStatus.archived
        : CallingStatus.active,
    archivedAt: calling.archivedAt,
  );

  UserRole _roleFromStorage(String value) => UserRole.values.firstWhere(
    (role) => role.storageValue == value,
    orElse: () => UserRole.user,
  );

  String _validatedName(String value, {required String fieldLabel}) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw WorkspaceValidationException('Informe o nome do $fieldLabel.');
    }
    if (normalized.length > 80) {
      throw WorkspaceValidationException(
        'O nome do $fieldLabel deve ter no máximo 80 caracteres.',
      );
    }
    return normalized;
  }

  String _validatedCallingTitle(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw const WorkspaceValidationException('Informe o nome do chamado.');
    }
    if (normalized.length > 120) {
      throw const WorkspaceValidationException(
        'O nome do chamado deve ter no máximo 120 caracteres.',
      );
    }
    return normalized;
  }

  String _validatedModuleKey(String value) {
    final normalized = value.trim().toLowerCase();
    final validKey = RegExp(r'^[a-z0-9]+(?:[-_.][a-z0-9]+)*$');
    if (normalized.isEmpty ||
        normalized.length > 64 ||
        !validKey.hasMatch(normalized)) {
      throw const WorkspaceValidationException(
        'O identificador do módulo é inválido.',
      );
    }
    return normalized;
  }

  String? _normalizePhotoPath(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _validatedPhotoPath(String value) {
    final normalized = _normalizePhotoPath(value);
    if (normalized == null) {
      throw const WorkspaceValidationException(
        'O arquivo selecionado para a foto é inválido.',
      );
    }
    return normalized;
  }

  String _nextIdentifier() {
    final current = DateTime.now().toUtc().microsecondsSinceEpoch;
    _lastIdentifier = current > _lastIdentifier ? current : _lastIdentifier + 1;
    return _lastIdentifier.toString();
  }
}
