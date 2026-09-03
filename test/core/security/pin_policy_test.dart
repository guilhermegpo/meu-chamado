import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/security/pin_policy.dart';

void main() {
  const policy = PinPolicy();

  test('aceita um PIN de seis dígitos sem padrão óbvio', () {
    expect(policy.validate('481920'), isNull);
    expect(policy.validate('730154'), isNull);
  });

  test('recusa tamanho diferente de seis', () {
    expect(policy.validate('12345'), isNotNull);
    expect(policy.validate('1234567'), isNotNull);
    expect(policy.validate(''), isNotNull);
  });

  test('recusa caracteres não numéricos', () {
    expect(policy.validate('12 456'), isNotNull);
    expect(policy.validate('abc123'), isNotNull);
  });

  test('recusa todos os dígitos iguais', () {
    for (var d = 0; d <= 9; d++) {
      final pin = '$d' * 6;
      expect(policy.validate(pin), isNotNull, reason: pin);
    }
  });

  test('recusa sequências simples', () {
    expect(policy.validate('123456'), isNotNull);
    expect(policy.validate('654321'), isNotNull);
    expect(policy.validate('012345'), isNotNull);
  });

  test('a razão da recusa é uma frase, não um código', () {
    final reason = policy.validate('000000');
    expect(reason, isA<String>());
    expect(reason, contains('adivinhar'));
  });
}
