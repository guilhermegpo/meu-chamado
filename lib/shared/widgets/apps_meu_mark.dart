import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Marca raster oficial do projeto, derivada da variação escolhida no refresh.
class AppsMeuMark extends StatelessWidget {
  const AppsMeuMark({this.size = 56, this.shadow = false, super.key});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Apps Meu',
      image: true,
      child: ExcludeSemantics(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: shadow
                  ? AppShadows.soft(Theme.of(context).brightness)
                  : null,
            ),
            child: SizedBox.square(
              dimension: size,
              child: Image.asset(
                'assets/branding/meu_chamado_icon_master.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
