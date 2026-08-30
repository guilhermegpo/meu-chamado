import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/profile/application/edit_own_profile.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Aba Perfil: quem está usando o app e o que dá para ajustar sobre si mesmo.
///
/// Mostra somente o que o domínio já guarda — nome, foto e papel. A referência
/// visual traz telefone, e-mail e nascimento, que continuam fora do escopo.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    required this.dashboard,
    required this.currentUser,
    required this.onReloaded,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;
  final void Function(WorkspaceDashboard, UserProfile) onReloaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs,
          Spacing.md,
          Spacing.xxl,
        ),
        children: [
          AppSurface(
            gradient: AppGradients.darkHero,
            border: const Border(),
            shadow: true,
            child: Column(
              children: [
                ProfileAvatar(
                  name: currentUser.name,
                  photoPath: currentUser.photoPath,
                  radius: 44,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  currentUser.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  _roleLabel(currentUser.role),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.cyan400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          AppSurface(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Line(label: 'Workspace', value: dashboard.name),
                const Divider(),
                _Line(
                  label: 'Modo',
                  value: dashboard.type == WorkspaceType.local
                      ? 'Local, neste aparelho'
                      : 'Compartilhado',
                ),
                const Divider(),
                _Line(
                  label: 'Chamados ativos',
                  value: '${_activeCallings(dashboard, currentUser)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          FilledButton.icon(
            key: const Key('edit-own-profile-button'),
            onPressed: () => _edit(context, ref),
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Editar meu perfil'),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final saved = await editOwnProfile(
      context: context,
      ref: ref,
      user: currentUser,
      workspaceId: dashboard.id,
    );
    if (!saved) return;

    final reloaded = await ref
        .read(workspaceRepositoryProvider)
        .loadDashboard(workspaceId: dashboard.id);
    if (reloaded == null) return;
    ref.invalidate(workspaceBootstrapProvider);

    for (final user in reloaded.users) {
      if (user.id == currentUser.id) {
        onReloaded(reloaded, user);
        return;
      }
    }
  }

  static int _activeCallings(WorkspaceDashboard dashboard, UserProfile user) =>
      dashboard.callings
          .where(
            (calling) =>
                calling.userId == user.id &&
                calling.status == CallingStatus.active,
          )
          .length;

  static String _roleLabel(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.moderator => 'Moderador',
    UserRole.user => 'Usuário',
  };
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
