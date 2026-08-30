import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/app_info.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/features/workspace/presentation/manage_users_screen.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Aba Mais: o que não é rotina diária.
///
/// Só destinos que existem. A referência visual mostra notificações,
/// segurança e recursos oficiais; nenhum deles foi implementado, e entradas
/// que não levam a lugar nenhum seriam pior que a ausência delas.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({
    required this.dashboard,
    required this.currentUser,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageUsers = WorkspaceRolePolicy.allows(
      currentUser.role,
      WorkspacePermission.createUser,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
        // Aba, não tela empilhada: a seta de voltar sairia do shell
        // inteiro e sugeriria uma navegação que não existe aqui.
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs,
          Spacing.md,
          Spacing.xxl,
        ),
        children: [
          if (canManageUsers)
            _Entry(
              icon: Icons.group_outlined,
              title: 'Usuários',
              subtitle: '${dashboard.users.length} no Workspace',
              itemKey: const Key('more-users'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ManageUsersScreen(
                    dashboard: dashboard,
                    actorId: currentUser.id,
                  ),
                ),
              ),
            ),
          _Entry(
            icon: Icons.tune,
            title: 'Configurações',
            subtitle: 'Aparência e informações do app',
            itemKey: const Key('more-settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: Spacing.md),
          AppSurface(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                const AppIconTile(icon: Icons.lock_outline, size: 42),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meu Chamado ${AppInfo.version}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        'Projeto independente e não oficial. Seus dados ficam '
                        'neste aparelho.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.itemKey,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Key itemKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: itemKey,
      contentPadding: const EdgeInsets.fromLTRB(
        Spacing.sm,
        Spacing.xs,
        Spacing.sm,
        Spacing.xs,
      ),
      leading: AppIconTile(icon: icon, size: 42),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
