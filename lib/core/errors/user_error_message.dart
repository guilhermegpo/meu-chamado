import 'package:meu_chamado/features/ministering/domain/ministering_exceptions.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_exceptions.dart';

String userErrorMessage(
  Object error, {
  String fallback = 'Não foi possível concluir esta ação.',
}) {
  if (error is WorkspaceException) return error.message;
  if (error is MinisteringException) return error.message;
  return fallback;
}
