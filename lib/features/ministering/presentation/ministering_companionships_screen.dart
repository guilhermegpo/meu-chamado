import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Composição das duplas de ministração.
///
/// Uma dupla tem dois integrantes, ou três quando um jovem acompanha. Assim
/// como o irmão, uma dupla com histórico é desativada em vez de apagada. Uma
/// composição criada por engano ainda pode ser excluída enquanto não houver
/// entrevista vinculada.
class MinisteringCompanionshipsScreen extends ConsumerStatefulWidget {
  const MinisteringCompanionshipsScreen({required this.callingId, super.key});

  final String callingId;

  @override
  ConsumerState<MinisteringCompanionshipsScreen> createState() =>
      _MinisteringCompanionshipsScreenState();
}

class _MinisteringCompanionshipsScreenState
    extends ConsumerState<MinisteringCompanionshipsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(ministeringModuleProvider(widget.callingId));

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duplas'),
          actions: [
            IconButton(
              key: const Key('open-brothers-button'),
              tooltip: 'Irmãos ministradores',
              onPressed: _openBrothers,
              icon: const Icon(Icons.group_outlined),
            ),
          ],
        ),
        floatingActionButton: module.hasValue
            ? FloatingActionButton.extended(
                key: const Key('add-companionship-button'),
                onPressed: _busy
                    ? null
                    : () => _create(module.requireValue.activeBrothers),
                icon: const Icon(Icons.add),
                label: const Text('Nova dupla'),
              )
            : null,
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
    final active = state.activeCompanionships;
    final inactive = state.companionships
        .where((item) => !item.isActive)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.fabClearance,
      ),
      children: [
        if (state.activeBrothers.length < 2)
          const MinisteringEmptyState(
            icon: Icons.info_outline,
            text:
                'Cadastre ao menos dois irmãos ativos antes de montar uma '
                'dupla.',
          )
        else
          const MinisteringPrivacyNote(
            text:
                'Uma dupla tem dois integrantes, ou três quando um jovem '
                'acompanha.',
          ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Ativas', count: active.length),
        const SizedBox(height: 8),
        if (active.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.people_outline,
            text: 'Nenhuma dupla montada.',
          )
        else
          for (final companionship in active)
            _CompanionshipCard(
              companionship: companionship,
              onEdit: _busy
                  ? null
                  : () => _edit(companionship, state.activeBrothers),
              onToggle: _busy
                  ? null
                  : () => _considerDeactivate(
                      companionship,
                      state.appointmentFor(companionship.id),
                    ),
              onDelete: _busy ? null : () => _considerDelete(companionship),
              toggleLabel: 'Desativar dupla',
              toggleIcon: Icons.pause_circle_outline,
            ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Inativas', count: inactive.length),
        const SizedBox(height: 8),
        if (inactive.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.history_toggle_off,
            text: 'Nenhuma dupla inativa.',
          )
        else ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Duplas inativas saem da contagem do trimestre e mantêm as '
              'entrevistas já registradas.',
            ),
          ),
          for (final companionship in inactive)
            _CompanionshipCard(
              companionship: companionship,
              onEdit: _busy
                  ? null
                  : () => _edit(companionship, state.activeBrothers),
              onToggle: _busy ? null : () => _setActive(companionship, true),
              onDelete: _busy ? null : () => _considerDelete(companionship),
              toggleLabel: 'Reativar dupla',
              toggleIcon: Icons.play_circle_outline,
            ),
        ],
      ],
    );
  }

  Future<void> _openBrothers() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MinisteringBrothersScreen(callingId: widget.callingId),
      ),
    );
    ref.invalidate(ministeringModuleProvider(widget.callingId));
  }

  Future<void> _create(List<MinisteringBrother> candidates) async {
    final draft = await _askComposition(
      title: 'Nova dupla',
      candidates: candidates,
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .createCompanionship(
            callingId: widget.callingId,
            brotherIds: draft.brotherIds,
            displayLabel: draft.displayLabel,
          ),
      'Dupla criada.',
    );
  }

  Future<void> _edit(
    MinisteringCompanionship companionship,
    List<MinisteringBrother> candidates,
  ) async {
    final activeIds = candidates.map((brother) => brother.id).toSet();
    final draft = await _askComposition(
      title: 'Editar dupla',
      candidates: candidates,
      initialLabel: companionship.displayLabel,
      initialSelection: companionship.members
          .where((member) => activeIds.contains(member.id))
          .map((member) => member.id)
          .toList(growable: false),
      droppedInactive: companionship.members
          .where((member) => !activeIds.contains(member.id))
          .length,
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .updateCompanionship(
            callingId: widget.callingId,
            companionshipId: companionship.id,
            brotherIds: draft.brotherIds,
            displayLabel: draft.displayLabel,
          ),
      'Dupla atualizada.',
    );
  }

  Future<void> _considerDeactivate(
    MinisteringCompanionship companionship,
    MinisteringAppointment? appointment,
  ) async {
    if (appointment != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Desativar e cancelar agendamento?'),
          content: const Text(
            'Esta dupla tem uma entrevista agendada. Ao desativá-la, o '
            'agendamento será cancelado. Entrevistas já realizadas serão '
            'preservadas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              key: const Key('confirm-deactivate-companionship'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Desativar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await _setActive(companionship, false);
  }

  Future<void> _setActive(
    MinisteringCompanionship companionship,
    bool isActive,
  ) => _runMutation(
    () => ref
        .read(ministeringRepositoryProvider)
        .setCompanionshipActive(
          callingId: widget.callingId,
          companionshipId: companionship.id,
          isActive: isActive,
        ),
    isActive ? 'Dupla reativada.' : 'Dupla desativada.',
  );

  Future<void> _considerDelete(MinisteringCompanionship companionship) async {
    late final MinisteringRemovalCheck check;
    setState(() => _busy = true);
    try {
      check = await ref
          .read(ministeringRepositoryProvider)
          .inspectCompanionshipRemoval(
            callingId: widget.callingId,
            companionshipId: companionship.id,
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
          content: Text(_removalBlockedMessage(check)),
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
          title: const Text('Excluir dupla?'),
          content: const Text(
            'Esta dupla ainda não tem entrevistas e pode ser excluída '
            'definitivamente. Os cadastros dos integrantes serão mantidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('confirm-delete-companionship'),
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
          .deleteCompanionship(
            callingId: widget.callingId,
            companionshipId: companionship.id,
          ),
      'Dupla excluída.',
    );
  }

  String _removalBlockedMessage(MinisteringRemovalCheck check) {
    if (check.interviews > 0 && check.appointments > 0) {
      return 'Esta dupla tem ${check.interviews} '
          'entrevista${check.interviews == 1 ? '' : 's'} registrada'
          '${check.interviews == 1 ? '' : 's'} e uma entrevista agendada. '
          'Cancele o agendamento e desative a dupla para preservar o histórico.';
    }
    if (check.interviews > 0) {
      return 'Esta dupla tem ${check.interviews} '
          'entrevista${check.interviews == 1 ? '' : 's'} registrada'
          '${check.interviews == 1 ? '' : 's'}. Desative-a para preservar '
          'o histórico.';
    }
    return 'Esta dupla tem uma entrevista agendada. Cancele o agendamento '
        'antes de excluir a dupla.';
  }

  Future<_CompanionshipDraft?> _askComposition({
    required String title,
    required List<MinisteringBrother> candidates,
    String? initialLabel,
    List<String> initialSelection = const [],
    int droppedInactive = 0,
  }) => showDialog<_CompanionshipDraft>(
    context: context,
    builder: (_) => _CompanionshipEditorDialog(
      title: title,
      candidates: candidates,
      initialLabel: initialLabel,
      initialSelection: initialSelection,
      droppedInactive: droppedInactive,
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
}

class _CompanionshipCard extends StatelessWidget {
  const _CompanionshipCard({
    required this.companionship,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.toggleLabel,
    required this.toggleIcon,
  });

  final MinisteringCompanionship companionship;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final String toggleLabel;
  final IconData toggleIcon;

  @override
  Widget build(BuildContext context) {
    final members = companionship.members
        .map((member) => member.displayLabel)
        .join(' · ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs,
          Spacing.xs,
          Spacing.xs,
        ),
        leading: const AppIconTile(icon: Icons.people_outline, size: 44),
        title: Text(companionship.title),
        subtitle: companionship.displayLabel != null
            ? Text(members)
            : Text(toggleLabel == 'Desativar dupla' ? 'Ativa' : 'Inativa'),
        trailing: PopupMenuButton<_CompanionshipAction>(
          tooltip: 'Ações da dupla',
          onSelected: (action) => switch (action) {
            _CompanionshipAction.edit => onEdit?.call(),
            _CompanionshipAction.toggle => onToggle?.call(),
            _CompanionshipAction.delete => onDelete?.call(),
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _CompanionshipAction.edit,
              enabled: onEdit != null,
              child: const ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar dupla'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CompanionshipAction.toggle,
              enabled: onToggle != null,
              child: ListTile(
                leading: Icon(toggleIcon),
                title: Text(toggleLabel),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CompanionshipAction.delete,
              enabled: onDelete != null,
              child: const ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Verificar exclusão da dupla'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CompanionshipAction { edit, toggle, delete }

/// Composição escolhida no editor, antes de ir para o repositório.
class _CompanionshipDraft {
  const _CompanionshipDraft({required this.brotherIds, this.displayLabel});

  final List<String> brotherIds;
  final String? displayLabel;
}

class _CompanionshipEditorDialog extends StatefulWidget {
  const _CompanionshipEditorDialog({
    required this.title,
    required this.candidates,
    required this.initialSelection,
    required this.droppedInactive,
    this.initialLabel,
  });

  final String title;
  final List<MinisteringBrother> candidates;
  final List<String> initialSelection;

  /// Quantos integrantes atuais estão inativos e por isso não aparecem.
  ///
  /// A dupla não pode ser salva com eles, então o editor avisa em vez de
  /// deixar o usuário descobrir pelo erro depois de confirmar.
  final int droppedInactive;
  final String? initialLabel;

  @override
  State<_CompanionshipEditorDialog> createState() =>
      _CompanionshipEditorDialogState();
}

class _CompanionshipEditorDialogState
    extends State<_CompanionshipEditorDialog> {
  late final Set<String> _selected = widget.initialSelection.toSet();
  late final TextEditingController _label = TextEditingController(
    text: widget.initialLabel ?? '',
  );

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  bool get _isValid => _selected.length >= 2 && _selected.length <= 3;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 380,
      child: ListView(
        shrinkWrap: true,
        children: [
          if (widget.droppedInactive > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.droppedInactive == 1
                    ? 'Um integrante desta dupla está inativo e não pode '
                          'continuar nela. Reative-o ou escolha outro.'
                    : '${widget.droppedInactive} integrantes desta dupla '
                          'estão inativos e não podem continuar nela.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Text(
            'Selecione 2 ou 3 integrantes '
            '(${_selected.length} selecionado'
            '${_selected.length == 1 ? '' : 's'}).',
          ),
          const SizedBox(height: 4),
          for (final brother in widget.candidates)
            CheckboxListTile(
              key: Key('companionship-member-${brother.id}'),
              value: _selected.contains(brother.id),
              title: Text(brother.displayLabel),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _selected.add(brother.id);
                } else {
                  _selected.remove(brother.id);
                }
              }),
            ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('companionship-label-field'),
            controller: _label,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Rótulo (opcional)',
              helperText: 'Vazio: a dupla é identificada pelos integrantes.',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const Key('companionship-confirm'),
        onPressed: _isValid ? _submit : null,
        child: const Text('Salvar'),
      ),
    ],
  );

  void _submit() {
    final label = _label.text.trim();
    Navigator.of(context).pop(
      _CompanionshipDraft(
        brotherIds: _selected.toList(growable: false),
        displayLabel: label.isEmpty ? null : label,
      ),
    );
  }
}
