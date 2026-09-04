import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/feedback/app_haptics.dart';
import 'package:meu_chamado/shared/widgets/app_action_sheet.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Cadastro dos irmãos que podem compor duplas.
///
/// Um irmão que já foi usado é desativado, nunca apagado. Exclusão definitiva
/// existe somente para corrigir um cadastro que ainda não compôs dupla nem
/// participou de entrevista.
class MinisteringBrothersScreen extends ConsumerStatefulWidget {
  const MinisteringBrothersScreen({required this.callingId, super.key});

  final String callingId;

  @override
  ConsumerState<MinisteringBrothersScreen> createState() =>
      _MinisteringBrothersScreenState();
}

class _MinisteringBrothersScreenState
    extends ConsumerState<MinisteringBrothersScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(ministeringModuleProvider(widget.callingId));

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Irmãos ministradores')),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('add-brother-button'),
          onPressed: _busy ? null : _create,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Adicionar'),
        ),
        body: module.when(
          loading: () => const MinisteringListSkeleton(),
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
    final active = state.activeBrothers;
    final inactive = state.brothers
        .where((brother) => !brother.isActive)
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
              'Use apenas o primeiro nome ou as iniciais — o suficiente para '
              'você se orientar. Não registre telefone, endereço nem qualquer '
              'informação tratada na entrevista.',
        ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Ativos', count: active.length),
        const SizedBox(height: 8),
        if (active.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.person_outline,
            text:
                'Nenhum irmão cadastrado. Comece pelos que já compõem duplas.',
          )
        else
          for (final brother in active)
            _BrotherCard(
              brother: brother,
              onEdit: _busy ? null : () => _rename(brother),
              onToggle: _busy ? null : () => _setActive(brother, false),
              onDelete: _busy ? null : () => _considerDelete(brother),
              toggleLabel: 'Desativar',
              toggleIcon: Icons.person_off_outlined,
            ),
        const SizedBox(height: 24),
        MinisteringSectionTitle(label: 'Inativos', count: inactive.length),
        const SizedBox(height: 8),
        if (inactive.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.history_toggle_off,
            text: 'Nenhum irmão inativo.',
          )
        else ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Irmãos inativos não entram em duplas novas, mas continuam nas '
              'duplas e entrevistas já registradas.',
            ),
          ),
          for (final brother in inactive)
            _BrotherCard(
              brother: brother,
              onEdit: _busy ? null : () => _rename(brother),
              onToggle: _busy ? null : () => _setActive(brother, true),
              onDelete: _busy ? null : () => _considerDelete(brother),
              toggleLabel: 'Reativar',
              toggleIcon: Icons.person_add_alt_outlined,
            ),
        ],
      ],
    );
  }

  Future<void> _create() async {
    final label = await _askLabel(title: 'Novo irmão');
    if (label == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .createBrother(callingId: widget.callingId, displayLabel: label),
      'Irmão adicionado.',
    );
  }

  Future<void> _rename(MinisteringBrother brother) async {
    final label = await _askLabel(
      title: 'Editar identificação',
      initial: brother.displayLabel,
    );
    if (label == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .updateBrother(
            callingId: widget.callingId,
            brotherId: brother.id,
            displayLabel: label,
          ),
      'Identificação atualizada.',
    );
  }

  Future<void> _setActive(MinisteringBrother brother, bool isActive) =>
      _runMutation(
        () => ref
            .read(ministeringRepositoryProvider)
            .setBrotherActive(
              callingId: widget.callingId,
              brotherId: brother.id,
              isActive: isActive,
            ),
        isActive ? 'Irmão reativado.' : 'Irmão desativado.',
      );

  Future<void> _considerDelete(MinisteringBrother brother) async {
    late final MinisteringRemovalCheck check;
    setState(() => _busy = true);
    try {
      check = await ref
          .read(ministeringRepositoryProvider)
          .inspectBrotherRemoval(
            callingId: widget.callingId,
            brotherId: brother.id,
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
                ? 'Este cadastro já participa do histórico de entrevistas. '
                      'Desative-o para preservá-lo.'
                : 'Este cadastro compõe ${check.companionships} '
                      'dupla${check.companionships == 1 ? '' : 's'}. '
                      'Remova-o da composição ou desative-o.',
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
          title: const Text('Excluir cadastro?'),
          content: const Text(
            'Este cadastro nunca foi usado e pode ser excluído definitivamente. '
            'Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('confirm-delete-brother'),
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
          .deleteBrother(callingId: widget.callingId, brotherId: brother.id),
      'Cadastro excluído.',
    );
  }

  Future<String?> _askLabel({required String title, String? initial}) =>
      showDialog<String>(
        context: context,
        builder: (_) => _BrotherLabelDialog(title: title, initial: initial),
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

class _BrotherCard extends StatelessWidget {
  const _BrotherCard({
    required this.brother,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.toggleLabel,
    required this.toggleIcon,
  });

  final MinisteringBrother brother;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final String toggleLabel;
  final IconData toggleIcon;

  void _openActions(BuildContext context) => showAppActionSheet(
    context: context,
    title: brother.displayLabel,
    actions: [
      AppAction(
        label: 'Editar identificação',
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
      leading: AppInitialAvatar(label: brother.displayLabel),
      title: Text(brother.displayLabel),
      subtitle: Text(toggleLabel == 'Desativar' ? 'Ativo' : 'Inativo'),
      trailing: IconButton(
        tooltip: 'Ações do cadastro',
        icon: const Icon(Icons.more_vert),
        onPressed: () => _openActions(context),
      ),
      onTap: () => _openActions(context),
    ),
  );
}

class _BrotherLabelDialog extends StatefulWidget {
  const _BrotherLabelDialog({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_BrotherLabelDialog> createState() => _BrotherLabelDialogState();
}

class _BrotherLabelDialogState extends State<_BrotherLabelDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _formKey,
      child: TextFormField(
        key: const Key('brother-label-field'),
        controller: _controller,
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
        onFieldSubmitted: (_) => _submit(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const Key('brother-label-confirm'),
        onPressed: _submit,
        child: const Text('Salvar'),
      ),
    ],
  );

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(_controller.text.trim());
  }
}
