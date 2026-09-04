import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/callings/presentation/manage_callings_screen.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_skeleton.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Início contextual.
///
/// A ordem responde ao que a pessoa precisa resolver agora: uma saudação
/// curta, o estado operacional dos chamados que já têm módulo (o que falta,
/// a próxima ação), e só depois a lista administrativa dos chamados. Não é um
/// menu de atalhos.
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
  final VoidCallback? onOpenCallings;

  /// Avisa o shell de que o Workspace foi relido.
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
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // O shell pode readotar o Workspace depois de uma mudança feita por outra
    // aba; sem isto a Home continuaria com o estado com que foi construída.
    if (!identical(widget.dashboard, oldWidget.dashboard)) {
      _dashboard = widget.dashboard;
    }
    if (!identical(widget.currentUser, oldWidget.currentUser)) {
      _currentUser = widget.currentUser;
    }
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

    final readyCallings = activeCallings
        .where(_hasModule)
        .toList(growable: false);
    final plainCallings = activeCallings
        .where((calling) => !_hasModule(calling))
        .toList(growable: false);

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
            Spacing.screenGutter,
            Spacing.sm,
            Spacing.screenGutter,
            Spacing.xxxl,
          ),
          children: [
            _Greeting(
              key: const Key('home-greeting'),
              user: _currentUser,
              workspaceName: _dashboard.name,
            ),
            if (activeCallings.isEmpty) ...[
              const SizedBox(height: Spacing.section),
              AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'Nenhum chamado ativo',
                message:
                    'Adicione um chamado para acompanhar suas rotinas em um '
                    'só lugar.',
                action: FilledButton.icon(
                  key: const Key('home-empty-add-calling'),
                  onPressed: widget.onOpenCallings ?? _openCallings,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar chamado'),
                ),
              ),
            ],
            for (final calling in readyCallings) ...[
              const SizedBox(height: Spacing.section),
              _MinisteringPulse(
                key: Key('home-ministering-${calling.id}'),
                calling: calling,
                onOpen: () => _openModule(calling),
              ),
            ],
            if (plainCallings.isNotEmpty) ...[
              const SizedBox(height: Spacing.section),
              AppSectionHeader(
                title: 'Outros chamados',
                count: plainCallings.length,
                action: TextButton.icon(
                  key: const Key('manage-callings-button'),
                  onPressed: widget.onOpenCallings ?? _openCallings,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Gerenciar'),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              for (final calling in plainCallings)
                _CallingCard(calling: calling),
            ] else if (readyCallings.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('manage-callings-button'),
                  onPressed: widget.onOpenCallings ?? _openCallings,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Gerenciar chamados'),
                ),
              ),
            ],
            if (archivedCount > 0) ...[
              const SizedBox(height: Spacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: AppStatusPill(
                  icon: Icons.archive_outlined,
                  label:
                      '$archivedCount chamado${archivedCount == 1 ? '' : 's'} '
                      'arquivado${archivedCount == 1 ? '' : 's'}',
                ),
              ),
            ],
            const SizedBox(height: Spacing.section),
            const _PrivacyNote(),
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
    if (mounted) ref.invalidate(ministeringModuleProvider(calling.id));
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

/// Saudação pelo período do dia. Curta: uma linha de presença, uma de contexto.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.user, required this.workspaceName, super.key});

  final UserProfile user;
  final String workspaceName;

  static String _partOfDay(int hour) {
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final first = user.name.split(' ').first;
    return AppSurface(
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
              radius: 28,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_partOfDay(DateTime.now().hour)}, $first',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: Spacing.xxs),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: AppColors.cyan400,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        'Workspace local · $workspaceName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
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
}

/// Estado operacional do chamado de Ministração, direto na Home.
///
/// Responde "o que falta?" antes de "onde configuro?": o trimestre, quantas
/// duplas faltam, e a próxima ação concreta. Carrega com esqueleto, falha com
/// calma.
class _MinisteringPulse extends ConsumerWidget {
  const _MinisteringPulse({
    required this.calling,
    required this.onOpen,
    super.key,
  });

  final CallingSummary calling;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref.watch(ministeringModuleProvider(calling.id));
    final theme = Theme.of(context);

    return AppSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: Radii.surfaceBorder,
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIconTile(
                    icon: Icons.volunteer_activism_outlined,
                    size: 40,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      calling.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              module.when(
                loading: () => const AppSkeletonList(rows: 2, rowHeight: 20),
                error: (error, _) => Row(
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(child: Text(userErrorMessage(error))),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(ministeringModuleProvider(calling.id)),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
                data: (state) => _summary(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, MinisteringModuleState state) {
    final theme = Theme.of(context);
    final summary = state.summary;
    final total = summary.activeCompanionships;

    if (total == 0) {
      return Text(
        state.activeBrothers.length >= 2
            ? 'Monte as duplas para acompanhar o trimestre.'
            : 'Comece cadastrando os irmãos ministradores.',
        style: theme.textTheme.bodyMedium,
      );
    }

    final nextAppointment = state.appointments.isEmpty
        ? null
        : state.appointments.first;
    final pending = summary.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.quarter.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          '${summary.interviewedCompanionships} de $total '
          'dupla${total == 1 ? '' : 's'} '
          'entrevistada${total == 1 ? '' : 's'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: summary.progress, minHeight: 6),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Icon(
              nextAppointment != null
                  ? Icons.event_outlined
                  : pending == 0
                  ? Icons.check_circle_outline
                  : Icons.pending_actions_outlined,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                nextAppointment != null
                    ? 'Próxima: '
                          '${formatAppointmentMoment(context, nextAppointment.scheduledAt)}'
                    : pending == 0
                    ? 'Tudo em dia neste trimestre.'
                    : '$pending dupla${pending == 1 ? '' : 's'} '
                          'sem entrevista nem agendamento.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallingCard extends StatelessWidget {
  const _CallingCard({required this.calling});

  final CallingSummary calling;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: Key('calling-card-${calling.id}'),
      contentPadding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.sm,
      ),
      leading: const AppIconTile(icon: Icons.construction_outlined, size: 44),
      title: Text(calling.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: Spacing.xxs),
        child: Text('Ativo • Em desenvolvimento'),
      ),
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => AppSurface(
    padding: const EdgeInsets.all(Spacing.md),
    gradient: AppGradients.soft(Theme.of(context).brightness),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            'Este Workspace funciona offline e protegido por PIN. '
            'Sincronização e compartilhamento ainda não existem.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
