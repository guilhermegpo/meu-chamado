import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';

/// Tema do app, montado a partir de uma paleta própria.
///
/// Claro e escuro são construídos pelo mesmo caminho, com as superfícies
/// declaradas explicitamente nos dois. Escuro não é o claro invertido: o navy
/// que serve de tinta no claro não teria contraste sobre o carvão, então o
/// papel de primária passa para o azul-céu.
abstract final class AppTheme {
  static const _skyBlue = Color(0xFF8EC9FF);
  static const _tealLight = Color(0xFF5EEAD4);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.teal600,
          brightness: brightness,
          primary: isLight ? AppColors.navy900 : _skyBlue,
          onPrimary: isLight ? Colors.white : AppColors.navy950,
          secondary: isLight ? AppColors.teal600 : _tealLight,
          tertiary: AppColors.blue600,
          surface: isLight ? AppColors.offWhite : AppColors.charcoal,
        ).copyWith(
          // Os degraus de superfície vêm declarados nos dois temas para os
          // cards não dependerem do tom que o Material derivaria sozinho.
          surfaceContainerLowest: isLight ? Colors.white : AppColors.navy950,
          surfaceContainerLow: isLight ? Colors.white : const Color(0xFF121F2B),
          surfaceContainer: isLight
              ? const Color(0xFFF0F4F8)
              : const Color(0xFF172633),
          surfaceContainerHigh: isLight
              ? const Color(0xFFE7EDF3)
              : const Color(0xFF1D2E3C),
          surfaceContainerHighest: isLight
              ? const Color(0xFFDDE6EE)
              : const Color(0xFF253845),
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
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.72),
          ),
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
        backgroundColor: isLight
            ? AppColors.navy900
            : colorScheme.surfaceContainerHighest,
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
        color: colorScheme.secondary,
        linearTrackColor: colorScheme.secondaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          baseText.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
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

  /// Hierarquia editorial da Product Experience 2.0.
  ///
  /// Escala conceitual: Display 32/36, Headline 26/30, Title 20/24,
  /// Body Large 16/24, Body 14/21, Label 12/16. Só o Display carrega o peso
  /// mais alto — abaixo dele o contraste vem do tamanho e do `height`, não de
  /// mais bold, para a leitura não ficar pesada.
  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 36 / 32,
      letterSpacing: -1,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 32 / 28,
      letterSpacing: -0.6,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 30 / 26,
      letterSpacing: -0.4,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 24 / 20,
      letterSpacing: -0.2,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 22 / 16,
      letterSpacing: -0.1,
    ),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 24 / 16),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 21 / 14),
    bodySmall: base.bodySmall?.copyWith(fontSize: 13, height: 18 / 13),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.4,
    ),
  );
}
