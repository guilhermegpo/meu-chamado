import 'package:flutter/widgets.dart';

/// Paleta proprietária da família Apps Meu.
abstract final class AppColors {
  static const navy950 = Color(0xFF04111F);
  static const navy900 = Color(0xFF071B30);
  static const navy800 = Color(0xFF0B2947);
  static const teal600 = Color(0xFF078F8A);
  static const teal500 = Color(0xFF0EB7AC);
  static const cyan400 = Color(0xFF31D6CF);
  static const blue600 = Color(0xFF1267D5);
  static const blue500 = Color(0xFF1687F8);
  static const offWhite = Color(0xFFF6F8FB);
  static const charcoal = Color(0xFF0D1620);
}

abstract final class AppGradients {
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.teal500, AppColors.blue600],
  );

  static const darkHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navy800, AppColors.navy950],
  );

  static LinearGradient soft(Brightness brightness) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brightness == Brightness.light
        ? const [Color(0xFFE9FAF8), Color(0xFFEAF2FF)]
        : const [Color(0xFF102D3B), Color(0xFF10233E)],
  );
}

abstract final class AppShadows {
  static List<BoxShadow> soft(Brightness brightness) => [
    BoxShadow(
      color: const Color(0xFF001326)
          .withValues(alpha: brightness == Brightness.light ? 0.09 : 0.28),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

/// Escala de espaçamento do app.
///
/// Um passo de 4 cobre tudo que as telas precisam. Sem isto, cada tela escolhe
/// o próprio número e a densidade varia sem motivo de uma para a outra.
abstract final class Spacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const section = 28.0;

  /// Margem lateral padrão das telas.
  static const screenInset = EdgeInsets.symmetric(horizontal: md);

  /// Espaço extra no fim de listas com botão flutuante, para o último item não
  /// ficar embaixo dele.
  static const fabClearance = 104.0;
}

/// Raios de canto. Três degraus bastam: controle, superfície e destaque.
abstract final class Radii {
  static const compact = Radius.circular(10);
  static const control = Radius.circular(14);
  static const surface = Radius.circular(20);
  static const emphasis = Radius.circular(28);

  static const compactBorder = BorderRadius.all(compact);
  static const controlBorder = BorderRadius.all(control);
  static const surfaceBorder = BorderRadius.all(surface);
  static const emphasisBorder = BorderRadius.all(emphasis);
}

/// Durações de movimento.
///
/// Curtas de propósito: a animação existe para explicar o que mudou, não para
/// ser percebida como animação.
abstract final class Motion {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 340);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
}

/// Altura mínima de alvos de toque.
///
/// 48 é o mínimo recomendado pelo Material; os controles primários usam 52
/// porque são tocados com o polegar, muitas vezes com uma mão só.
abstract final class TouchTarget {
  static const minimum = 48.0;
  static const primary = 52.0;

  /// Largura mínima de um botão. O padrão do Material, mantido explícito
  /// porque foi justamente isto que uma vez virou `double.infinity` por
  /// engano e espalhou botões de largura cheia por diálogos.
  static const minimumWidth = 64.0;
}
