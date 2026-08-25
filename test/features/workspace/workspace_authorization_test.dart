import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

void main() {
  const authorization = WorkspaceAuthorizationService();

  test('ADMIN possui todas as permissões', () {
    for (final permission in WorkspacePermission.values) {
      expect(WorkspaceRolePolicy.allows(UserRole.admin, permission), isTrue);
      expect(
        () => authorization.require(UserRole.admin, permission),
        returnsNormally,
      );
    }
  });

  test('MODERATOR não altera papéis nem exclui usuários', () {
    expect(
      WorkspaceRolePolicy.allows(
        UserRole.moderator,
        WorkspacePermission.createUser,
      ),
      isTrue,
    );
    expect(
      () => authorization.require(
        UserRole.moderator,
        WorkspacePermission.assignRole,
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
    expect(
      () => authorization.require(
        UserRole.moderator,
        WorkspacePermission.deleteUser,
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
  });

  test('USER administra apenas o próprio perfil e os próprios chamados', () {
    expect(
      WorkspaceRolePolicy.allows(
        UserRole.user,
        WorkspacePermission.updateOwnUser,
      ),
      isTrue,
    );
    expect(
      WorkspaceRolePolicy.allows(
        UserRole.user,
        WorkspacePermission.createOwnCalling,
      ),
      isTrue,
    );
    expect(
      () => authorization.require(
        UserRole.user,
        WorkspacePermission.updateAnyUser,
      ),
      throwsA(isA<WorkspaceAuthorizationException>()),
    );
  });
}
