import 'package:flutter/material.dart';
import 'package:meu_chamado/features/home/presentation/home_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({required this.dashboard, super.key});

  final WorkspaceDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppsMeuMark(size: 64),
                  const SizedBox(height: 24),
                  Text(
                    dashboard.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quem está usando o app?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  for (final user in dashboard.users)
                    Card(
                      child: ListTile(
                        key: Key('select-user-${user.id}'),
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          child: Text(_initials(user.name)),
                        ),
                        title: Text(user.name),
                        subtitle: Text(_roleLabel(user.role)),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => HomeScreen(
                              dashboard: dashboard,
                              currentUser: user,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.moderator => 'Moderador',
    UserRole.user => 'Usuário',
  };
}
