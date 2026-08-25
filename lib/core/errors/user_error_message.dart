import 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';

String userErrorMessage(
  Object error, {
  String fallback = 'Não foi possível concluir esta ação.',
}) {
  if (error is WorkspaceException) return error.message;
  return fallback;
}
