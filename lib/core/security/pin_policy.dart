/// Regras mínimas do PIN.
///
/// Não é senha: são 6 dígitos, sem os padrões mais óbvios. A ideia é evitar o
/// PIN que qualquer pessoa tentaria primeiro, sem transformar a criação num
/// jogo de adivinhar o que o app aceita.
class PinPolicy {
  const PinPolicy();

  static const length = 6;

  static const _blocked = {
    '000000',
    '111111',
    '222222',
    '333333',
    '444444',
    '555555',
    '666666',
    '777777',
    '888888',
    '999999',
    '123456',
    '654321',
    '012345',
    '543210',
  };

  /// Devolve `null` se o PIN serve, ou a frase que explica a recusa.
  String? validate(String pin) {
    if (pin.length != length) {
      return 'O PIN precisa ter $length dígitos.';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'Use apenas números.';
    }
    if (_blocked.contains(pin) || _isRun(pin)) {
      return 'Esse PIN é fácil de adivinhar. Escolha outro.';
    }
    return null;
  }

  /// Sequência simples crescente ou decrescente (1-2-3-4-5-6, 9-8-7-6-5-4).
  bool _isRun(String pin) {
    var ascending = true;
    var descending = true;
    for (var i = 1; i < pin.length; i++) {
      final prev = pin.codeUnitAt(i - 1);
      final curr = pin.codeUnitAt(i);
      if (curr != prev + 1) ascending = false;
      if (curr != prev - 1) descending = false;
    }
    return ascending || descending;
  }
}
