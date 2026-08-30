import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

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
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () =>
                ref.invalidate(ministeringModuleProvider(widget.callingId)),
          ),
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
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.fabClearance,
      ),
      children: [
        AppSurface(
          gradient: AppGradients.soft(Theme.of(context).brightness),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companionship.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Sem rótulo próprio, o título já é a lista de integrantes:
              // repeti-la abaixo mostraria a mesma linha duas vezes.
              if (companionship.displayLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  companionship.members
                      .map((member) => member.displayLabel)
                      .join(' · '),
                ),
              ],
              const SizedBox(height: 12),
              AppStatusPill(
                positive: interviewed,
                icon: interviewed
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
                label: interviewed
                    ? 'Entrevistada no ${state.summary.quarter.label}'
                    : 'Pendente no ${state.summary.quarter.label}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        history.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () =>
                ref.invalidate(ministeringInterviewsProvider(_query)),
          ),
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
                    onEdit: _busy
                        ? null
                        : () => _edit(interview, companionship),
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
      builder: (_) => _InterviewEditorDialog(
        title: 'Registrar entrevista',
        actionLabel: 'Registrar',
        companionship: companionship,
        initialDate: DateTime.now(),
        initialParticipantIds: companionship.members
            .map((member) => member.id)
            .toSet(),
      ),
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

  Future<void> _edit(
    MinisteringInterview interview,
    MinisteringCompanionship companionship,
  ) async {
    final currentMemberIds = companionship.members
        .map((member) => member.id)
        .toSet();
    final draft = await showDialog<_InterviewDraft>(
      context: context,
      builder: (_) => _InterviewEditorDialog(
        title: 'Corrigir entrevista',
        actionLabel: 'Salvar correção',
        companionship: companionship,
        initialDate: displayCalendarDate(interview.completedAt),
        initialParticipantIds: interview.participantIds
            .where(currentMemberIds.contains)
            .toSet(),
      ),
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .updateInterview(
            callingId: widget.callingId,
            interviewId: interview.id,
            completedOn: draft.completedOn,
            participantBrotherIds: draft.participantIds,
          ),
      'Entrevista corrigida.',
    );
  }

  Future<void> _confirmDelete(MinisteringInterview interview) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover entrevista?'),
        content: Text(
          'A entrevista de '
          '${MaterialLocalizations.of(context).formatMediumDate(displayCalendarDate(interview.completedAt))} '
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
    required this.onEdit,
    required this.onDelete,
  });

  final MinisteringInterview interview;
  final MinisteringCompanionship companionship;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final participants = companionship.members
        .where((member) => interview.participantIds.contains(member.id))
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
        leading: const AppIconTile(icon: Icons.event_available_outlined),
        title: Text(
          MaterialLocalizations.of(context)
              .formatMediumDate(interview.completedAt),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: Spacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participants.isEmpty
                    ? 'Participantes fora da composição atual'
                    : participants,
              ),
              Text(
                interview.quarter.label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Corrigir entrevista',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
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
  const _InterviewEditorDialog({
    required this.title,
    required this.actionLabel,
    required this.companionship,
    required this.initialDate,
    required this.initialParticipantIds,
  });

  final String title;
  final String actionLabel;
  final MinisteringCompanionship companionship;
  final DateTime initialDate;
  final Set<String> initialParticipantIds;

  @override
  State<_InterviewEditorDialog> createState() => _InterviewEditorDialogState();
}

class _InterviewEditorDialogState extends State<_InterviewEditorDialog> {
  late DateTime _date = widget.initialDate;

  late final Set<String> _participants = widget.initialParticipantIds.toSet();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.title),
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
          child: Text(widget.actionLabel),
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
