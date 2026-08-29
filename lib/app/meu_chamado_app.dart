import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/app/theme/theme_mode_controller.dart';
import 'package:meu_chamado/features/onboarding/presentation/onboarding_screen.dart';
import 'package:meu_chamado/features/splash/presentation/app_splash_screen.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/presentation/user_selection_screen.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

/// Único idioma da alpha.
///
/// Sem isto o seletor de data do Material aparece em inglês e no formato
/// mês/dia — errado para quem registra a data de uma entrevista aqui.
const appLocale = Locale('pt', 'BR');

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
      locale: appLocale,
      supportedLocales: const [appLocale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
