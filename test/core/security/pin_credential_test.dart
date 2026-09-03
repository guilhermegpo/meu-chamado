import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/security/pin_credential.dart';

void main() {
  // Iterações baixas só no teste: o comportamento é o mesmo, sem o custo.
  const fastIterations = 1000;

  test('confere o PIN certo e recusa o errado', () async {
    final credential = await PinCredential.create(
      '481920',
      iterations: fastIterations,
    );

    expect(await credential.matches('481920'), isTrue);
    expect(await credential.matches('481921'), isFalse);
    expect(await credential.matches('000000'), isFalse);
  });

  test('serializa e desserializa preservando o verificador', () async {
    final credential = await PinCredential.create(
      '730154',
      iterations: fastIterations,
    );
    final restored = PinCredential.deserialize(credential.serialize());

    expect(await restored.matches('730154'), isTrue);
    expect(await restored.matches('730155'), isFalse);
    expect(restored.iterations, fastIterations);
  });

  test('o serializado não contém o PIN', () async {
    final credential = await PinCredential.create(
      '246813',
      iterations: fastIterations,
    );
    expect(credential.serialize(), isNot(contains('246813')));
    expect(credential.serialize(), startsWith('pbkdf2-sha256\$'));
  });

  test('desserializar recusa formato inválido', () {
    expect(
      () => PinCredential.deserialize('nao-e-um-verificador'),
      throwsFormatException,
    );
    expect(
      () => PinCredential.deserialize('md5\$1\$aa\$bb'),
      throwsFormatException,
    );
  });

  test('sais diferentes geram hashes diferentes para o mesmo PIN', () async {
    final a = await PinCredential.create(
      '481920',
      iterations: fastIterations,
      random: Random(1),
    );
    final b = await PinCredential.create(
      '481920',
      iterations: fastIterations,
      random: Random(2),
    );

    expect(a.serialize(), isNot(b.serialize()));
    expect(await a.matches('481920'), isTrue);
    expect(await b.matches('481920'), isTrue);
  });
}
