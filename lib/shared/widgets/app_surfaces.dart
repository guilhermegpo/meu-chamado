import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

class AppBrandLockup extends StatelessWidget {
  const AppBrandLockup({this.compact = false, this.onDark = false, super.key});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final foreground = onDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppsMeuMark(size: compact ? 42 : 54, shadow: !onDark),
        SizedBox(width: compact ? Spacing.sm : Spacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meu Chamado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (!compact)
              Text(
                'ORGANIZE · SIRVA · FAÇA A DIFERENÇA',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.75,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class AppIconTile extends StatelessWidget {
  const AppIconTile({
    required this.icon,
    this.size = 44,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final double size;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: AppGradients.brand,
      borderRadius: Radii.controlBorder,
    ),
    child: SizedBox.square(
      dimension: size,
      child: Icon(icon, color: foregroundColor ?? Colors.white),
    ),
  );
}

/// Avatar de iniciais para pessoas em listas — irmãos, liderança.
///
/// Sem foto no domínio da Ministração (identificação mínima), a inicial já
/// dá âncora visual para percorrer a lista sem virar mais um ícone genérico.
class AppInitialAvatar extends StatelessWidget {
  const AppInitialAvatar({required this.label, this.size = 40, super.key});

  final String label;
  final double size;

  String get _initials {
    final parts = label.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          _initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.gradient,
    this.color,
    this.border,
    this.shadow = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final Border? border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color ?? scheme.surfaceContainerLow : null,
        gradient: gradient,
        borderRadius: Radii.surfaceBorder,
        border:
            border ??
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.72)),
        boxShadow: shadow
            ? AppShadows.soft(Theme.of(context).brightness)
            : null,
      ),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.count,
    this.action,
    super.key,
  });

  final String title;
  final int? count;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (count != null)
        Semantics(
          label: '$title: $count',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      if (action != null) ...[const SizedBox(width: Spacing.xs), action!],
    ],
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => AppSurface(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconTile(icon: icon, size: 48),
        const SizedBox(height: Spacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: Spacing.xs),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: Spacing.md), action!],
      ],
    ),
  );
}

class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    required this.label,
    required this.icon,
    this.positive = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = positive
        ? scheme.secondaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = positive
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
