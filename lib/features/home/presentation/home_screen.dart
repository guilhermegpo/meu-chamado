import 'package:flutter/material.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.dashboard,
    required this.currentUser,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    final activeCallings = dashboard.callings
        .where((calling) => calling.status == CallingStatus.active)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Chamado'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Olá, ${currentUser.name}',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('Workspace local • ${dashboard.name}'),
          const SizedBox(height: 28),
          Text(
            'Meus chamados',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (activeCallings.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum chamado ativo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A fundação aceita zero, um ou vários chamados. Os módulos serão entregues de forma incremental.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            for (final calling in activeCallings)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in_outlined),
                  title: Text(calling.title),
                  subtitle: Text(calling.moduleKey),
                ),
              ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacidade por padrão',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este Workspace funciona offline. Sincronização e compartilhamento ainda não estão implementados.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
