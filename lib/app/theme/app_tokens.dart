import 'package:flutter/widgets.dart';

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

  /// Margem lateral padrão das telas.
  static const screenInset = EdgeInsets.symmetric(horizontal: md);

  /// Espaço extra no fim de listas com botão flutuante, para o último item não
  /// ficar embaixo dele.
  static const fabClearance = 104.0;
}

/// Raios de canto. Três degraus bastam: controle, superfície e destaque.
abstract final class Radii {
  static const control = Radius.circular(14);
  static const surface = Radius.circular(20);
  static const emphasis = Radius.circular(28);

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
