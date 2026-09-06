import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/app_info.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/app/theme/theme_mode_controller.dart';
import 'package:meu_chamado/features/security/presentation/security_settings_section.dart';
import 'package:meu_chamado/shared/feedback/app_haptics.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Configurações, agrupadas por área: preferências do app e informações do
/// produto. A segurança faz parte das preferências — o bloqueio é do app.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeState = ref.watch(themeModeProvider);
    final selectedMode = themeModeState.when(
      data: (mode) => mode,
      loading: () => ThemeMode.system,
      error: (_, _) => ThemeMode.system,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.screenGutter,
          Spacing.sm,
          Spacing.screenGutter,
          Spacing.xxxl,
        ),
        children: [
          const _SectionLabel('Preferências'),
          const SizedBox(height: Spacing.sm),
          Text('Aparência', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.xs),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.settings_suggest_outlined),
                label: Text('Sistema'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Claro'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Escuro'),
              ),
            ],
            selected: {selectedMode},
            onSelectionChanged: themeModeState.isLoading
                ? null
                : (selection) async {
                    AppHaptics.selection();
                    try {
                      await ref
                          .read(themeModeProvider.notifier)
                          .select(selection.first);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Não foi possível salvar a preferência de tema.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(height: Spacing.lg),
          Text('Segurança', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.xs),
          const SecuritySettingsSection(),
          const SizedBox(height: Spacing.section),
          const _SectionLabel('Aplicativo'),
          const SizedBox(height: Spacing.sm),
          const AppSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Privacidade'),
                  subtitle: Text(
                    'Tudo fica neste aparelho. Sem sincronização, sem '
                    'compartilhamento e sem envio para a internet.',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Meu Chamado'),
                  subtitle: Text(AppInfo.versionLine),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const Center(child: AppBrandLockup()),
          const SizedBox(height: Spacing.sm),
          Text(
            'Projeto independente e não oficial.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Rótulo de grupo das configurações: caixa alta, discreto, sem virar um card.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 1,
      fontWeight: FontWeight.w700,
    ),
  );
}
