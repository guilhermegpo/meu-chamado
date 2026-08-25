import 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

enum WorkspacePermission {
  createUser,
  assignRole,
  updateOwnUser,
  updateAnyUser,
  deleteUser,
  createOwnCalling,
  createAnyCalling,
  archiveOwnCalling,
  archiveAnyCalling,
}

abstract final class WorkspaceRolePolicy {
  static const Map<UserRole, Set<WorkspacePermission>> _permissions = {
    UserRole.admin: {...WorkspacePermission.values},
    UserRole.moderator: {
      WorkspacePermission.createUser,
      WorkspacePermission.updateOwnUser,
      WorkspacePermission.updateAnyUser,
      WorkspacePermission.createOwnCalling,
      WorkspacePermission.createAnyCalling,
      WorkspacePermission.archiveOwnCalling,
      WorkspacePermission.archiveAnyCalling,
    },
    UserRole.user: {
      WorkspacePermission.updateOwnUser,
      WorkspacePermission.createOwnCalling,
      WorkspacePermission.archiveOwnCalling,
    },
  };

  static bool allows(UserRole role, WorkspacePermission permission) =>
      _permissions[role]?.contains(permission) ?? false;
}

class WorkspaceAuthorizationService {
  const WorkspaceAuthorizationService();

  void require(UserRole role, WorkspacePermission permission) {
    if (!WorkspaceRolePolicy.allows(role, permission)) {
      throw const WorkspaceAuthorizationException();
    }
  }
}
