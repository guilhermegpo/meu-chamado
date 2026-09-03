import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Liga/desliga o `FLAG_SECURE` da janela no Android: oculta o conteúdo no
/// seletor de apps e bloqueia captura de tela.
///
/// O trade-off (impede também screenshots legítimos) é aceito enquanto o app
/// mostra a agenda administrativa da ala. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class SecureWindow {
  const SecureWindow();

  static const _channel = MethodChannel('meu_chamado/secure_window');

  Future<void> setSecure({required bool secure}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    // Em debug o flag fica desligado para não quebrar screenshots de
    // homologação; em release ele protege o usuário.
    if (kDebugMode) return;
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on PlatformException {
      // Sem canal (teste, plataforma sem suporte): a proteção de dados em
      // repouso e o bloqueio por PIN continuam valendo.
    } on MissingPluginException {
      // idem
    }
  }
}
