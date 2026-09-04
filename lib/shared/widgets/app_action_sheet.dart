import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Uma ação de um menu contextual: rótulo, ícone e o que fazer.
class AppAction {
  const AppAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final bool destructive;
  final bool enabled;
}

/// Folha de ações contextuais de uma entidade (irmão, dupla, liderança).
///
/// Substitui o menu de três pontos: no celular a folha dá alvos de toque
/// maiores e um título que diz sobre o que são as ações. A folha fecha antes
/// de disparar a ação, para diálogos e outras folhas subirem limpos.
Future<void> showAppActionSheet({
  required BuildContext context,
  required String title,
  required List<AppAction> actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screenGutter,
                Spacing.xs,
                Spacing.screenGutter,
                Spacing.xs,
              ),
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final action in actions)
              ListTile(
                enabled: action.enabled,
                leading: Icon(
                  action.icon,
                  color: action.destructive ? scheme.error : null,
                ),
                title: Text(
                  action.label,
                  style: action.destructive
                      ? TextStyle(color: scheme.error)
                      : null,
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  action.onSelected();
                },
              ),
            const SizedBox(height: Spacing.xs),
          ],
        ),
      );
    },
  );
}
