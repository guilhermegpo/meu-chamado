sealed class WorkspaceException implements Exception {
  const WorkspaceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkspaceValidationException extends WorkspaceException {
  const WorkspaceValidationException(super.message);
}

class WorkspaceAuthorizationException extends WorkspaceException {
  const WorkspaceAuthorizationException()
    : super('Você não tem permissão para realizar esta ação.');
}

class LastAdministratorException extends WorkspaceValidationException {
  const LastAdministratorException()
    : super('Todo Workspace precisa manter ao menos um administrador.');
}
