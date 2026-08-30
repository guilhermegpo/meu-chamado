import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/callings/presentation/manage_callings_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/profile/presentation/user_editor_dialog.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/features/workspace/presentation/manage_users_screen.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    required this.dashboard,
    required this.currentUser,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late WorkspaceDashboard _dashboard;
  late UserProfile _currentUser;

  @override
  void initState() {
    super.initState();
    _dashboard = widget.dashboard;
    _currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final userCallings = _dashboard.callings
        .where((calling) => calling.userId == _currentUser.id)
        .toList(growable: false);
    final activeCallings = userCallings
        .where((calling) => calling.status == CallingStatus.active)
        .toList(growable: false);
    final archivedCount = userCallings
        .where((calling) => calling.status == CallingStatus.archived)
        .length;
    final canManageUsers = WorkspaceRolePolicy.allows(
      _currentUser.role,
      WorkspacePermission.createUser,
    );

    return Scaffold(
      appBar: AppBar(
        title: const AppBrandLockup(compact: true),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.xxxl,
          ),
          children: [
            _WelcomeHero(user: _currentUser, workspaceName: _dashboard.name),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editOwnProfile,
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Meu perfil'),
                  ),
                ),
                if (canManageUsers) ...[
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('manage-users-button'),
                      onPressed: _openUsers,
                      icon: const Icon(Icons.group_outlined),
                      label: const Text('Usuários'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Spacing.section),
            AppSectionHeader(
              title: 'Meus chamados',
              count: activeCallings.length,
              action: TextButton.icon(
                key: const Key('manage-callings-button'),
                onPressed: _openCallings,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Gerenciar'),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            AnimatedSwitcher(
              duration: Motion.base,
              switchInCurve: Motion.enter,
              switchOutCurve: Motion.exit,
              child: activeCallings.isEmpty
                  ? const AppEmptyState(
                      key: ValueKey('empty-callings'),
                      icon: Icons.assignment_outlined,
                      title: 'Nenhum chamado ativo',
                      message:
                          'Adicione um chamado para organizar suas rotinas em '
                          'um só lugar.',
                    )
                  : Column(
                      key: ValueKey(activeCallings.length),
                      children: [
                        for (final calling in activeCallings)
                          _CallingCard(
                            calling: calling,
                            hasModule: _hasModule(calling),
                            onTap: _hasModule(calling)
                                ? () => _openModule(calling)
                                : null,
                          ),
                      ],
                    ),
            ),
            if (archivedCount > 0) ...[
              const SizedBox(height: Spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: AppStatusPill(
                  icon: Icons.archive_outlined,
                  label:
                      '$archivedCount chamado${archivedCount == 1 ? '' : 's'} '
                      'arquivado${archivedCount == 1 ? '' : 's'}',
                ),
              ),
            ],
            const SizedBox(height: Spacing.section),
            AppSurface(
              gradient: AppGradients.soft(Theme.of(context).brightness),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppIconTile(icon: Icons.shield_outlined),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacidade por padrão',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: Spacing.xs),
                        const Text(
                          'Este Workspace funciona offline. Sincronização e '
                          'compartilhamento ainda não estão implementados.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasModule(CallingSummary calling) =>
      CallingCatalog.byModuleKey(calling.moduleKey)?.hasModule ?? false;

  Future<void> _openModule(CallingSummary calling) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MinisteringDashboardScreen(
          callingId: calling.id,
          callingTitle: calling.title,
        ),
      ),
    );
  }

  Future<void> _openUsers() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ManageUsersScreen(dashboard: _dashboard, actorId: _currentUser.id),
      ),
    );
    await _reload();
  }

  Future<void> _openCallings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ManageCallingsScreen(
          dashboard: _dashboard,
          actorId: _currentUser.id,
          targetUserId: _currentUser.id,
        ),
      ),
    );
    await _reload();
  }

  Future<void> _editOwnProfile() async {
    final result = await showDialog<UserEditorResult>(
      context: context,
      builder: (_) => UserEditorDialog(user: _currentUser, roleEditable: false),
    );
    if (result == null || !mounted) return;

    final previousPhotoPath = _currentUser.photoPath;
    final changedPhoto =
        result.removePhoto || result.photoPath != previousPhotoPath;
    try {
      await ref
          .read(workspaceRepositoryProvider)
          .updateUser(
            actorId: _currentUser.id,
            workspaceId: _dashboard.id,
            targetUserId: _currentUser.id,
            name: result.name,
            photoPath: result.photoPath,
            removePhoto: result.removePhoto,
          );
      await _reload();
      if (changedPhoto) {
        await ref
            .read(profilePhotoServiceProvider)
            .deleteIfManaged(previousPhotoPath);
      }
    } catch (error) {
      if (changedPhoto) {
        await ref
            .read(profilePhotoServiceProvider)
            .deleteIfManaged(result.photoPath);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
    }
  }

  Future<void> _reload() async {
    final dashboard = await ref
        .read(workspaceRepositoryProvider)
        .loadDashboard(workspaceId: _dashboard.id);
    if (dashboard == null || !mounted) return;
    UserProfile? currentUser;
    for (final user in dashboard.users) {
      if (user.id == _currentUser.id) {
        currentUser = user;
        break;
      }
    }
    if (currentUser == null) {
      Navigator.of(context).pop();
      return;
    }
    ref.invalidate(workspaceBootstrapProvider);
    setState(() {
      _dashboard = dashboard;
      _currentUser = currentUser!;
    });
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.user, required this.workspaceName});

  final UserProfile user;
  final String workspaceName;

  @override
  Widget build(BuildContext context) => AppSurface(
    gradient: AppGradients.darkHero,
    border: const Border(),
    shadow: true,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            gradient: AppGradients.brand,
            shape: BoxShape.circle,
          ),
          child: ProfileAvatar(
            name: user.name,
            photoPath: user.photoPath,
            radius: 30,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${user.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.offline_bolt_outlined,
                    size: 16,
                    color: AppColors.cyan400,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Workspace local · $workspaceName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CallingCard extends StatelessWidget {
  const _CallingCard({
    required this.calling,
    required this.hasModule,
    required this.onTap,
  });

  final CallingSummary calling;
  final bool hasModule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: Key('calling-card-${calling.id}'),
      contentPadding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.sm,
        Spacing.sm,
      ),
      leading: AppIconTile(
        icon: hasModule
            ? Icons.assignment_turned_in_outlined
            : Icons.construction_outlined,
        size: 48,
      ),
      title: Text(calling.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Spacing.xxs),
        child: Text(
          hasModule ? 'Ativo • Abrir módulo' : 'Ativo • Em desenvolvimento',
        ),
      ),
      trailing: hasModule
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 18)
          : null,
      onTap: onTap,
    ),
  );
}
