import 'package:flutter/material.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Cabeçalho de seção com a contagem ao lado.
///
/// A contagem ganha rótulo semântico próprio porque, sozinho, um número em
/// `Chip` é lido pelo leitor de tela sem dizer do que se trata.
class MinisteringSectionTitle extends StatelessWidget {
  const MinisteringSectionTitle({
    required this.label,
    required this.count,
    super.key,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) =>
      AppSectionHeader(title: label, count: count);
}

class MinisteringEmptyState extends StatelessWidget {
  const MinisteringEmptyState({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => AppSurface(
    padding: const EdgeInsets.all(Spacing.md),
    child: Row(
      children: [
        AppIconTile(icon: icon, size: 42),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

/// Lembrete de privacidade exibido onde o usuário digita identificações.
///
/// O app guarda o mínimo necessário para o secretário se orientar. O lembrete
/// fica na tela, não só na documentação, porque é ali que a decisão é tomada.
class MinisteringPrivacyNote extends StatelessWidget {
  const MinisteringPrivacyNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurface(
      padding: const EdgeInsets.all(Spacing.md),
      gradient: AppGradients.soft(Theme.of(context).brightness),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
