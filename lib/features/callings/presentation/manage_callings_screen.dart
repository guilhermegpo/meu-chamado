import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

class ManageCallingsScreen extends ConsumerStatefulWidget {
  const ManageCallingsScreen({
    required this.dashboard,
    required this.actorId,
    required this.targetUserId,
    this.showBackButton = true,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final String actorId;
  final String targetUserId;

  /// Como aba do shell a tela é um destino, não uma tela empilhada: exibir
  /// uma seta de voltar ali sugeriria uma navegação que não existe.
  final bool showBackButton;

  @override
  ConsumerState<ManageCallingsScreen> createState() =>
      _ManageCallingsScreenState();
}

class _ManageCallingsScreenState extends ConsumerState<ManageCallingsScreen> {
  late WorkspaceDashboard _dashboard;
  bool _busy = false;

  UserProfile get _actor =>
      _dashboard.users.firstWhere((user) => user.id == widget.actorId);

  UserProfile get _target =>
      _dashboard.users.firstWhere((user) => user.id == widget.targetUserId);

  bool get _isOwnProfile => _actor.id == _target.id;

  @override
  void initState() {
    super.initState();
    _dashboard = widget.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final userCallings = _dashboard.callings
        .where((calling) => calling.userId == _target.id)
        .toList(growable: false);
    final active = userCallings
        .where((calling) => calling.status == CallingStatus.active)
        .toList(growable: false);
    final archived = userCallings
        .where((calling) => calling.status == CallingStatus.archived)
        .toList(growable: false);
    final canCreate = WorkspaceRolePolicy.allows(
      _actor.role,
      _isOwnProfile
          ? WorkspacePermission.createOwnCalling
          : WorkspacePermission.createAnyCalling,
    );

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.showBackButton,
          title: const Text('Chamados'),
        ),
        floatingActionButton: canCreate
            ? FloatingActionButton.extended(
                key: const Key('add-calling-button'),
                onPressed: _busy ? null : () => _chooseCalling(active),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              )
            : null,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.xs,
            Spacing.md,
            Spacing.fabClearance,
          ),
          children: [
            AppSurface(
              gradient: AppGradients.soft(Theme.of(context).brightness),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppIconTile(icon: Icons.assignment_ind_outlined),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _target.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: Spacing.xs),
                        const Text(
                          'Módulos prontos abrem suas rotinas pela tela inicial; '
                          'os demais continuam sinalizados como futuros.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(label: 'Ativos', count: active.length),
            const SizedBox(height: 8),
            if (active.isEmpty)
              const _EmptyState(
                icon: Icons.assignment_outlined,
                text: 'Nenhum chamado ativo.',
              )
            else
              for (final calling in active)
                _CallingCard(
                  calling: calling,
                  actionLabel: 'Arquivar',
                  actionIcon: Icons.archive_outlined,
                  onAction: _canArchive ? () => _archive(calling) : null,
                ),
            const SizedBox(height: 24),
            _SectionTitle(label: 'Arquivados', count: archived.length),
            const SizedBox(height: 8),
            if (archived.isEmpty)
              const _EmptyState(
                icon: Icons.inventory_2_outlined,
                text: 'Nenhum chamado arquivado.',
              )
            else
              for (final calling in archived)
                _CallingCard(
                  calling: calling,
                  actionLabel: 'Restaurar',
                  actionIcon: Icons.unarchive_outlined,
                  onAction: _canArchive ? () => _restore(calling) : null,
                ),
          ],
        ),
      ),
    );
  }

  bool get _canArchive => WorkspaceRolePolicy.allows(
    _actor.role,
    _isOwnProfile
        ? WorkspacePermission.archiveOwnCalling
        : WorkspacePermission.archiveAnyCalling,
  );

  Future<void> _chooseCalling(List<CallingSummary> active) async {
    final activeKeys = active.map((calling) => calling.moduleKey).toSet();
    final definition = await showModalBottomSheet<CallingDefinition>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'Catálogo inicial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha uma estrutura. O conteúdo completo de cada módulo '
              'será entregue em versões futuras.',
            ),
            const SizedBox(height: 12),
            for (final item in CallingCatalog.values)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(item.title),
                  subtitle: Text(
                    activeKeys.contains(item.moduleKey)
                        ? 'Já está ativo neste perfil'
                        : item.description,
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  enabled: !activeKeys.contains(item.moduleKey),
                  onTap: activeKeys.contains(item.moduleKey)
                      ? null
                      : () => Navigator.of(context).pop(item),
                ),
              ),
          ],
        ),
      ),
    );
    if (definition == null || !mounted) return;

    await _runMutation(
      () => ref
          .read(workspaceRepositoryProvider)
          .createCalling(
            actorId: _actor.id,
            workspaceId: _dashboard.id,
            userId: _target.id,
            title: definition.title,
            moduleKey: definition.moduleKey,
          ),
      'Chamado adicionado.',
    );
  }

  Future<void> _archive(CallingSummary calling) => _runMutation(
    () => ref
        .read(workspaceRepositoryProvider)
        .archiveCalling(
          actorId: _actor.id,
          workspaceId: _dashboard.id,
          callingId: calling.id,
        ),
    'Chamado arquivado.',
  );

  Future<void> _restore(CallingSummary calling) => _runMutation(
    () => ref
        .read(workspaceRepositoryProvider)
        .restoreCalling(
          actorId: _actor.id,
          workspaceId: _dashboard.id,
          callingId: calling.id,
        ),
    'Chamado restaurado.',
  );

  Future<void> _runMutation(
    Future<void> Function() operation,
    String successMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await operation();
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) =>
      AppSectionHeader(title: label, count: count);
}

class _CallingCard extends StatelessWidget {
  const _CallingCard({
    required this.calling,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final CallingSummary calling;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const AppIconTile(
            icon: Icons.assignment_turned_in_outlined,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calling.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  CallingCatalog.byModuleKey(calling.moduleKey)?.hasModule ??
                          false
                      ? 'Módulo disponível'
                      : 'Em desenvolvimento',
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: actionLabel,
            onPressed: onAction,
            icon: Icon(actionIcon),
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => AppSurface(
    child: Row(
      children: [
        AppIconTile(icon: icon),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
