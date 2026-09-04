import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Bloco de carregamento com a forma do conteúdo que vai chegar.
///
/// Um esqueleto contextual explica o que está sendo carregado melhor que um
/// giro central. A pulsação é lenta e some quando a pessoa pediu para reduzir
/// movimento — nesse caso fica um bloco estático, que ainda comunica "aguarde".
class AppSkeletonBox extends StatefulWidget {
  const AppSkeletonBox({
    this.width = double.infinity,
    this.height = 16,
    this.radius = Radii.compact,
    super.key,
  });

  final double width;
  final double height;
  final Radius radius;

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final base = scheme.surfaceContainerHigh;

    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.all(widget.radius),
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );

    if (reduceMotion) {
      return ExcludeSemantics(child: box);
    }

    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 0.9).animate(_controller),
        child: box,
      ),
    );
  }
}

/// Lista vertical de linhas de esqueleto, para telas de lista.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({this.rows = 3, this.rowHeight = 76, super.key});

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando',
    liveRegion: true,
    child: Column(
      children: [
        for (var i = 0; i < rows; i++) ...[
          AppSkeletonBox(height: rowHeight, radius: Radii.surface),
          if (i != rows - 1) const SizedBox(height: Spacing.sm),
        ],
      ],
    ),
  );
}
