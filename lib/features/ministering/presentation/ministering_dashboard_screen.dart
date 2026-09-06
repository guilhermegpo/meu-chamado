import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_companionships_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_interviews_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_leaders_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';
import 'package:meu_chamado/shared/widgets/app_skeleton.dart';
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
      appBar: AppBar(title: const Text('Ministração')),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(ministeringModuleProvider(callingId)),
        child: module.when(
          skipLoadingOnReload: true,
          loading: () => const _DashboardSkeleton(),
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
    final upcoming = state.appointments;
    final done = state.activeCompanionships
        .where((item) => state.isInterviewed(item.id))
        .toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenGutter,
        Spacing.md,
        Spacing.screenGutter,
        Spacing.xxxl,
      ),
      children: [
        _QuarterCard(eyebrow: callingTitle, summary: state.summary),
        const SizedBox(height: Spacing.section),
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
          MinisteringSectionTitle(
            label: 'Próximas entrevistas',
            count: upcoming.length,
          ),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const MinisteringEmptyState(
              icon: Icons.event_outlined,
              text: 'Nenhuma entrevista agendada.',
            )
          else
            for (final appointment in upcoming)
              _AppointmentRow(
                appointment: appointment,
                companionship: state.companionshipById(
                  appointment.companionshipId,
                ),
                interviewer: state.leaderById(appointment.interviewerId),
                onTap: () => _open(
                  context,
                  ref,
                  MinisteringInterviewsScreen(
                    callingId: callingId,
                    companionshipId: appointment.companionshipId,
                  ),
                ),
              ),
          const SizedBox(height: Spacing.section),
          MinisteringSectionTitle(label: 'Pendentes', count: pending.length),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            MinisteringEmptyState(
              icon: Icons.done_all,
              text: upcoming.isEmpty
                  ? 'Todas as duplas ativas já foram entrevistadas neste '
                        'trimestre.'
                  : 'Nada a agendar: as duplas restantes já foram '
                        'entrevistadas ou já têm entrevista marcada.',
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
          const SizedBox(height: Spacing.section),
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
        const SizedBox(height: Spacing.section),
        _ManageSection(
          onOpenCompanionships: () => _open(
            context,
            ref,
            MinisteringCompanionshipsScreen(callingId: callingId),
          ),
          onOpenBrothers: () => _open(
            context,
            ref,
            MinisteringBrothersScreen(callingId: callingId),
          ),
          onOpenLeaders: () => _open(
            context,
            ref,
            MinisteringLeadersScreen(callingId: callingId),
          ),
        ),
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
  const _QuarterCard({required this.eyebrow, required this.summary});

  final String eyebrow;
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
            Text(
              eyebrow,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.64),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
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
              duration: Motion.adaptive(context, Motion.slow),
              curve: Motion.enter,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: const Key('quarter-progress'),
                  value: value,
                  minHeight: 8,
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

/// Uma entrevista marcada, na seção "Próximas entrevistas".
class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.appointment,
    required this.companionship,
    required this.interviewer,
    required this.onTap,
  });

  final MinisteringAppointment appointment;
  final MinisteringCompanionship? companionship;
  final MinisteringLeader? interviewer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = appointment.isOverdueAt(DateTime.now());
    final interviewerLabel = interviewer == null
        ? 'Entrevistador não encontrado'
        : 'com ${interviewer!.displayLabel}';

    return Card(
      child: ListTile(
        key: Key('dashboard-appointment-${appointment.id}'),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        isThreeLine: true,
        leading: AppIconTile(
          icon: overdue ? Icons.event_busy_outlined : Icons.event_outlined,
          size: 44,
        ),
        title: Text(companionship?.title ?? 'Dupla removida'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: Spacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatAppointmentMoment(context, appointment.scheduledAt)),
              Text(
                overdue ? '$interviewerLabel · atrasada' : interviewerLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: overdue ? scheme.error : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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

/// Ferramentas de cadastro, agrupadas depois do estado do trimestre: são o
/// "onde eu configuro", que vem depois do "o que falta".
class _ManageSection extends StatelessWidget {
  const _ManageSection({
    required this.onOpenCompanionships,
    required this.onOpenBrothers,
    required this.onOpenLeaders,
  });

  final VoidCallback onOpenCompanionships;
  final VoidCallback onOpenBrothers;
  final VoidCallback onOpenLeaders;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(title: 'Gerenciar'),
      const SizedBox(height: Spacing.sm),
      AppSurface(
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              _ManageTile(
                itemKey: const Key('open-companionships-button'),
                icon: Icons.people_outline,
                label: 'Duplas',
                onTap: onOpenCompanionships,
              ),
              const Divider(height: 1),
              _ManageTile(
                itemKey: const Key('open-brothers-from-dashboard'),
                icon: Icons.group_outlined,
                label: 'Irmãos ministradores',
                onTap: onOpenBrothers,
              ),
              const Divider(height: 1),
              _ManageTile(
                itemKey: const Key('open-leaders-from-dashboard'),
                icon: Icons.badge_outlined,
                label: 'Liderança',
                onTap: onOpenLeaders,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ManageTile extends StatelessWidget {
  const _ManageTile({
    required this.itemKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key itemKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    key: itemKey,
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

/// Esqueleto do painel enquanto a leitura do módulo não chega.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      Spacing.screenGutter,
      Spacing.md,
      Spacing.screenGutter,
      Spacing.xxxl,
    ),
    children: const [
      AppSkeletonBox(height: 148, radius: Radii.surface),
      SizedBox(height: Spacing.section),
      AppSkeletonBox(height: 22, width: 180),
      SizedBox(height: Spacing.sm),
      AppSkeletonList(rows: 2),
      SizedBox(height: Spacing.section),
      AppSkeletonBox(height: 22, width: 140),
      SizedBox(height: Spacing.sm),
      AppSkeletonList(rows: 3),
    ],
  );
}
