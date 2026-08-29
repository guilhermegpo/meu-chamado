import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Tema do app, montado a partir de uma paleta própria.
///
/// Claro e escuro são construídos pelo mesmo caminho, com as superfícies
/// declaradas explicitamente nos dois. Escuro não é o claro invertido: o navy
/// que serve de tinta no claro não teria contraste sobre o carvão, então o
/// papel de primária passa para o azul-céu.
abstract final class AppTheme {
  static const _navy = Color(0xFF0B2239);
  static const _teal = Color(0xFF0D9488);
  static const _blue = Color(0xFF2F6FED);
  static const _offWhite = Color(0xFFF7F8FA);
  static const _charcoal = Color(0xFF101820);

  static const _skyBlue = Color(0xFF8EC9FF);
  static const _tealLight = Color(0xFF5EEAD4);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _teal,
          brightness: brightness,
          primary: isLight ? _navy : _skyBlue,
          onPrimary: isLight ? Colors.white : _navy,
          secondary: isLight ? _teal : _tealLight,
          tertiary: _blue,
          surface: isLight ? _offWhite : _charcoal,
        ).copyWith(
          // Os degraus de superfície vêm declarados nos dois temas para os
          // cards não dependerem do tom que o Material derivaria sozinho.
          surfaceContainerLowest: isLight
              ? Colors.white
              : const Color(0xFF0B121A),
          surfaceContainerLow: isLight ? Colors.white : const Color(0xFF141D27),
          surfaceContainer: isLight
              ? const Color(0xFFF1F3F7)
              : const Color(0xFF18222D),
          surfaceContainerHigh: isLight
              ? const Color(0xFFE9ECF2)
              : const Color(0xFF1E2933),
          surfaceContainerHighest: isLight
              ? const Color(0xFFE2E6EE)
              : const Color(0xFF243039),
        );

    final baseText = isLight
        ? Typography.material2021().black
        : Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(baseText),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: const OutlineInputBorder(
          borderRadius: Radii.controlBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Radii.controlBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.controlBorder,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.controlBorder,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.controlBorder,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.surfaceBorder,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      // O tamanho mínimo declara altura **e** largura. `Size.fromHeight` é
      // `Size(double.infinity, h)`: usá-la aqui daria largura infinita a todo
      // botão preenchido do app e empilharia as ações dos diálogos. Quem
      // precisa de largura cheia declara isso na própria composição.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            TouchTarget.minimumWidth,
            TouchTarget.primary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(
            borderRadius: Radii.controlBorder,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            TouchTarget.minimumWidth,
            TouchTarget.primary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          side: BorderSide(color: colorScheme.outline),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: Radii.controlBorder,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            TouchTarget.minimumWidth,
            TouchTarget.minimum,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: Radii.controlBorder,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(TouchTarget.minimum),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.controlBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.emphasisBorder),
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xs,
          Spacing.lg,
          Spacing.lg,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radii.emphasis),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? _navy : colorScheme.surfaceContainerHighest,
        contentTextStyle: baseText.bodyMedium?.copyWith(
          color: isLight ? Colors.white : colorScheme.onSurface,
        ),
        insetPadding: const EdgeInsets.all(Spacing.md),
        shape: const RoundedRectangleBorder(borderRadius: Radii.controlBorder),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: baseText.labelLarge?.copyWith(color: colorScheme.onSurface),
        shape: const StadiumBorder(),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: Radii.surfaceBorder),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xxs,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: Spacing.xl,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.secondaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(
            TouchTarget.minimumWidth,
            TouchTarget.primary,
          ),
          selectedBackgroundColor: colorScheme.secondaryContainer,
          selectedForegroundColor: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  /// Ajustes de peso e respiro sobre a tipografia do Material.
  ///
  /// Títulos ganham peso e `height` menor para virarem âncora de leitura; o
  /// corpo ganha entrelinha para textos explicativos não ficarem apertados.
  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    headlineSmall: base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.4,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    bodySmall: base.bodySmall?.copyWith(height: 1.4),
    labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.1),
  );
}
