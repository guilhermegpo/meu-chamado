import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/security/presentation/pin_field.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

/// Tela de bloqueio. Não mostra nada do conteúdo — só a marca, o PIN e, quando
/// ativada, a biometria.
class LockedScreen extends ConsumerStatefulWidget {
  const LockedScreen({super.key});

  @override
  ConsumerState<LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends ConsumerState<LockedScreen> {
  final _pinKey = GlobalKey<PinFieldState>();
  String? _error;
  bool _busy = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _maybeOfferBiometric();
  }

  Future<void> _maybeOfferBiometric() async {
    final enabled = await ref
        .read(securityRepositoryProvider)
        .isBiometricEnabled();
    if (!mounted) return;
    setState(() => _biometricEnabled = enabled);
    if (enabled) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(appLockProvider.notifier).submitBiometric();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _submitPin(String pin) async {
    setState(() => _busy = true);
    final failure = await ref.read(appLockProvider.notifier).submitPin(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failure;
    });
    if (failure != null) {
      _pinKey.currentState?.clear();
      _pinKey.currentState?.focus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.navy950,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.darkHero),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppsMeuMark(size: 96, shadow: true),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      'Meu Chamado está bloqueado',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Digite seu PIN para continuar.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: Spacing.xxxl),
                    PinField(
                      key: _pinKey,
                      onDark: true,
                      enabled: !_busy,
                      onCompleted: _submitPin,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: Spacing.md),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.cyan400),
                      ),
                    ],
                    if (_biometricEnabled) ...[
                      const SizedBox(height: Spacing.xl),
                      TextButton.icon(
                        key: const Key('locked-use-biometric'),
                        onPressed: _busy ? null : _tryBiometric,
                        icon: const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Usar biometria',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
