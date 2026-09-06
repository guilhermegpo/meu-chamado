import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/security/secure_window.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/security/presentation/locked_screen.dart';
import 'package:meu_chamado/features/security/presentation/security_setup_screen.dart';
import 'package:meu_chamado/features/splash/presentation/app_splash_screen.dart';

/// Fica entre a splash e o resto do app.
///
/// - sem PIN configurado → configuração;
/// - com PIN e trancado → tela de bloqueio;
/// - liberado → [child], mas só depois que o banco criptografado abriu.
///
/// Ver [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class SecurityGate extends ConsumerWidget {
  const SecurityGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider);

    ref.listen(appLockProvider, (_, next) {
      const SecureWindow().setSecure(
        secure: next.value != AppLockPhase.needsSetup,
      );
      // Ao trancar, fecha qualquer rota aberta (Configurações, diálogos,
      // subtelas) para a tela de bloqueio ficar à frente.
      if (next.value == AppLockPhase.locked) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return lock.when(
      loading: () => const AppSplashScreen(),
      error: (_, _) => const _DatabaseUnavailable(),
      data: (phase) => switch (phase) {
        AppLockPhase.needsSetup => const SecuritySetupScreen(),
        AppLockPhase.locked => const LockedScreen(),
        AppLockPhase.unlocked => child,
      },
    );
  }
}

class _DatabaseUnavailable extends ConsumerWidget {
  const _DatabaseUnavailable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Não foi possível abrir seus dados locais.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tente novamente. Nada foi enviado para a internet.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(appDatabaseProvider);
                    ref.invalidate(appLockProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
