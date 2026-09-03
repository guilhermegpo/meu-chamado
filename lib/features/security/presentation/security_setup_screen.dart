import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/security/pin_policy.dart';
import 'package:meu_chamado/core/security/security_repository.dart';
import 'package:meu_chamado/features/security/application/app_lock.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/security/presentation/pin_field.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

enum _Step { create, confirm, biometric }

/// "Proteja seus dados": cria o PIN, confirma e oferece a biometria.
class SecuritySetupScreen extends ConsumerStatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  ConsumerState<SecuritySetupScreen> createState() =>
      _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends ConsumerState<SecuritySetupScreen> {
  final _pinKey = GlobalKey<PinFieldState>();
  final _policy = const PinPolicy();

  _Step _step = _Step.create;
  String _firstPin = '';
  String? _error;
  bool _busy = false;
  bool _biometricAvailable = false;

  Future<void> _onPinCreated(String pin) async {
    final reason = _policy.validate(pin);
    if (reason != null) {
      _reject(reason);
      return;
    }
    setState(() {
      _firstPin = pin;
      _error = null;
      _step = _Step.confirm;
    });
    _resetField();
  }

  Future<void> _onPinConfirmed(String pin) async {
    if (pin != _firstPin) {
      _reject('Os PINs não são iguais. Comece de novo.');
      setState(() {
        _firstPin = '';
        _step = _Step.create;
      });
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(securityRepositoryProvider).setPin(pin);
    } on SecurityException catch (error) {
      setState(() {
        _busy = false;
        _firstPin = '';
        _step = _Step.create;
      });
      _reject(error.message);
      return;
    }

    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _biometricAvailable = available;
    });

    if (available) {
      setState(() => _step = _Step.biometric);
    } else {
      _finish();
    }
  }

  Future<void> _enableBiometric() async {
    setState(() => _busy = true);
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate('Confirme para ativar a biometria');
    if (!mounted) return;
    await ref.read(securityRepositoryProvider).setBiometricEnabled(enabled: ok);
    _finish();
  }

  void _finish() {
    ref.read(appLockProvider.notifier).completeSetup();
  }

  void _reject(String message) {
    setState(() => _error = message);
    _resetField();
  }

  void _resetField() {
    _pinKey.currentState?.clear();
    _pinKey.currentState?.focus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ({String title, String hint}) copy = switch (_step) {
      _Step.create => (
        title: 'Proteja seus dados',
        hint:
            'O Meu Chamado guarda tudo neste aparelho. Crie um PIN de '
            '${PinPolicy.length} dígitos para abrir o app.',
      ),
      _Step.confirm => (
        title: 'Repita o PIN',
        hint: 'Digite o mesmo PIN de novo para confirmar.',
      ),
      _Step.biometric => (
        title: 'Ativar biometria?',
        hint:
            'A biometria é um atalho para o PIN. O PIN continua funcionando '
            'sempre.',
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppsMeuMark(size: 72),
                  const SizedBox(height: Spacing.xl),
                  Text(
                    copy.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    copy.hint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Spacing.xxxl),
                  if (_step != _Step.biometric)
                    PinField(
                      key: _pinKey,
                      enabled: !_busy,
                      onCompleted: _step == _Step.create
                          ? _onPinCreated
                          : _onPinConfirmed,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: Spacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  if (_step == _Step.biometric && _biometricAvailable) ...[
                    const SizedBox(height: Spacing.md),
                    FilledButton.icon(
                      key: const Key('security-enable-biometric'),
                      onPressed: _busy ? null : _enableBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Ativar biometria'),
                    ),
                    const SizedBox(height: Spacing.xs),
                    TextButton(
                      key: const Key('security-skip-biometric'),
                      onPressed: _busy ? null : _finish,
                      child: const Text('Agora não'),
                    ),
                  ],
                  if (_busy) ...[
                    const SizedBox(height: Spacing.xl),
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
