import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

void main() {
  final themes = {'claro': AppTheme.light, 'escuro': AppTheme.dark};

  /// Tamanho mínimo do estilo no estado padrão.
  Size? minimumSize(ButtonStyle? style) =>
      style?.minimumSize?.resolve(const <WidgetState>{});

  group('tamanho dos botões', () {
    for (final entry in themes.entries) {
      test('nenhum botão do tema ${entry.key} pede largura infinita', () {
        final theme = entry.value;
        final styles = <String, ButtonStyle?>{
          'filled': theme.filledButtonTheme.style,
          'outlined': theme.outlinedButtonTheme.style,
          'text': theme.textButtonTheme.style,
        };

        for (final style in styles.entries) {
          final size = minimumSize(style.value);
          expect(size, isNotNull, reason: style.key);
          // `Size.fromHeight(h)` é `Size(double.infinity, h)`. No tema, isso
          // estica todo botão do app e empilha as ações dos diálogos — foi
          // exatamente o defeito que esta asserção existe para impedir.
          expect(
            size!.width,
            TouchTarget.minimumWidth,
            reason:
                'o botão ${style.key} do tema ${entry.key} não deve impor '
                'largura; largura cheia é decisão da composição',
          );
        }
      });

      test('a altura mínima respeita o alvo de toque no tema ${entry.key}', () {
        final theme = entry.value;
        expect(
          minimumSize(theme.filledButtonTheme.style)!.height,
          greaterThanOrEqualTo(TouchTarget.minimum),
        );
        expect(
          minimumSize(theme.textButtonTheme.style)!.height,
          greaterThanOrEqualTo(TouchTarget.minimum),
        );
      });
    }
  });

  group('superfícies', () {
    for (final entry in themes.entries) {
      test('o tema ${entry.key} declara os degraus de superfície', () {
        final scheme = entry.value.colorScheme;
        final levels = <Color>[
          scheme.surface,
          scheme.surfaceContainerLow,
          scheme.surfaceContainer,
          scheme.surfaceContainerHigh,
          scheme.surfaceContainerHighest,
        ];
        // Distintos entre si: sem isso, card e fundo se confundem e a tela
        // perde a hierarquia que a borda sozinha não sustenta.
        expect(levels.toSet(), hasLength(levels.length));
      });
    }

    test('claro e escuro não compartilham superfície nem primária', () {
      expect(
        AppTheme.light.colorScheme.surface,
        isNot(AppTheme.dark.colorScheme.surface),
      );
      expect(
        AppTheme.light.colorScheme.primary,
        isNot(AppTheme.dark.colorScheme.primary),
      );
    });
  });

  group('contraste', () {
    /// Razão de contraste WCAG entre duas cores opacas.
    double ratio(Color foreground, Color background) {
      double channel(double value) => value <= 0.03928
          ? value / 12.92
          : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
      double luminance(Color color) =>
          0.2126 * channel(color.r) +
          0.7152 * channel(color.g) +
          0.0722 * channel(color.b);

      final a = luminance(foreground) + 0.05;
      final b = luminance(background) + 0.05;
      return a > b ? a / b : b / a;
    }

    for (final entry in themes.entries) {
      test('o texto do tema ${entry.key} passa em AA', () {
        final scheme = entry.value.colorScheme;
        final pairs = <String, (Color, Color)>{
          'onSurface sobre surface': (scheme.onSurface, scheme.surface),
          'onSurface sobre card': (
            scheme.onSurface,
            scheme.surfaceContainerLow,
          ),
          'onPrimary sobre primary': (scheme.onPrimary, scheme.primary),
          'onSecondaryContainer sobre secondaryContainer': (
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          'onError sobre error': (scheme.onError, scheme.error),
        };

        for (final pair in pairs.entries) {
          expect(
            ratio(pair.value.$1, pair.value.$2),
            greaterThanOrEqualTo(4.5),
            reason: '${pair.key} (${entry.key})',
          );
        }
      });
    }
  });
}
