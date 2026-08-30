import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_companionships_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_interviews_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Painel do trimestre corrente.
///
/// A pergunta que o secretário faz é "quais duplas ainda faltam?", então é
/// isso que a tela abre respondendo — as pendentes primeiro, as entrevistadas
/// depois.
class MinisteringDashboardScreen extends ConsumerWidget {
  const MinisteringDashboardScreen({
    required this.callingId,
    required this.callingTitle,
    super.key,
  });

  final String callingId;
  final String callingTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref.watch(ministeringModuleProvider(callingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ministração'),
        actions: [
          IconButton(
            key: const Key('open-companionships-button'),
            tooltip: 'Duplas',
            onPressed: () => _open(
              context,
              ref,
              MinisteringCompanionshipsScreen(callingId: callingId),
            ),
            icon: const Icon(Icons.people_outline),
          ),
          IconButton(
            key: const Key('open-brothers-from-dashboard'),
            tooltip: 'Irmãos ministradores',
            onPressed: () => _open(
              context,
              ref,
              MinisteringBrothersScreen(callingId: callingId),
            ),
            icon: const Icon(Icons.group_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(ministeringModuleProvider(callingId)),
        child: module.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => MinisteringErrorState(
            message: userErrorMessage(error),
            onRetry: () => ref.invalidate(ministeringModuleProvider(callingId)),
          ),
          data: (state) => _buildBody(context, ref, state),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MinisteringModuleState state,
  ) {
    final pending = state.pendingCompanionships;
    final done = state.activeCompanionships
        .where((item) => state.isInterviewed(item.id))
        .toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        AppSurface(
          gradient: AppGradients.soft(Theme.of(context).brightness),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIconTile(icon: Icons.volunteer_activism_outlined),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel trimestral',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      callingTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: Spacing.xs),
                    const Text(
                      'Acompanhe o que falta e registre somente o trabalho '
                      'administrativo necessário.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        _QuarterCard(summary: state.summary),
        const SizedBox(height: 24),
        if (state.activeCompanionships.isEmpty)
          _StartHere(
            hasBrothers: state.activeBrothers.length >= 2,
            onOpenBrothers: () => _open(
              context,
              ref,
              MinisteringBrothersScreen(callingId: callingId),
            ),
            onOpenCompanionships: () => _open(
              context,
              ref,
              MinisteringCompanionshipsScreen(callingId: callingId),
            ),
          )
        else ...[
          MinisteringSectionTitle(label: 'Pendentes', count: pending.length),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const MinisteringEmptyState(
              icon: Icons.done_all,
              text:
                  'Todas as duplas ativas já foram entrevistadas neste '
                  'trimestre.',
            )
          else
            for (final companionship in pending)
              _CompanionshipRow(
                companionship: companionship,
                interviewed: false,
                onTap: () => _open(
                  context,
                  ref,
                  MinisteringInterviewsScreen(
                    callingId: callingId,
                    companionshipId: companionship.id,
                  ),
                ),
              ),
          const SizedBox(height: 24),
          MinisteringSectionTitle(label: 'Entrevistadas', count: done.length),
          const SizedBox(height: 8),
          if (done.isEmpty)
            const MinisteringEmptyState(
              icon: Icons.event_available_outlined,
              text: 'Nenhuma entrevista registrada neste trimestre.',
            )
          else
            for (final companionship in done)
              _CompanionshipRow(
                companionship: companionship,
                interviewed: true,
                onTap: () => _open(
                  context,
                  ref,
                  MinisteringInterviewsScreen(
                    callingId: callingId,
                    companionshipId: companionship.id,
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Widget screen) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => screen));
    ref.invalidate(ministeringModuleProvider(callingId));
  }
}

class _QuarterCard extends StatelessWidget {
  const _QuarterCard({required this.summary});

  final QuarterSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.activeCompanionships;

    return AppSurface(
      gradient: AppGradients.darkHero,
      border: const Border(),
      shadow: true,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.cyan400,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    summary.quarter.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // A contagem vem antes da barra e a barra não carrega percentual:
            // o número mede o trabalho administrativo do secretário, não o
            // desempenho espiritual de ninguém.
            Text(
              total == 0
                  ? 'Nenhuma dupla ativa'
                  // A concordância segue o total, não o numerador: são as
                  // duplas do trimestre que estão sendo contadas.
                  : '${summary.interviewedCompanionships} de $total '
                        'dupla${total == 1 ? '' : 's'} '
                        'entrevistada${total == 1 ? '' : 's'}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(end: summary.progress),
              duration: Motion.slow,
              curve: Motion.enter,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: const Key('quarter-progress'),
                  value: value,
                  minHeight: 10,
                  color: AppColors.cyan400,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary.pending == 0
                  ? 'Nada pendente por aqui.'
                  : '${summary.pending} dupla${summary.pending == 1 ? '' : 's'} '
                        'ainda sem entrevista neste trimestre.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionshipRow extends StatelessWidget {
  const _CompanionshipRow({
    required this.companionship,
    required this.interviewed,
    required this.onTap,
  });

  final MinisteringCompanionship companionship;
  final bool interviewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final members = companionship.members
        .map((member) => member.displayLabel)
        .join(' · ');

    return Card(
      child: ListTile(
        key: Key('dashboard-companionship-${companionship.id}'),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: AppIconTile(
          icon: interviewed
              ? Icons.check_circle_outline
              : Icons.schedule_outlined,
          size: 44,
        ),
        title: Text(companionship.title),
        subtitle: companionship.displayLabel == null ? null : Text(members),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Primeiro uso: diz qual é o próximo passo em vez de mostrar uma lista vazia.
class _StartHere extends StatelessWidget {
  const _StartHere({
    required this.hasBrothers,
    required this.onOpenBrothers,
    required this.onOpenCompanionships,
  });

  final bool hasBrothers;
  final VoidCallback onOpenBrothers;
  final VoidCallback onOpenCompanionships;

  @override
  Widget build(BuildContext context) => AppSurface(
    gradient: AppGradients.soft(Theme.of(context).brightness),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppIconTile(icon: Icons.route_outlined, size: 48),
        const SizedBox(height: Spacing.md),
        Text('Comece por aqui', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          hasBrothers
              ? 'Os irmãos já estão cadastrados. Monte as duplas para '
                    'acompanhar as entrevistas do trimestre.'
              : 'Cadastre os irmãos ministradores e depois monte as duplas.',
        ),
        const SizedBox(height: Spacing.md),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            OutlinedButton.icon(
              key: const Key('start-brothers-button'),
              onPressed: onOpenBrothers,
              icon: const Icon(Icons.group_outlined),
              label: const Text('Irmãos'),
            ),
            FilledButton.icon(
              key: const Key('start-companionships-button'),
              onPressed: hasBrothers ? onOpenCompanionships : null,
              icon: const Icon(Icons.people_outline),
              label: const Text('Duplas'),
            ),
          ],
        ),
      ],
    ),
  );
}
