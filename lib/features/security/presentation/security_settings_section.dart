import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/security/presentation/change_pin_screen.dart';
import 'package:meu_chamado/shared/feedback/app_haptics.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';

/// Seção "Segurança" das Configurações: estado do PIN, biometria, trocar o PIN
/// e bloquear agora. Não há recuperação online.
class SecuritySettingsSection extends ConsumerStatefulWidget {
  const SecuritySettingsSection({super.key});

  @override
  ConsumerState<SecuritySettingsSection> createState() =>
      _SecuritySettingsSectionState();
}

class _SecuritySettingsSectionState
    extends ConsumerState<SecuritySettingsSection> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final security = ref.read(securityRepositoryProvider);
    final available = await ref.read(biometricServiceProvider).isAvailable();
    final enabled = await security.isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    AppHaptics.toggle();
    setState(() => _busy = true);
    var enabled = value;
    if (value) {
      enabled = await ref
          .read(biometricServiceProvider)
          .authenticate('Confirme para ativar a biometria');
    }
    await ref
        .read(securityRepositoryProvider)
        .setBiometricEnabled(enabled: enabled);
    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSurface(
          // ListTile pinta ink no Material mais próximo; sem isto ele fica
          // atrás do fundo do AppSurface.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline),
                  title: Text('Proteção por PIN'),
                  subtitle: Text('Ativa neste dispositivo'),
                ),
                if (_biometricAvailable)
                  SwitchListTile(
                    key: const Key('security-biometric-switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Desbloquear com biometria'),
                    subtitle: const Text('O PIN continua funcionando sempre'),
                    value: _biometricEnabled,
                    onChanged: _busy ? null : _toggleBiometric,
                  ),
                const Divider(height: Spacing.xl),
                ListTile(
                  key: const Key('security-change-pin'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('Alterar PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChangePinScreen(),
                    ),
                  ),
                ),
                ListTile(
                  key: const Key('security-lock-now'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_clock_outlined),
                  title: const Text('Bloquear agora'),
                  onTap: () {
                    AppHaptics.milestone();
                    ref.read(appLockProvider.notifier).lockNow();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Não há recuperação pela internet. Guarde seu PIN.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
