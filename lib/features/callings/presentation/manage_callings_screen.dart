import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/callings/domain/calling_catalog.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_authorization.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/feedback/app_haptics.dart';
import 'package:meu_chamado/shared/widgets/app_action_sheet.dart';
import 'package:meu_chamado/shared/widgets/app_form_sheet.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Gerenciamento dos chamados de um perfil.
///
/// Lista editorial: os ativos primeiro, os arquivados depois, cada linha com o
/// estado claro e as ações na folha. Um chamado com histórico é arquivado,
/// nunca destruído silenciosamente. A identidade é o `moduleKey`, não o
/// título — renomear não muda comportamento.
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
  void didUpdateWidget(ManageCallingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.dashboard, oldWidget.dashboard)) {
      _dashboard = widget.dashboard;
    }
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
          title: Text(
            _isOwnProfile ? 'Chamados' : 'Chamados de ${_target.name}',
          ),
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
            Spacing.screenGutter,
            Spacing.md,
            Spacing.screenGutter,
            Spacing.fabClearance,
          ),
          children: [
            AppSectionHeader(title: 'Ativos', count: active.length),
            const SizedBox(height: Spacing.sm),
            if (active.isEmpty)
              AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'Nenhum chamado ativo',
                message: canCreate
                    ? 'Adicione um chamado do catálogo para organizar as '
                          'rotinas dele.'
                    : 'Nenhum chamado ativo para este perfil.',
                action: canCreate
                    ? FilledButton.icon(
                        key: const Key('calling-empty-add'),
                        onPressed: _busy ? null : () => _chooseCalling(active),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar chamado'),
                      )
                    : null,
              )
            else
              for (final calling in active)
                _CallingCard(
                  calling: calling,
                  actionLabel: 'Arquivar',
                  actionIcon: Icons.archive_outlined,
                  onAction: _canArchive ? () => _archive(calling) : null,
                ),
            const SizedBox(height: Spacing.section),
            AppSectionHeader(title: 'Arquivados', count: archived.length),
            const SizedBox(height: Spacing.sm),
            if (archived.isEmpty)
              const AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Nada arquivado',
                message:
                    'Chamados arquivados guardam o histórico e podem voltar '
                    'a qualquer momento.',
              )
            else
              for (final calling in archived)
                _CallingCard(
                  calling: calling,
                  actionLabel: 'Restaurar',
                  actionIcon: Icons.unarchive_outlined,
                  archivedLook: true,
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
      isScrollControlled: true,
      builder: (sheetContext) => AppFormSheet(
        title: 'Catálogo de chamados',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha uma estrutura. O conteúdo completo de cada módulo '
              'chega em versões futuras.',
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),
            for (final item in CallingCatalog.values) ...[
              _CatalogTile(
                item: item,
                alreadyActive: activeKeys.contains(item.moduleKey),
                onTap: () => Navigator.of(sheetContext).pop(item),
              ),
              if (item != CallingCatalog.values.last)
                const SizedBox(height: Spacing.xs),
            ],
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
      AppHaptics.saved();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      AppHaptics.warning();
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

class _CallingCard extends StatelessWidget {
  const _CallingCard({
    required this.calling,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.archivedLook = false,
  });

  final CallingSummary calling;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final bool archivedLook;

  bool get _hasModule =>
      CallingCatalog.byModuleKey(calling.moduleKey)?.hasModule ?? false;

  void _openActions(BuildContext context) => showAppActionSheet(
    context: context,
    title: calling.title,
    actions: [
      AppAction(
        label: actionLabel,
        icon: actionIcon,
        enabled: onAction != null,
        onSelected: () => onAction?.call(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        key: Key('manage-calling-${calling.id}'),
        leading: Opacity(
          opacity: archivedLook ? 0.55 : 1,
          child: AppIconTile(
            icon: _hasModule
                ? Icons.assignment_turned_in_outlined
                : Icons.construction_outlined,
            size: 44,
          ),
        ),
        title: Text(
          calling.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          archivedLook
              ? 'Arquivado'
              : _hasModule
              ? 'Ativo • Módulo disponível'
              : 'Ativo • Em desenvolvimento',
          style: TextStyle(
            color: archivedLook ? scheme.onSurfaceVariant : null,
          ),
        ),
        trailing: onAction == null
            ? null
            : IconButton(
                tooltip: 'Ações do chamado',
                icon: const Icon(Icons.more_vert),
                onPressed: () => _openActions(context),
              ),
        onTap: onAction == null ? null : () => _openActions(context),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.item,
    required this.alreadyActive,
    required this.onTap,
  });

  final CallingDefinition item;
  final bool alreadyActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: Radii.surfaceBorder,
        onTap: alreadyActive ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: Radii.surfaceBorder,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      alreadyActive
                          ? 'Já está ativo neste perfil'
                          : item.description,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(
                alreadyActive
                    ? Icons.check_circle_outline
                    : Icons.add_circle_outline,
                color: alreadyActive ? scheme.secondary : scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
