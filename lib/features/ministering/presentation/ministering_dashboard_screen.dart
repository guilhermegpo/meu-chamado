import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/errors/user_error_message.dart';
import 'package:meu_chamado/features/ministering/application/ministering_providers.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_companionships_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_interviews_screen.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_widgets.dart';

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
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  userErrorMessage(error),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
        Text(
          callingTitle,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.quarter.label, style: theme.textTheme.titleLarge),
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
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                key: const Key('quarter-progress'),
                value: summary.progress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary.pending == 0
                  ? 'Nada pendente por aqui.'
                  : '${summary.pending} dupla${summary.pending == 1 ? '' : 's'} '
                        'ainda sem entrevista neste trimestre.',
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
        leading: Icon(
          interviewed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: interviewed ? scheme.primary : scheme.outline,
        ),
        title: Text(companionship.title),
        subtitle: companionship.displayLabel == null ? null : Text(members),
        trailing: const Icon(Icons.chevron_right),
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comece por aqui',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasBrothers
                ? 'Os irmãos já estão cadastrados. Monte as duplas para '
                      'acompanhar as entrevistas do trimestre.'
                : 'Cadastre os irmãos ministradores e depois monte as duplas.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
    ),
  );
}
