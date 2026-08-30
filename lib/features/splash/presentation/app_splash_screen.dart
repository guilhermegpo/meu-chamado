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
                            const AppsMeuMark(size: 112, shadow: true),
                            const SizedBox(height: Spacing.xl),
                            Text(
                              'MEU CHAMADO',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.2,
                                  ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              'ORGANIZE · SIRVA · FAÇA A DIFERENÇA',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.cyan400,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                            ),
                            const SizedBox(height: Spacing.xxl),
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: AppColors.cyan400,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
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
