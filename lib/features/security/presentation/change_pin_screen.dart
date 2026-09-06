import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/security/pin_policy.dart';
import 'package:meu_chamado/core/security/security_repository.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/security/presentation/pin_field.dart';

enum _Step { current, create, confirm }

/// Troca o PIN: exige o atual, pede o novo e confirma.
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _pinKey = GlobalKey<PinFieldState>();
  final _policy = const PinPolicy();

  _Step _step = _Step.current;
  String _currentPin = '';
  String _newPin = '';
  String? _error;
  bool _busy = false;

  Future<void> _onSubmit(String pin) async {
    switch (_step) {
      case _Step.current:
        setState(() => _busy = true);
        final ok = await ref.read(securityRepositoryProvider).verifyPin(pin);
        if (!mounted) return;
        setState(() => _busy = false);
        if (!ok) {
          _reject('PIN atual incorreto.');
          return;
        }
        setState(() {
          _currentPin = pin;
          _error = null;
          _step = _Step.create;
        });
        _reset();
      case _Step.create:
        final reason = _policy.validate(pin);
        if (reason != null) {
          _reject(reason);
          return;
        }
        setState(() {
          _newPin = pin;
          _error = null;
          _step = _Step.confirm;
        });
        _reset();
      case _Step.confirm:
        if (pin != _newPin) {
          _reject('Os PINs não são iguais.');
          setState(() => _step = _Step.create);
          return;
        }
        setState(() => _busy = true);
        try {
          await ref
              .read(securityRepositoryProvider)
              .changePin(currentPin: _currentPin, newPin: pin);
        } on SecurityException catch (error) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _step = _Step.create;
          });
          _reject(error.message);
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('PIN alterado.')));
        Navigator.of(context).pop();
    }
  }

  void _reject(String message) {
    setState(() => _error = message);
    _reset();
  }

  void _reset() {
    _pinKey.currentState?.clear();
    _pinKey.currentState?.focus();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      _Step.current => 'Digite o PIN atual',
      _Step.create => 'Escolha o novo PIN',
      _Step.confirm => 'Repita o novo PIN',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Alterar PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.xxxl),
                PinField(
                  key: _pinKey,
                  enabled: !_busy,
                  onCompleted: _onSubmit,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
