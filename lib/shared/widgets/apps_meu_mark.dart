import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Marca raster oficial do projeto, derivada da variação escolhida no refresh.
class AppsMeuMark extends StatelessWidget {
  const AppsMeuMark({this.size = 56, this.shadow = false, super.key});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    // O mestre tem mais de mil pixels de lado; sem isto ele seria decodificado
    // inteiro na memória para desenhar poucas dezenas de pontos na tela.
    final decodeSide = math.max(1, (size * devicePixelRatio).ceil());

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
                filterQuality: FilterQuality.medium,
                cacheWidth: decodeSide,
                cacheHeight: decodeSide,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
