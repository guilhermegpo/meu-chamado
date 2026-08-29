import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Meu Chamado'),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              children: [
                ProfileAvatar(
                  name: _currentUser.name,
                  photoPath: _currentUser.photoPath,
                  radius: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${_currentUser.name}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text('Workspace local • ${_dashboard.name}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _editOwnProfile,
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Meu perfil'),
                ),
                if (canManageUsers)
                  OutlinedButton.icon(
                    key: const Key('manage-users-button'),
                    onPressed: _openUsers,
                    icon: const Icon(Icons.group_outlined),
                    label: const Text('Usuários'),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meus chamados',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  key: const Key('manage-callings-button'),
                  onPressed: _openCallings,
                  icon: const Icon(Icons.tune),
                  label: const Text('Gerenciar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (activeCallings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum chamado ativo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Você pode organizar zero, um ou vários chamados.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final calling in activeCallings)
                Card(
                  child: ListTile(
                    key: Key('calling-card-${calling.id}'),
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: Text(calling.title),
                    subtitle: Text(
                      _hasModule(calling)
                          ? 'Ativo • Abrir módulo'
                          : 'Ativo • Em desenvolvimento',
                    ),
                    trailing: _hasModule(calling)
                        ? const Icon(Icons.chevron_right)
                        : null,
                    onTap: _hasModule(calling)
                        ? () => _openModule(calling)
                        : null,
                  ),
                ),
            if (archivedCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$archivedCount chamado${archivedCount == 1 ? '' : 's'} '
                'arquivado${archivedCount == 1 ? '' : 's'}',
                textAlign: TextAlign.end,
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacidade por padrão',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Este Workspace funciona offline. Sincronização e '
                      'compartilhamento ainda não estão implementados.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Um chamado abre um módulo quando existe tela para o seu `moduleKey`.
  ///
  /// A checagem é pela chave do módulo, nunca pelo título: o título é texto
  /// livre e pode ser renomeado sem que a funcionalidade mude.
  bool _hasModule(CallingSummary calling) =>
      calling.moduleKey == CallingCatalog.ministeringSecretary.moduleKey;

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
