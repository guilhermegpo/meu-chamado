import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/app/theme/theme_mode_controller.dart';
import 'package:meu_chamado/features/onboarding/presentation/onboarding_screen.dart';
import 'package:meu_chamado/features/splash/presentation/app_splash_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/presentation/user_selection_screen.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

class MeuChamadoApp extends ConsumerWidget {
  const MeuChamadoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref
        .watch(themeModeProvider)
        .when(
          data: (mode) => mode,
          loading: () => ThemeMode.system,
          error: (_, _) => ThemeMode.system,
        );

    return MaterialApp(
      title: 'Meu Chamado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(workspaceBootstrapProvider);

    return bootstrap.when(
      data: (dashboard) => dashboard == null
          ? OnboardingScreen(
              onSelectPhoto: () =>
                  ref.read(profilePhotoServiceProvider).chooseFromGallery(),
            )
          : UserSelectionScreen(dashboard: dashboard),
      loading: () => const AppSplashScreen(),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppsMeuMark(size: 64),
                  const SizedBox(height: 24),
                  Text(
                    'Não foi possível abrir seus dados locais.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tente novamente. Nenhuma informação foi enviada para a internet.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(workspaceBootstrapProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
