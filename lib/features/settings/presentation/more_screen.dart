import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/app_info.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/features/workspace/presentation/manage_users_screen.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Aba Mais: o que não é rotina diária, agrupado por área.
///
/// Só destinos que existem. A referência visual mostra notificações, recursos
/// oficiais e outras áreas que não foram implementadas; entradas que não levam
/// a lugar nenhum seriam pior que a ausência delas.
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
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.screenGutter,
          Spacing.sm,
          Spacing.screenGutter,
          Spacing.xxxl,
        ),
        children: [
          const _SectionLabel('Preferências'),
          const SizedBox(height: Spacing.sm),
          _Group(
            children: [
              _Entry(
                icon: Icons.tune,
                title: 'Configurações',
                subtitle: 'Aparência e segurança',
                itemKey: const Key('more-settings'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          if (canManageUsers) ...[
            const SizedBox(height: Spacing.section),
            const _SectionLabel('Workspace'),
            const SizedBox(height: Spacing.sm),
            _Group(
              children: [
                _Entry(
                  icon: Icons.group_outlined,
                  title: 'Gerenciar usuários',
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
              ],
            ),
          ],
          const SizedBox(height: Spacing.section),
          const _SectionLabel('Aplicativo'),
          const SizedBox(height: Spacing.sm),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 1,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppSurface(
    padding: EdgeInsets.zero,
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => ListTile(
    key: itemKey,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
