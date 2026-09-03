import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/security/security_repository.dart';

import 'fake_secure_store.dart';

void main() {
  late FakeSecureStore store;
  late SecurityRepository repository;

  setUp(() {
    store = FakeSecureStore();
    repository = SecurityRepository(store);
  });

  group('chave do banco', () {
    test('é criada uma vez e se mantém estável', () async {
      final first = await repository.databaseKey();
      final second = await repository.databaseKey();

      expect(first, hasLength(64));
      expect(first, equals(second));
      expect(await repository.hasDatabaseKey(), isTrue);
    });

    test('não fica em app_preferences nem em texto óbvio', () async {
      final key = await repository.databaseKey();
      // O único lugar é o secure store, sob uma entrada dedicada.
      expect(store.values.values, contains(key));
      expect(store.values.keys.single, contains('database_key'));
    });
  });

  group('PIN', () {
    test('não configurado até setPin', () async {
      expect(await repository.isPinConfigured(), isFalse);
      await repository.setPin('481920');
      expect(await repository.isPinConfigured(), isTrue);
    });

    test('recusa PIN fraco', () async {
      expect(
        () => repository.setPin('111111'),
        throwsA(isA<WeakPinException>()),
      );
      expect(await repository.isPinConfigured(), isFalse);
    });

    test('verifica o PIN certo e recusa o errado', () async {
      await repository.setPin('481920');
      expect(await repository.verifyPin('481920'), isTrue);
      expect(await repository.verifyPin('000001'), isFalse);
    });

    test('verificar sem PIN configurado lança', () async {
      expect(
        () => repository.verifyPin('481920'),
        throwsA(isA<SecurityNotConfiguredException>()),
      );
    });

    test('o PIN em claro nunca é guardado', () async {
      await repository.setPin('481920');
      expect(store.values.values, isNot(contains('481920')));
      expect(store.values.values.any((v) => v.contains('481920')), isFalse);
    });

    test('trocar o PIN exige o atual correto', () async {
      await repository.setPin('481920');

      expect(
        () => repository.changePin(currentPin: '000000', newPin: '730154'),
        throwsA(isA<InvalidPinException>()),
      );
      expect(await repository.verifyPin('481920'), isTrue);

      await repository.changePin(currentPin: '481920', newPin: '730154');
      expect(await repository.verifyPin('730154'), isTrue);
      expect(await repository.verifyPin('481920'), isFalse);
    });
  });

  group('biometria', () {
    test('desligada por padrão e persiste a escolha', () async {
      expect(await repository.isBiometricEnabled(), isFalse);
      await repository.setBiometricEnabled(enabled: true);
      expect(await repository.isBiometricEnabled(), isTrue);
      await repository.setBiometricEnabled(enabled: false);
      expect(await repository.isBiometricEnabled(), isFalse);
    });
  });
}
