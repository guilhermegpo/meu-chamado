import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_leaders_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Tela operacional de uma dupla: o estado dela no trimestre, a entrevista
/// agendada (se houver) e o histórico das realizadas.
///
/// Três estados, todos derivados da existência de linhas, nunca de uma coluna
/// de status: **pendente** (nada), **agendada** (há um agendamento aberto),
/// **entrevistada** (há entrevista no trimestre). Cancelar um agendamento
/// nunca apaga uma entrevista já realizada.
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
    final appointment = state.appointmentFor(companionship.id);
    final activeLeaders = state.activeLeaders;

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
                    : appointment != null
                    ? Icons.event_outlined
                    : Icons.schedule_outlined,
                label: interviewed
                    ? 'Entrevistada no ${state.summary.quarter.label}'
                    : appointment != null
                    ? 'Agendada no ${state.summary.quarter.label}'
                    : 'Pendente no ${state.summary.quarter.label}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (appointment != null)
          _AppointmentCard(
            appointment: appointment,
            interviewer: state.leaderById(appointment.interviewerId),
            onComplete: _busy
                ? null
                : () => _complete(appointment, companionship, state),
            onReschedule: _busy
                ? null
                : () => _reschedule(appointment, activeLeaders),
            onCancel: _busy ? null : () => _confirmCancel(appointment),
          )
        else
          _ScheduleCallToAction(
            hasLeaders: activeLeaders.isNotEmpty,
            onSchedule: _busy
                ? null
                : () => _schedule(companionship, activeLeaders),
            onOpenLeaders: () => _openLeaders(),
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
              Row(
                children: [
                  Expanded(
                    child: MinisteringSectionTitle(
                      label: 'Registradas',
                      count: interviews.length,
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('record-interview-button'),
                    onPressed: _busy
                        ? null
                        : () => _record(companionship, activeLeaders),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                  ),
                ],
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
                    interviewer: state.leaderById(interview.interviewerId),
                    onEdit: _busy
                        ? null
                        : () => _edit(interview, companionship, state),
                    onDelete: _busy ? null : () => _confirmDelete(interview),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLeaders() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MinisteringLeadersScreen(callingId: widget.callingId),
      ),
    );
    ref.invalidate(ministeringModuleProvider(widget.callingId));
  }

  Future<void> _schedule(
    MinisteringCompanionship companionship,
    List<MinisteringLeader> leaders,
  ) async {
    final draft = await showDialog<_ScheduleDraft>(
      context: context,
      builder: (_) => _ScheduleDialog(
        title: 'Agendar entrevista',
        actionLabel: 'Agendar',
        leaders: leaders,
      ),
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .scheduleInterview(
            callingId: widget.callingId,
            companionshipId: companionship.id,
            scheduledAt: draft.scheduledAt,
            interviewerId: draft.interviewerId,
          ),
      'Entrevista agendada.',
    );
  }

  Future<void> _reschedule(
    MinisteringAppointment appointment,
    List<MinisteringLeader> leaders,
  ) async {
    final draft = await showDialog<_ScheduleDraft>(
      context: context,
      builder: (_) => _ScheduleDialog(
        title: 'Reagendar entrevista',
        actionLabel: 'Salvar',
        leaders: leaders,
        initialDateTime: appointment.scheduledAt.toLocal(),
        initialInterviewerId: appointment.interviewerId,
      ),
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .rescheduleInterview(
            callingId: widget.callingId,
            appointmentId: appointment.id,
            scheduledAt: draft.scheduledAt,
            interviewerId: draft.interviewerId,
          ),
      'Entrevista reagendada.',
    );
  }

  Future<void> _confirmCancel(MinisteringAppointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar agendamento?'),
        content: const Text(
          'O horário planejado é removido e a dupla volta para pendente. '
          'Entrevistas já registradas não são afetadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            key: const Key('confirm-cancel-appointment'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar agendamento'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .cancelAppointment(
            callingId: widget.callingId,
            appointmentId: appointment.id,
          ),
      'Agendamento cancelado.',
    );
  }

  Future<void> _complete(
    MinisteringAppointment appointment,
    MinisteringCompanionship companionship,
    MinisteringModuleState state,
  ) async {
    final draft = await showDialog<_InterviewDraft>(
      context: context,
      builder: (_) => _InterviewEditorDialog(
        title: 'Marcar realizada',
        actionLabel: 'Concluir',
        companionship: companionship,
        initialDate: DateTime.now(),
        initialParticipantIds: companionship.members
            .map((member) => member.id)
            .toSet(),
        fixedInterviewer: state.leaderById(appointment.interviewerId),
      ),
    );
    if (draft == null) return;

    await _runMutation(
      () => ref
          .read(ministeringRepositoryProvider)
          .completeAppointment(
            callingId: widget.callingId,
            appointmentId: appointment.id,
            completedOn: draft.completedOn,
            participantBrotherIds: draft.participantIds,
          ),
      'Entrevista registrada.',
    );
  }

  Future<void> _record(
    MinisteringCompanionship companionship,
    List<MinisteringLeader> leaders,
  ) async {
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
        interviewerChoices: leaders,
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
            interviewerId: draft.interviewerId,
          ),
      'Entrevista registrada.',
    );
  }

  Future<void> _edit(
    MinisteringInterview interview,
    MinisteringCompanionship companionship,
    MinisteringModuleState state,
  ) async {
    final currentMemberIds = companionship.members
        .map((member) => member.id)
        .toSet();
    // O entrevistador anterior entra na lista mesmo inativo, para poder ser
    // mantido sem exigir reativação.
    final current = state.leaderById(interview.interviewerId);
    final choices = <MinisteringLeader>[
      ...state.activeLeaders,
      if (current != null && !current.isActive) current,
    ];
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
        interviewerChoices: choices,
        initialInterviewerId: interview.interviewerId,
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
            interviewerId: draft.interviewerId,
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

/// Cartão da entrevista agendada, com as três ações do fluxo operacional.
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.interviewer,
    required this.onComplete,
    required this.onReschedule,
    required this.onCancel,
  });

  final MinisteringAppointment appointment;
  final MinisteringLeader? interviewer;
  final VoidCallback? onComplete;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = appointment.isOverdueAt(DateTime.now());

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconTile(
                icon: overdue
                    ? Icons.event_busy_outlined
                    : Icons.event_available_outlined,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrevista agendada',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      formatAppointmentMoment(context, appointment.scheduledAt),
                    ),
                    Text(
                      interviewer == null
                          ? 'Entrevistador não encontrado'
                          : '${interviewer!.displayLabel} · '
                                '${interviewer!.role.label}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (overdue) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'A data planejada já passou. Marque como realizada, reagende ou '
              'cancele.',
              style: TextStyle(color: scheme.error),
            ),
          ],
          if (interviewer != null && !interviewer!.isActive) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'O entrevistador está inativo. Reagende para escolher outro.',
              style: TextStyle(color: scheme.error),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              FilledButton.icon(
                key: const Key('complete-appointment-button'),
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar realizada'),
              ),
              OutlinedButton.icon(
                key: const Key('reschedule-appointment-button'),
                onPressed: onReschedule,
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Reagendar'),
              ),
              TextButton.icon(
                key: const Key('cancel-appointment-button'),
                onPressed: onCancel,
                icon: const Icon(Icons.event_busy_outlined),
                label: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quando não há agendamento: convida a agendar, ou aponta para a liderança se
/// ela ainda não existe (o entrevistador nunca é inferido).
class _ScheduleCallToAction extends StatelessWidget {
  const _ScheduleCallToAction({
    required this.hasLeaders,
    required this.onSchedule,
    required this.onOpenLeaders,
  });

  final bool hasLeaders;
  final VoidCallback? onSchedule;
  final VoidCallback onOpenLeaders;

  @override
  Widget build(BuildContext context) => AppSurface(
    gradient: AppGradients.soft(Theme.of(context).brightness),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sem entrevista agendada',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          hasLeaders
              ? 'Escolha a data, a hora e quem vai conduzir.'
              : 'Cadastre a liderança responsável antes de agendar — o '
                    'entrevistador é sempre escolhido, nunca suposto.',
        ),
        const SizedBox(height: Spacing.sm),
        if (hasLeaders)
          FilledButton.icon(
            key: const Key('schedule-interview-button'),
            onPressed: onSchedule,
            icon: const Icon(Icons.event_outlined),
            label: const Text('Agendar entrevista'),
          )
        else
          OutlinedButton.icon(
            key: const Key('open-leaders-from-interviews'),
            onPressed: onOpenLeaders,
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Cadastrar liderança'),
          ),
      ],
    ),
  );
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard({
    required this.interview,
    required this.companionship,
    required this.interviewer,
    required this.onEdit,
    required this.onDelete,
  });

  final MinisteringInterview interview;
  final MinisteringCompanionship companionship;
  final MinisteringLeader? interviewer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final participants = companionship.members
        .where((member) => interview.participantIds.contains(member.id))
        .map((member) => member.displayLabel)
        .join(' · ');
    final interviewerLine = interview.interviewerId == null
        ? 'Entrevistador não registrado'
        : interviewer == null
        ? 'Entrevistador removido'
        : 'Entrevistador: ${interviewer!.displayLabel}';

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
                interviewerLine,
                style: Theme.of(context).textTheme.bodySmall,
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

/// Agendamento escolhido no editor, antes de ir para o repositório.
class _ScheduleDraft {
  const _ScheduleDraft({
    required this.scheduledAt,
    required this.interviewerId,
  });

  final DateTime scheduledAt;
  final String interviewerId;
}

class _ScheduleDialog extends StatefulWidget {
  const _ScheduleDialog({
    required this.title,
    required this.actionLabel,
    required this.leaders,
    this.initialDateTime,
    this.initialInterviewerId,
  });

  final String title;
  final String actionLabel;
  final List<MinisteringLeader> leaders;
  final DateTime? initialDateTime;
  final String? initialInterviewerId;

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late DateTime _moment =
      widget.initialDateTime ?? DateTime.now().add(const Duration(days: 1));
  late String? _interviewerId =
      widget.initialInterviewerId ??
      (widget.leaders.length == 1 ? widget.leaders.single.id : null);

  bool get _isValid => _interviewerId != null;

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
              key: const Key('schedule-date-field'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Data'),
              subtitle: Text(localizations.formatFullDate(_moment)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickDate,
            ),
            ListTile(
              key: const Key('schedule-time-field'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Hora'),
              subtitle: Text(
                localizations.formatTimeOfDay(
                  TimeOfDay.fromDateTime(_moment),
                  alwaysUse24HourFormat: true,
                ),
              ),
              trailing: const Icon(Icons.more_time_outlined),
              onTap: _pickTime,
            ),
            const Divider(),
            DropdownButtonFormField<String>(
              key: const Key('schedule-interviewer-field'),
              initialValue: _interviewerId,
              decoration: const InputDecoration(labelText: 'Entrevistador'),
              items: widget.leaders
                  .map(
                    (leader) => DropdownMenuItem(
                      value: leader.id,
                      child: Text(
                        '${leader.displayLabel} · ${leader.role.label}',
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _interviewerId = value),
            ),
            const SizedBox(height: Spacing.xs),
            const MinisteringPrivacyNote(
              text:
                  'O entrevistador é sempre escolhido aqui. O secretário '
                  'organiza a agenda sem virar entrevistador.',
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
          key: const Key('schedule-confirm'),
          onPressed: _isValid ? _submit : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _moment.isBefore(today) ? today : _moment,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
      helpText: 'Data da entrevista',
    );
    if (picked == null) return;
    setState(() {
      _moment = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _moment.hour,
        _moment.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_moment),
      helpText: 'Hora da entrevista',
    );
    if (picked == null) return;
    setState(() {
      _moment = DateTime(
        _moment.year,
        _moment.month,
        _moment.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _submit() => Navigator.of(
    context,
  ).pop(_ScheduleDraft(scheduledAt: _moment, interviewerId: _interviewerId!));
}

/// Entrevista escolhida no editor, antes de ir para o repositório.
class _InterviewDraft {
  const _InterviewDraft({
    required this.completedOn,
    required this.participantIds,
    this.interviewerId,
  });

  final DateTime completedOn;
  final List<String> participantIds;
  final String? interviewerId;
}

class _InterviewEditorDialog extends StatefulWidget {
  const _InterviewEditorDialog({
    required this.title,
    required this.actionLabel,
    required this.companionship,
    required this.initialDate,
    required this.initialParticipantIds,
    this.interviewerChoices = const [],
    this.initialInterviewerId,
    this.fixedInterviewer,
  });

  final String title;
  final String actionLabel;
  final MinisteringCompanionship companionship;
  final DateTime initialDate;
  final Set<String> initialParticipantIds;

  /// Líderes que podem ser escolhidos. Vazio: sem seletor (só o caminho legado).
  final List<MinisteringLeader> interviewerChoices;
  final String? initialInterviewerId;

  /// Quando definido, o entrevistador vem do agendamento e não é editável.
  final MinisteringLeader? fixedInterviewer;

  @override
  State<_InterviewEditorDialog> createState() => _InterviewEditorDialogState();
}

class _InterviewEditorDialogState extends State<_InterviewEditorDialog> {
  late DateTime _date = widget.initialDate;
  late final Set<String> _participants = widget.initialParticipantIds.toSet();
  late String? _interviewerId = widget.initialInterviewerId;

  bool get _needsInterviewer =>
      widget.fixedInterviewer == null && widget.interviewerChoices.isNotEmpty;

  bool get _isValid =>
      _participants.isNotEmpty &&
      (!_needsInterviewer || _interviewerId != null);

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
            if (widget.fixedInterviewer != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Entrevistador'),
                subtitle: Text(
                  '${widget.fixedInterviewer!.displayLabel} · '
                  '${widget.fixedInterviewer!.role.label} (do agendamento)',
                ),
              )
            else if (widget.interviewerChoices.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              DropdownButtonFormField<String>(
                key: const Key('interview-interviewer-field'),
                initialValue: _interviewerId,
                decoration: const InputDecoration(labelText: 'Entrevistador'),
                items: widget.interviewerChoices
                    .map(
                      (leader) => DropdownMenuItem(
                        value: leader.id,
                        child: Text(
                          '${leader.displayLabel} · ${leader.role.label}'
                          '${leader.isActive ? '' : ' (inativo)'}',
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _interviewerId = value),
              ),
            ],
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
          onPressed: _isValid ? _submit : null,
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
      interviewerId: _needsInterviewer ? _interviewerId : null,
    ),
  );
}
