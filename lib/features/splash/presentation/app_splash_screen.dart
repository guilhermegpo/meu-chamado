import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

/// A quiet, branded loading surface for app bootstrap work.
///
/// The widget deliberately owns no timer: callers should keep it visible only
/// while real startup work is running.
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({
    this.message = 'Preparando seu Workspace…',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy950,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.darkHero),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    label: 'Meu Chamado. $message',
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.xxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Entrada curta: a marca assenta enquanto o app
                            // abre os dados. Serve para a abertura não piscar,
                            // não para ser percebida como animação.
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Motion.slow,
                              curve: Motion.enter,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.94 + (0.06 * value),
                                  child: child,
                                ),
                              ),
                              child: const AppsMeuMark(size: 132, shadow: true),
                            ),
                            const SizedBox(height: Spacing.section),
                            Text(
                              'Meu Chamado',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            Text(
                              'Organize. Sirva. Faça a diferença.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                            ),
                            const SizedBox(height: Spacing.lg),
                            // Régua curta: fecha o bloco da marca e separa a
                            // identidade do estado de carregamento.
                            Container(
                              width: 48,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.cyan400,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: Spacing.xxxl),
                            // O carregamento fica subordinado à marca: na
                            // abertura o que importa é a identidade, e o
                            // indicador só explica por que a tela ainda espera.
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.cyan400,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                Flexible(
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.62,
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
