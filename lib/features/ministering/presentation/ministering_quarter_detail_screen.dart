import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_interviews_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Detalhe de um trimestre do histórico: as duplas do escopo, separadas entre
/// entrevistadas e pendentes.
///
/// Para um trimestre encerrado o escopo vem do snapshot congelado; para o
/// corrente, do estado atual das duplas ativas. Tocar numa dupla abre o
/// histórico de entrevistas dela — é ali que uma entrevista omitida é
/// registrada ou uma data errada é corrigida, e o numerador deste trimestre
/// recalcula na volta.
class MinisteringQuarterDetailScreen extends ConsumerWidget {
  const MinisteringQuarterDetailScreen({
    required this.callingId,
    required this.callingTitle,
    required this.quarter,
    super.key,
  });

  final String callingId;
  final String callingTitle;
  final Quarter quarter;

  MinisteringQuarterDetailQuery get _query =>
      (callingId: callingId, quarter: quarter);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(ministeringQuarterDetailProvider(_query));

    return Scaffold(
      appBar: AppBar(title: Text(quarter.label)),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(ministeringQuarterDetailProvider(_query)),
        child: detail.when(
          skipLoadingOnReload: true,
          loading: () => const MinisteringListSkeleton(),
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () =>
                ref.invalidate(ministeringQuarterDetailProvider(_query)),
          ),
          data: (data) =>
              data == null ? _missing(context) : _buildBody(context, ref, data),
        ),
      ),
    );
  }

  Widget _missing(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      Spacing.screenGutter,
      Spacing.md,
      Spacing.screenGutter,
      Spacing.xxxl,
    ),
    children: const [
      AppEmptyState(
        icon: Icons.history_toggle_off_outlined,
        title: 'Este trimestre não tem histórico',
        message:
            'Nenhuma dupla e nenhuma entrevista neste trimestre — não houve '
            'escopo para congelar.',
      ),
    ],
  );

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MinisteringQuarterDetail data,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenGutter,
        Spacing.md,
        Spacing.screenGutter,
        Spacing.xxxl,
      ),
      children: [
        _SummaryCard(eyebrow: callingTitle, summary: data.summary),
        const SizedBox(height: Spacing.section),
        MinisteringSectionTitle(
          label: 'Entrevistadas',
          count: data.interviewed.length,
        ),
        const SizedBox(height: Spacing.xs),
        if (data.interviewed.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.event_note_outlined,
            text: 'Nenhuma entrevista registrada neste trimestre.',
          )
        else
          for (final item in data.interviewed) ...[
            _CompanionshipRow(
              item: item,
              onTap: () => _openInterviews(context, ref, item),
            ),
            const SizedBox(height: Spacing.xs),
          ],
        const SizedBox(height: Spacing.section),
        MinisteringSectionTitle(label: 'Pendentes', count: data.pending.length),
        const SizedBox(height: Spacing.xs),
        if (data.pending.isEmpty)
          const MinisteringEmptyState(
            icon: Icons.done_all,
            text: 'Todas as duplas do escopo foram entrevistadas.',
          )
        else
          for (final item in data.pending) ...[
            _CompanionshipRow(
              item: item,
              onTap: () => _openInterviews(context, ref, item),
            ),
            const SizedBox(height: Spacing.xs),
          ],
      ],
    );
  }

  Future<void> _openInterviews(
    BuildContext context,
    WidgetRef ref,
    MinisteringQuarterCompanionshipDetail item,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MinisteringInterviewsScreen(
          callingId: callingId,
          companionshipId: item.companionshipId,
        ),
      ),
    );
    ref
      ..invalidate(ministeringQuarterDetailProvider(_query))
      ..invalidate(ministeringQuarterHistoryProvider(callingId));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.eyebrow, required this.summary});

  final String eyebrow;
  final MinisteringHistoricalQuarter summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.eligible;

    return AppSurface(
      gradient: AppGradients.darkHero,
      border: const Border(),
      shadow: true,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.64),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              summary.quarter.monthsLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            if (summary.inProgress) ...[
              const SizedBox(height: Spacing.sm),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppStatusPill(
                  label: 'Em andamento',
                  icon: Icons.hourglass_bottom_outlined,
                ),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            Text(
              total == 0
                  ? 'Nenhuma dupla no escopo'
                  : '${summary.interviewed} de $total '
                        'dupla${total == 1 ? '' : 's'} '
                        'entrevistada${total == 1 ? '' : 's'}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: const Key('quarter-detail-progress'),
                  value: summary.progress,
                  minHeight: 8,
                  color: AppColors.cyan400,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                summary.pending == 0
                    ? summary.inProgress
                          ? 'Nada pendente por aqui.'
                          : 'Nada ficou pendente.'
                    : '${summary.pending} dupla${summary.pending == 1 ? '' : 's'} '
                          'sem entrevista neste trimestre.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompanionshipRow extends StatelessWidget {
  const _CompanionshipRow({required this.item, required this.onTap});

  final MinisteringQuarterCompanionshipDetail item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final members = item.members
        .map((member) => member.displayLabel)
        .join(' · ');
    final subtitleLines = <String>[
      if (members.isNotEmpty && members != item.title) members,
      if (item.interviewed && item.lastInterviewAt != null)
        item.interviewCount > 1
            ? '${item.interviewCount} entrevistas · última em '
                  '${_formatDate(context, item.lastInterviewAt!)}'
            : 'Entrevistada em ${_formatDate(context, item.lastInterviewAt!)}',
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: Key('quarter-companionship-${item.companionshipId}'),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: AppIconTile(
          icon: item.interviewed
              ? Icons.check_circle_outline
              : Icons.schedule_outlined,
          size: 44,
        ),
        title: Text(item.title),
        subtitle: subtitleLines.isEmpty ? null : Text(subtitleLines.join('\n')),
        isThreeLine: subtitleLines.length > 1,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context)
          .formatMediumDate(displayCalendarDate(value));
}
