import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/callings/presentation/manage_callings_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    required this.dashboard,
    required this.currentUser,
    this.onOpenCallings,
    this.onReloaded,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;

  /// Leva para a aba Chamados quando a Home vive dentro do shell.
  ///
  /// Sem isto a Home empilharia a mesma tela que já é um destino da barra, e
  /// o usuário terminaria com dois caminhos para o mesmo lugar.
  final VoidCallback? onOpenCallings;

  /// Avisa o shell de que o Workspace foi relido, para as outras abas não
  /// continuarem mostrando o estado anterior.
  final void Function(WorkspaceDashboard, UserProfile)? onReloaded;

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
            const SizedBox(height: Spacing.section),
            AppSectionHeader(
              title: 'Meus chamados',
              count: activeCallings.length,
              action: TextButton.icon(
                key: const Key('manage-callings-button'),
                onPressed: widget.onOpenCallings ?? _openCallings,
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
    widget.onReloaded?.call(dashboard, currentUser);
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
