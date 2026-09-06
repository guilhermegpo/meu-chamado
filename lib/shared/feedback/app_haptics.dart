import 'package:flutter/services.dart';

/// Camada semântica de retorno tátil.
///
/// As telas chamam a intenção ("salvou", "concluiu a entrevista"), nunca o
/// primitivo do sistema. Assim o vocabulário fica consistente e um ajuste de
/// intensidade acontece num lugar só. Todo toque é discreto de propósito: o
/// háptico confirma uma ação, não decora a interface.
abstract final class AppHaptics {
  /// Trocar de aba ou mover uma seleção entre opções.
  static void selection() => HapticFeedback.selectionClick();

  /// Alternar um valor (switch, checkbox, chip).
  static void toggle() => HapticFeedback.selectionClick();

  /// Uma gravação simples deu certo (salvar cadastro, editar identificação).
  static void saved() => HapticFeedback.lightImpact();

  /// Um marco do fluxo se completou (entrevista registrada ou concluída).
  static void milestone() => HapticFeedback.mediumImpact();

  /// Uma ação destrutiva foi confirmada e executada.
  static void destructive() => HapticFeedback.mediumImpact();

  /// Entrada rejeitada (PIN incorreto, validação que barra o envio).
  static void warning() => HapticFeedback.vibrate();
}
