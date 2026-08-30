import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/app/shell/app_shell.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({required this.dashboard, super.key});

  final WorkspaceDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSurface(
                    gradient: AppGradients.darkHero,
                    border: const Border(),
                    shadow: true,
                    child: Column(
                      children: [
                        const AppBrandLockup(onDark: true),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          dashboard.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          'Quem está usando o Meu Chamado?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.section),
                  AppSectionHeader(
                    title: 'Escolha seu perfil',
                    count: dashboard.users.length,
                  ),
                  const SizedBox(height: Spacing.sm),
                  for (final user in dashboard.users)
                    Card(
                      child: ListTile(
                        key: Key('select-user-${user.id}'),
                        contentPadding: const EdgeInsets.all(Spacing.sm),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            gradient: AppGradients.brand,
                            shape: BoxShape.circle,
                          ),
                          child: ProfileAvatar(
                            name: user.name,
                            photoPath: user.photoPath,
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(_roleLabel(user.role)),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AppShell(
                              dashboard: dashboard,
                              currentUser: user,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: Spacing.md),
                  AppSurface(
                    padding: const EdgeInsets.all(Spacing.sm),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Nesta versão local, a seleção de perfil não '
                            'substitui autenticação individual.',
                          ),
                        ),
                      ],
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

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.moderator => 'Moderador',
    UserRole.user => 'Usuário',
  };
}
