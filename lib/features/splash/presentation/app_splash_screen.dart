import 'package:flutter/material.dart';
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

  static const _navy = Color(0xFF0B2239);
  static const _teal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    final markTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme
          .copyWith(primary: _navy, secondary: _teal),
    );

    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Center(
          child: Semantics(
            container: true,
            liveRegion: true,
            label: 'Meu Chamado. $message',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Theme(data: markTheme, child: const AppsMeuMark(size: 88)),
                    const SizedBox(height: 24),
                    Text(
                      'MEU CHAMADO',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: _teal,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
