import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/profile/presentation/user_editor_dialog.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

/// Abre o editor do próprio perfil e persiste o resultado.
///
/// Vive fora das telas porque a ação é a mesma vinda da Home ou da aba Perfil,
/// e a parte delicada — apagar a foto certa quando a gravação falha — não
/// deveria existir em duas cópias que podem divergir.
///
/// Devolve `true` quando algo foi gravado, para quem chamou recarregar.
Future<bool> editOwnProfile({
  required BuildContext context,
  required WidgetRef ref,
  required UserProfile user,
  required String workspaceId,
}) async {
  final result = await showDialog<UserEditorResult>(
    context: context,
    builder: (_) => UserEditorDialog(user: user, roleEditable: false),
  );
  if (result == null || !context.mounted) return false;

  final previousPhotoPath = user.photoPath;
  final changedPhoto =
      result.removePhoto || result.photoPath != previousPhotoPath;

  try {
    await ref
        .read(workspaceRepositoryProvider)
        .updateUser(
          actorId: user.id,
          workspaceId: workspaceId,
          targetUserId: user.id,
          name: result.name,
          photoPath: result.photoPath,
          removePhoto: result.removePhoto,
        );
    if (changedPhoto) {
      // A foto antiga só sai depois de a nova estar gravada: o contrário
      // deixaria o perfil apontando para um arquivo que não existe mais.
      await ref
          .read(profilePhotoServiceProvider)
          .deleteIfManaged(previousPhotoPath);
    }
    return true;
  } catch (error) {
    if (changedPhoto) {
      // A gravação falhou, então a foto recém-escolhida ficou órfã.
      await ref
          .read(profilePhotoServiceProvider)
          .deleteIfManaged(result.photoPath);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
    }
    return false;
  }
}
