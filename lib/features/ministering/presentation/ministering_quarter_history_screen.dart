import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_quarter_detail_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Histórico dos trimestres do chamado.
///
/// O denominador de um trimestre encerrado não se move: ele vem do escopo
/// congelado no snapshot, não do estado atual das duplas. Corrigir uma
/// entrevista antiga ainda recalcula o numerador — o histórico registra o
/// trabalho, não o congela. Ver
/// [ADR 0017](../../../docs/adr/0017-ministering-quarter-snapshots.md).
class MinisteringQuarterHistoryScreen extends ConsumerWidget {
  const MinisteringQuarterHistoryScreen({
    required this.callingId,
    required this.callingTitle,
    super.key,
  });

  final String callingId;
  final String callingTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(ministeringQuarterHistoryProvider(callingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(ministeringQuarterHistoryProvider(callingId)),
        child: history.when(
          skipLoadingOnReload: true,
          loading: () => const MinisteringListSkeleton(),
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () =>
                ref.invalidate(ministeringQuarterHistoryProvider(callingId)),
          ),
          data: (quarters) => _buildBody(context, ref, quarters),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MinisteringHistoricalQuarter> quarters,
  ) {
    final frozen = quarters.where((q) => !q.inProgress).toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenGutter,
        Spacing.md,
        Spacing.screenGutter,
        Spacing.xxxl,
      ),
      children: [
        for (final section in _groupByYear(quarters)) ...[
          AppSectionHeader(title: '${section.year}'),
          const SizedBox(height: Spacing.sm),
          for (final quarter in section.quarters) ...[
            _QuarterCard(
              quarter: quarter,
              onTap: () => _openDetail(context, ref, quarter.quarter),
            ),
            const SizedBox(height: Spacing.xs),
          ],
          const SizedBox(height: Spacing.section),
        ],
        if (frozen.isEmpty)
          const AppEmptyState(
            icon: Icons.history_toggle_off_outlined,
            title: 'Ainda não há trimestres encerrados',
            message:
                'Quando o trimestre atual terminar, ele é congelado aqui com '
                'as duplas que faziam parte do escopo. O que já foi '
                'registrado continua podendo ser corrigido.',
          ),
      ],
    );
  }

  List<({int year, List<MinisteringHistoricalQuarter> quarters})> _groupByYear(
    List<MinisteringHistoricalQuarter> quarters,
  ) {
    final sections =
        <({int year, List<MinisteringHistoricalQuarter> quarters})>[];
    for (final quarter in quarters) {
      if (sections.isEmpty || sections.last.year != quarter.quarter.year) {
        sections.add((year: quarter.quarter.year, quarters: []));
      }
      sections.last.quarters.add(quarter);
    }
    return sections;
  }

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    Quarter quarter,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MinisteringQuarterDetailScreen(
          callingId: callingId,
          callingTitle: callingTitle,
          quarter: quarter,
        ),
      ),
    );
    // Uma correção feita no detalhe muda o numerador desta lista.
    ref.invalidate(ministeringQuarterHistoryProvider(callingId));
  }
}

class _QuarterCard extends StatelessWidget {
  const _QuarterCard({required this.quarter, required this.onTap});

  final MinisteringHistoricalQuarter quarter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = quarter.eligible;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        key: Key(
          'history-quarter-${quarter.quarter.year}-'
          '${quarter.quarter.number}',
        ),
        borderRadius: Radii.surfaceBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${quarter.quarter.number}º trimestre',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          quarter.quarter.monthsLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (quarter.inProgress) ...[
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
                    : '${quarter.interviewed} de $total '
                          'dupla${total == 1 ? '' : 's'} '
                          'entrevistada${total == 1 ? '' : 's'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (total > 0) ...[
                const SizedBox(height: Spacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    key: Key(
                      'history-progress-${quarter.quarter.year}-'
                      '${quarter.quarter.number}',
                    ),
                    value: quarter.progress,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  quarter.pending == 0
                      ? 'Nada ficou pendente.'
                      : '${quarter.pending} '
                            'dupla${quarter.pending == 1 ? '' : 's'} '
                            'sem entrevista neste trimestre.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
