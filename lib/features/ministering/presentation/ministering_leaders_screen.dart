import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/feedback/app_haptics.dart';
import 'package:meu_chamado/shared/widgets/app_action_sheet.dart';
import 'package:meu_chamado/shared/widgets/app_form_sheet.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Liderança responsável pelas entrevistas de ministração.
///
/// Domínio próprio, separado do papel de Workspace: `ADMIN`, `MODERATOR` e
/// `USER` são técnicos e não representam autoridade eclesiástica. Um líder com
/// histórico é desativado, nunca apagado.
class MinisteringLeadersScreen extends ConsumerStatefulWidget {
  const MinisteringLeadersScreen({required this.callingId, super.key});

  final String callingId;

  @override
  ConsumerState<MinisteringLeadersScreen> createState() =>
      _MinisteringLeadersScreenState();
}

class _MinisteringLeadersScreenState
    extends ConsumerState<MinisteringLeadersScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(ministeringModuleProvider(widget.callingId));

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Liderança')),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('add-leader-button'),
          onPressed: _busy ? null : _create,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Adicionar'),
        ),
        body: module.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () =>
                ref.invalidate(ministeringModuleProvider(widget.callingId)),
          ),
          data: _buildList,
        ),
      ),
    );
  }

  Widget _buildList(MinisteringModuleState state) {
    final active = state.activeLeaders;
    final inactive = state.leaders
        .where((leader) => !leader.isActive)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.fabClearance,
      ),
      children: [
        const MinisteringPrivacyNote(
          text:
              'Presidência do Quórum de Élderes: quem conduz as entrevistas. '
              'Guarde só o primeiro nome ou as iniciais e o cargo — nada de '
              'telefone, endereço, número de registro ou notas.',
        ),
        const SizedBox(height: Spacing.md),
        const MinisteringEmptyState(
          icon: Icons.badge_outlined,
          text:
              'O entrevistador é sempre escolhido nesta lista. O secretário '
              'organiza a agenda, mas não vira entrevistador por isso.',
        ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Ativos', count: active.length),
        const SizedBox(height: 8),
        if (active.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.person_outline,
            text:
                'Nenhuma liderança cadastrada. Adicione ao menos o Presidente '
                'do Quórum.',
          )
        else
          for (final leader in active)
            _LeaderCard(
              leader: leader,
              onEdit: _busy ? null : () => _edit(leader),
              onToggle: _busy ? null : () => _setActive(leader, false),
              onDelete: _busy ? null : () => _considerDelete(leader),
              toggleLabel: 'Desativar',
              toggleIcon: Icons.person_off_outlined,
            ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Inativos', count: inactive.length),
        const SizedBox(height: 8),
        if (inactive.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.history_toggle_off,
            text: 'Nenhuma liderança inativa.',
          )
        else ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Liderança inativa não pode conduzir novas entrevistas, mas '
              'continua no histórico e nos agendamentos que já tinha.',
            ),
          ),
          for (final leader in inactive)
            _LeaderCard(
              leader: leader,
              onEdit: _busy ? null : () => _edit(leader),
              onToggle: _busy ? null : () => _setActive(leader, true),
              onDelete: _busy ? null : () => _considerDelete(leader),
              toggleLabel: 'Reativar',
              toggleIcon: Icons.person_add_alt_outlined,
            ),
        ],
      ],
    );
  }

  Future<void> _create() async {
    final draft = await _askLeader(title: 'Nova liderança');
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .createLeader(
            callingId: widget.callingId,
            displayLabel: draft.displayLabel,
            role: draft.role,
          ),
      'Liderança adicionada.',
    );
  }

  Future<void> _edit(MinisteringLeader leader) async {
    final draft = await _askLeader(
      title: 'Editar liderança',
      initialLabel: leader.displayLabel,
      initialRole: leader.role,
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .updateLeader(
            callingId: widget.callingId,
            leaderId: leader.id,
            displayLabel: draft.displayLabel,
            role: draft.role,
          ),
      'Liderança atualizada.',
    );
  }

  Future<void> _setActive(MinisteringLeader leader, bool isActive) =>
      _runMutation(
        () => ref
            .read(ministeringRepositoryProvider)
            .setLeaderActive(
              callingId: widget.callingId,
              leaderId: leader.id,
              isActive: isActive,
            ),
        isActive ? 'Liderança reativada.' : 'Liderança desativada.',
      );

  Future<void> _considerDelete(MinisteringLeader leader) async {
    late final MinisteringRemovalCheck check;
    setState(() => _busy = true);
    try {
      check = await ref
          .read(ministeringRepositoryProvider)
          .inspectLeaderRemoval(
            callingId: widget.callingId,
            leaderId: leader.id,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    if (!check.canDelete) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Exclusão indisponível'),
          content: Text(
            check.hasHistory
                ? 'Esta liderança consta no histórico de entrevistas. '
                      'Desative-a para preservá-lo.'
                : 'Esta liderança tem ${check.appointments} '
                      'entrevista${check.appointments == 1 ? '' : 's'} '
                      'agendada${check.appointments == 1 ? '' : 's'}. '
                      'Reatribua ou cancele antes de excluir.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Excluir liderança?'),
          content: const Text(
            'Esta liderança nunca conduziu nem tem entrevista agendada e pode '
            'ser excluída definitivamente. Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('confirm-delete-leader'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .deleteLeader(callingId: widget.callingId, leaderId: leader.id),
      'Liderança excluída.',
    );
  }

  Future<_LeaderDraft?> _askLeader({
    required String title,
    String? initialLabel,
    MinisteringLeadershipRole? initialRole,
  }) => showModalBottomSheet<_LeaderDraft>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LeaderDialog(
      title: title,
      initialLabel: initialLabel,
      initialRole: initialRole ?? MinisteringLeadershipRole.quorumPresident,
    ),
  );

  Future<void> _runMutation(
    Future<void> Function() operation,
    String successMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await operation();
      ref.invalidate(ministeringModuleProvider(widget.callingId));
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
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({
    required this.leader,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.toggleLabel,
    required this.toggleIcon,
  });

  final MinisteringLeader leader;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final String toggleLabel;
  final IconData toggleIcon;

  void _openActions(BuildContext context) => showAppActionSheet(
    context: context,
    title: '${leader.displayLabel} · ${leader.role.label}',
    actions: [
      AppAction(
        label: 'Editar',
        icon: Icons.edit_outlined,
        enabled: onEdit != null,
        onSelected: () => onEdit?.call(),
      ),
      AppAction(
        label: toggleLabel,
        icon: toggleIcon,
        enabled: onToggle != null,
        onSelected: () => onToggle?.call(),
      ),
      AppAction(
        label: 'Verificar exclusão',
        icon: Icons.delete_outline,
        destructive: true,
        enabled: onDelete != null,
        onSelected: () => onDelete?.call(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: AppInitialAvatar(label: leader.displayLabel),
      title: Text(leader.displayLabel),
      subtitle: Text(leader.role.label),
      trailing: IconButton(
        tooltip: 'Ações da liderança',
        icon: const Icon(Icons.more_vert),
        onPressed: () => _openActions(context),
      ),
      onTap: () => _openActions(context),
    ),
  );
}

/// Identificação e papel escolhidos no editor, antes de ir ao repositório.
class _LeaderDraft {
  const _LeaderDraft({required this.displayLabel, required this.role});

  final String displayLabel;
  final MinisteringLeadershipRole role;
}

class _LeaderDialog extends StatefulWidget {
  const _LeaderDialog({
    required this.title,
    required this.initialRole,
    this.initialLabel,
  });

  final String title;
  final MinisteringLeadershipRole initialRole;
  final String? initialLabel;

  @override
  State<_LeaderDialog> createState() => _LeaderDialogState();
}

class _LeaderDialogState extends State<_LeaderDialog> {
  late final TextEditingController _label = TextEditingController(
    text: widget.initialLabel ?? '',
  );
  late MinisteringLeadershipRole _role = widget.initialRole;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppFormSheet(
    title: widget.title,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const Key('leader-confirm'),
        onPressed: _submit,
        child: const Text('Salvar'),
      ),
    ],
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('leader-label-field'),
            controller: _label,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Identificação',
              helperText: 'Primeiro nome ou iniciais.',
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Informe uma identificação.'
                : null,
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<MinisteringLeadershipRole>(
            key: const Key('leader-role-field'),
            initialValue: _role,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Cargo na presidência do quórum',
            ),
            items: MinisteringLeadershipRole.values
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(
                      role.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            selectedItemBuilder: (context) => MinisteringLeadershipRole.values
                .map(
                  (role) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      role.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
        ],
      ),
    ),
  );

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context)
        .pop(_LeaderDraft(displayLabel: _label.text.trim(), role: _role));
  }
}
