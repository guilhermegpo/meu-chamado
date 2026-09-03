import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/profile/presentation/user_editor_dialog.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({
    required this.dashboard,
    required this.actorId,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final String actorId;

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  late WorkspaceDashboard _dashboard;
  bool _busy = false;

  UserProfile get _actor =>
      _dashboard.users.firstWhere((user) => user.id == widget.actorId);

  @override
  void initState() {
    super.initState();
    _dashboard = widget.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = WorkspaceRolePolicy.allows(
      _actor.role,
      WorkspacePermission.createUser,
    );

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Usuários')),
        floatingActionButton: canCreate
            ? FloatingActionButton.extended(
                key: const Key('add-user-button'),
                onPressed: _busy ? null : _createUser,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Novo usuário'),
              )
            : null,
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.xs,
            Spacing.md,
            Spacing.fabClearance,
          ),
          itemCount: _dashboard.users.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return AppSurface(
                gradient: AppGradients.soft(Theme.of(context).brightness),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIconTile(icon: Icons.manage_accounts_outlined),
                    SizedBox(width: Spacing.md),
                    Expanded(
                      child: Text(
                        'Perfis deste Workspace local. A seleção de perfil '
                        'ainda não equivale a autenticação individual.',
                      ),
                    ),
                  ],
                ),
              );
            }
            final user = _dashboard.users[index - 1];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                leading: ProfileAvatar(
                  name: user.name,
                  photoPath: user.photoPath,
                ),
                title: Text(user.name),
                subtitle: Text(_roleLabel(user.role)),
                trailing: _actionsFor(user),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? _actionsFor(UserProfile target) {
    final canUpdate = WorkspaceRolePolicy.allows(
      _actor.role,
      target.id == _actor.id
          ? WorkspacePermission.updateOwnUser
          : WorkspacePermission.updateAnyUser,
    );
    final canAssignRole = WorkspaceRolePolicy.allows(
      _actor.role,
      WorkspacePermission.assignRole,
    );
    final canDelete = WorkspaceRolePolicy.allows(
      _actor.role,
      WorkspacePermission.deleteUser,
    );
    if (!canUpdate && !canAssignRole && !canDelete) return null;

    return PopupMenuButton<_UserAction>(
      tooltip: 'Ações para ${target.name}',
      enabled: !_busy,
      onSelected: (action) => switch (action) {
        _UserAction.edit => _editUser(target),
        _UserAction.role => _changeRole(target),
        _UserAction.delete => _deleteUser(target),
      },
      itemBuilder: (_) => [
        if (canUpdate)
          const PopupMenuItem(
            value: _UserAction.edit,
            child: Text('Editar nome e foto'),
          ),
        if (canAssignRole)
          const PopupMenuItem(
            value: _UserAction.role,
            child: Text('Alterar cargo'),
          ),
        if (canDelete)
          const PopupMenuItem(
            value: _UserAction.delete,
            child: Text('Excluir usuário'),
          ),
      ],
    );
  }

  Future<void> _createUser() async {
    final result = await showDialog<UserEditorResult>(
      context: context,
      builder: (_) =>
          UserEditorDialog(roleEditable: _actor.role == UserRole.admin),
    );
    if (result == null || !mounted) return;

    await _runMutation(
      () => ref
          .read(workspaceRepositoryProvider)
          .createUser(
            actorId: _actor.id,
            workspaceId: _dashboard.id,
            name: result.name,
            role: result.role,
            photoPath: result.photoPath,
          ),
      successMessage: 'Usuário criado.',
      orphanPhotoPath: result.photoPath,
    );
  }

  Future<void> _editUser(UserProfile target) async {
    final result = await showDialog<UserEditorResult>(
      context: context,
      builder: (_) => UserEditorDialog(user: target, roleEditable: false),
    );
    if (result == null || !mounted) return;

    final changedPhoto =
        result.removePhoto || result.photoPath != target.photoPath;
    final succeeded = await _runMutation(
      () => ref
          .read(workspaceRepositoryProvider)
          .updateUser(
            actorId: _actor.id,
            workspaceId: _dashboard.id,
            targetUserId: target.id,
            name: result.name,
            photoPath: result.photoPath,
            removePhoto: result.removePhoto,
          ),
      successMessage: 'Perfil atualizado.',
      orphanPhotoPath: changedPhoto ? result.photoPath : null,
    );
    if (succeeded && changedPhoto) {
      await ref
          .read(profilePhotoServiceProvider)
          .deleteIfManaged(target.photoPath);
    }
  }

  Future<void> _changeRole(UserProfile target) async {
    final role = await showDialog<UserRole>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cargo de ${target.name}'),
        children: [
          for (final value in UserRole.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(value),
              child: Semantics(
                selected: target.role == value,
                child: Row(
                  children: [
                    Icon(
                      target.role == value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    const SizedBox(width: 12),
                    Text(_roleLabel(value)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (role == null || role == target.role || !mounted) return;

    final succeeded = await _runMutation(
      () => ref
          .read(workspaceRepositoryProvider)
          .changeRole(
            actorId: _actor.id,
            workspaceId: _dashboard.id,
            userId: target.id,
            newRole: role,
          ),
      successMessage: 'Cargo atualizado.',
    );
    if (succeeded && target.id == _actor.id && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteUser(UserProfile target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Excluir usuário?'),
          content: Text(
            'O perfil de ${target.name} e seus chamados locais serão removidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final succeeded = await _runMutation(
      () => ref
          .read(workspaceRepositoryProvider)
          .deleteUser(
            actorId: _actor.id,
            workspaceId: _dashboard.id,
            targetUserId: target.id,
          ),
      successMessage: 'Usuário excluído.',
    );
    if (succeeded) {
      await ref
          .read(profilePhotoServiceProvider)
          .deleteIfManaged(target.photoPath);
      if (target.id == _actor.id && mounted) Navigator.of(context).pop(true);
    }
  }

  Future<bool> _runMutation(
    Future<Object?> Function() operation, {
    required String successMessage,
    String? orphanPhotoPath,
  }) async {
    setState(() => _busy = true);
    try {
      await operation();
      await _reload();
      if (!mounted) return true;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
      return true;
    } catch (error) {
      if (orphanPhotoPath != null) {
        await ref
            .read(profilePhotoServiceProvider)
            .deleteIfManaged(orphanPhotoPath);
      }
      if (!mounted) return false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload() async {
    final dashboard = await ref
        .read(workspaceRepositoryProvider)
        .loadDashboard(workspaceId: _dashboard.id);
    if (dashboard == null) return;
    ref.invalidate(workspaceBootstrapProvider);
    if (mounted) setState(() => _dashboard = dashboard);
  }

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.moderator => 'Moderador',
    UserRole.user => 'Usuário',
  };
}

enum _UserAction { edit, role, delete }
