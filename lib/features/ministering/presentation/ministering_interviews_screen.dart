import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';

/// Histórico de entrevistas de uma dupla.
///
/// Não há status: a linha existe porque a entrevista aconteceu. Mais de uma
/// entrevista no mesmo trimestre é permitida — o Manual pede pelo menos uma, e
/// recusar a segunda apagaria trabalho que foi feito de verdade.
class MinisteringInterviewsScreen extends ConsumerStatefulWidget {
  const MinisteringInterviewsScreen({
    required this.callingId,
    required this.companionshipId,
    super.key,
  });

  final String callingId;
  final String companionshipId;

  @override
  ConsumerState<MinisteringInterviewsScreen> createState() =>
      _MinisteringInterviewsScreenState();
}

class _MinisteringInterviewsScreenState
    extends ConsumerState<MinisteringInterviewsScreen> {
  bool _busy = false;

  MinisteringInterviewsQuery get _query =>
      (callingId: widget.callingId, companionshipId: widget.companionshipId);

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(ministeringModuleProvider(widget.callingId));
    final companionship = module.value?.companionships
        .where((item) => item.id == widget.companionshipId)
        .firstOrNull;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Entrevistas')),
        floatingActionButton: companionship == null
            ? null
            : FloatingActionButton.extended(
                key: const Key('record-interview-button'),
                onPressed: _busy ? null : () => _record(companionship),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Registrar'),
              ),
        body: module.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _CenteredMessage(text: userErrorMessage(error)),
          data: (state) => companionship == null
              ? const _CenteredMessage(
                  text: 'Esta dupla não existe mais neste chamado.',
                )
              : _buildBody(state, companionship),
        ),
      ),
    );
  }

  Widget _buildBody(
    MinisteringModuleState state,
    MinisteringCompanionship companionship,
  ) {
    final history = ref.watch(ministeringInterviewsProvider(_query));
    final interviewed = state.isInterviewed(companionship.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companionship.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  companionship.members
                      .map((member) => member.displayLabel)
                      .join(' · '),
                ),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    interviewed
                        ? Icons.check_circle_outline
                        : Icons.schedule_outlined,
                    size: 18,
                  ),
                  label: Text(
                    interviewed
                        ? 'Entrevistada no ${state.summary.quarter.label}'
                        : 'Pendente no ${state.summary.quarter.label}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        history.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _CenteredMessage(text: userErrorMessage(error)),
          data: (interviews) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MinisteringSectionTitle(
                label: 'Registradas',
                count: interviews.length,
              ),
              const SizedBox(height: 8),
              if (interviews.isEmpty)
                const MinisteringEmptyState(
                  icon: Icons.event_note_outlined,
                  text: 'Nenhuma entrevista registrada para esta dupla.',
                )
              else
                for (final interview in interviews)
                  _InterviewCard(
                    interview: interview,
                    companionship: companionship,
                    onDelete: _busy ? null : () => _confirmDelete(interview),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _record(MinisteringCompanionship companionship) async {
    final draft = await showDialog<_InterviewDraft>(
      context: context,
      builder: (_) => _InterviewEditorDialog(companionship: companionship),
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .recordInterview(
            callingId: widget.callingId,
            companionshipId: companionship.id,
            completedOn: draft.completedOn,
            participantBrotherIds: draft.participantIds,
          ),
      'Entrevista registrada.',
    );
  }

  Future<void> _confirmDelete(MinisteringInterview interview) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover entrevista?'),
        content: Text(
          'A entrevista de '
          '${MaterialLocalizations.of(context).formatMediumDate(interview.completedAt)} '
          'sai do histórico e a dupla pode voltar a aparecer como pendente. '
          'Use isto apenas para corrigir um registro feito por engano.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm-delete-interview'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .deleteInterview(
            callingId: widget.callingId,
            interviewId: interview.id,
          ),
      'Entrevista removida.',
    );
  }

  Future<void> _runMutation(
    Future<void> Function() operation,
    String successMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await operation();
      ref
        ..invalidate(ministeringModuleProvider(widget.callingId))
        ..invalidate(ministeringInterviewsProvider(_query));
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard({
    required this.interview,
    required this.companionship,
    required this.onDelete,
  });

  final MinisteringInterview interview;
  final MinisteringCompanionship companionship;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final participants = companionship.members
        .where((member) => interview.participantIds.contains(member.id))
        .map((member) => member.displayLabel)
        .join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(interview.completedAt),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participants.isEmpty
                        ? 'Participantes fora da composição atual'
                        : participants,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    interview.quarter.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remover entrevista',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

/// Entrevista escolhida no editor, antes de ir para o repositório.
class _InterviewDraft {
  const _InterviewDraft({
    required this.completedOn,
    required this.participantIds,
  });

  final DateTime completedOn;
  final List<String> participantIds;
}

class _InterviewEditorDialog extends StatefulWidget {
  const _InterviewEditorDialog({required this.companionship});

  final MinisteringCompanionship companionship;

  @override
  State<_InterviewEditorDialog> createState() => _InterviewEditorDialogState();
}

class _InterviewEditorDialogState extends State<_InterviewEditorDialog> {
  late DateTime _date = DateTime.now();

  /// Começa com todos marcados: entrevistar a dupla inteira é o caso comum.
  late final Set<String> _participants = widget.companionship.members
      .map((member) => member.id)
      .toSet();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return AlertDialog(
      title: const Text('Registrar entrevista'),
      content: SizedBox(
        width: 380,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              key: const Key('interview-date-field'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Data da entrevista'),
              subtitle: Text(localizations.formatFullDate(_date)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickDate,
            ),
            const Divider(),
            const Text('Quem participou'),
            for (final member in widget.companionship.members)
              CheckboxListTile(
                key: Key('interview-participant-${member.id}'),
                value: _participants.contains(member.id),
                title: Text(member.displayLabel),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) => setState(() {
                  if (checked ?? false) {
                    _participants.add(member.id);
                  } else {
                    _participants.remove(member.id);
                  }
                }),
              ),
            const SizedBox(height: 8),
            const MinisteringPrivacyNote(
              text:
                  'Registre apenas que a entrevista aconteceu. O que foi '
                  'tratado nela não deve ser anotado no app.',
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
          key: const Key('interview-confirm'),
          onPressed: _participants.isEmpty ? null : _submit,
          child: const Text('Registrar'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      // Um ano para trás cobre os quatro trimestres do ciclo sem abrir o
      // seletor para um passado que o módulo não representa.
      firstDate: DateTime(today.year - 1),
      lastDate: today,
      helpText: 'Data da entrevista',
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() => Navigator.of(context).pop(
    _InterviewDraft(
      completedOn: _date,
      participantIds: _participants.toList(growable: false),
    ),
  );
}
