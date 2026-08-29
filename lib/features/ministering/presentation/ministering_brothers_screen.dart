import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';

/// Cadastro dos irmãos que podem compor duplas.
///
/// Um irmão nunca é apagado: é desativado. Apagar destruiria as entrevistas em
/// que ele participou, e o histórico é o registro do trabalho já feito.
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(userErrorMessage(error), textAlign: TextAlign.center),
            ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
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

class _BrotherCard extends StatelessWidget {
  const _BrotherCard({
    required this.brother,
    required this.onEdit,
    required this.onToggle,
    required this.toggleLabel,
    required this.toggleIcon,
  });

  final MinisteringBrother brother;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final String toggleLabel;
  final IconData toggleIcon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              brother.displayLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Editar identificação',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: toggleLabel,
            onPressed: onToggle,
            icon: Icon(toggleIcon),
          ),
        ],
      ),
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
