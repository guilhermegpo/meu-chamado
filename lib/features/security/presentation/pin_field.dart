import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/core/security/pin_policy.dart';

/// Entrada de PIN: seis pontos guiados por um campo numérico oculto.
///
/// Um campo de texto real (e não um teclado desenhado) mantém o suporte a
/// teclado físico, leitor de tela e preenchimento — importante inclusive no
/// emulador.
class PinField extends StatefulWidget {
  const PinField({
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.autofocus = true,
    this.onDark = false,
    super.key,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final bool onDark;

  @override
  State<PinField> createState() => PinFieldState();
}

class PinFieldState extends State<PinField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Limpa o campo — usado quando o PIN é recusado.
  void clear() => _controller.clear();

  void focus() => _focusNode.requestFocus();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    widget.onChanged?.call(value);
    if (value.length == PinPolicy.length) {
      widget.onCompleted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled = widget.onDark ? Colors.white : scheme.primary;
    final empty = (widget.onDark ? Colors.white : scheme.outline).withValues(
      alpha: 0.35,
    );

    return Semantics(
      textField: true,
      label: 'PIN de ${PinPolicy.length} dígitos',
      child: GestureDetector(
        onTap: widget.enabled ? focus : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                obscureText: true,
                showCursor: false,
                maxLength: PinPolicy.length,
                style: const TextStyle(color: Colors.transparent, height: 0.01),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(PinPolicy.length),
                ],
                onChanged: _handleChange,
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final count = _controller.text.length;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < PinPolicy.length; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Spacing.xs,
                        ),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < count ? filled : Colors.transparent,
                          border: Border.all(
                            color: i < count ? filled : empty,
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
