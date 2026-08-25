enum WorkspaceType {
  local('LOCAL'),
  shared('SHARED');

  const WorkspaceType(this.storageValue);
  final String storageValue;
}

enum UserRole {
  admin('ADMIN'),
  moderator('MODERATOR'),
  user('USER');

  const UserRole(this.storageValue);
  final String storageValue;
}

enum CallingStatus {
  active('ACTIVE'),
  archived('ARCHIVED');

  const CallingStatus(this.storageValue);
  final String storageValue;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.photoPath,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? photoPath;
}

class CallingSummary {
  const CallingSummary({
    required this.id,
    required this.title,
    required this.moduleKey,
    required this.status,
  });

  final String id;
  final String title;
  final String moduleKey;
  final CallingStatus status;
}

class WorkspaceDashboard {
  const WorkspaceDashboard({
    required this.id,
    required this.name,
    required this.type,
    required this.users,
    required this.callings,
  });

  final String id;
  final String name;
  final WorkspaceType type;
  final List<UserProfile> users;
  final List<CallingSummary> callings;
}
