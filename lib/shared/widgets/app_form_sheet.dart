import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Folha inferior para operações rápidas: agendar, reagendar, registrar,
/// corrigir, editar uma entidade.
///
/// Diálogos ficam para confirmações curtas e ações destrutivas. Uma folha dá
/// mais largura útil no celular, sobe do polegar e nunca impõe uma largura
/// fixa — o conteúdo rola, o teclado empurra as ações para cima e a barra de
/// ações fica sempre alcançável.
Future<T?> showAppFormSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  required List<Widget> actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => AppFormSheet(
      title: title,
      actions: actions,
      child: Builder(builder: builder),
    ),
  );
}

class AppFormSheet extends StatelessWidget {
  const AppFormSheet({
    required this.title,
    required this.child,
    required this.actions,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screenGutter,
                Spacing.xs,
                Spacing.screenGutter,
                Spacing.md,
              ),
              child: Text(title, style: theme.textTheme.titleLarge),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Spacing.screenGutter,
                  0,
                  Spacing.screenGutter,
                  Spacing.md,
                ),
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.screenGutter,
                Spacing.sm,
                Spacing.screenGutter,
                Spacing.md + viewInsets.bottom,
              ),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: Spacing.xs,
                overflowAlignment: OverflowBarAlignment.end,
                overflowSpacing: Spacing.xs,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
