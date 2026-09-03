import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/app_info.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/app/theme/theme_mode_controller.dart';
import 'package:meu_chamado/features/security/presentation/security_settings_section.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

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
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          Spacing.xxxl,
        ),
        children: [
          AppSurface(
            gradient: AppGradients.soft(Theme.of(context).brightness),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconTile(icon: Icons.tune_outlined),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu app, do seu jeito',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: Spacing.xxs),
                      Text(
                        'A preferência de tema fica salva neste dispositivo.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.section),
          const AppSectionHeader(title: 'Aparência'),
          const SizedBox(height: Spacing.sm),
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
          const SizedBox(height: Spacing.section),
          const AppSectionHeader(title: 'Segurança'),
          const SizedBox(height: Spacing.sm),
          const SecuritySettingsSection(),
          const SizedBox(height: Spacing.section),
          const AppSectionHeader(title: 'Sobre o produto'),
          const SizedBox(height: Spacing.sm),
          const AppSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: AppIconTile(icon: Icons.cloud_off_outlined),
                  title: Text('Compartilhamento'),
                  subtitle: Text('Planejado para uma versão futura'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: AppIconTile(icon: Icons.info_outline),
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
