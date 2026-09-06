import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/core/security/database_key.dart';
import 'package:meu_chamado/core/security/encrypted_database.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';

void main() {
  late Directory directory;
  late File file;
  final key = generateDatabaseKey();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('meu-chamado-enc-');
    file = File('${directory.path}${Platform.pathSeparator}meu_chamado.sqlite');
  });

  tearDown(() async => directory.delete(recursive: true));

  AppDatabase openWith(String withKey) => AppDatabase(
    NativeDatabase(file, setup: (db) => applyDatabaseKey(db, withKey)),
  );

  test('a chave certa abre e lê o que foi gravado', () async {
    final first = openWith(key);
    await WorkspaceRepository(first).createLocalWorkspace(
      workspaceName: 'Workspace Demo',
      administratorName: 'Administrador Demo',
    );
    await first.close();

    final reopened = openWith(key);
    final dashboard = await WorkspaceRepository(reopened).loadDashboard();
    expect(dashboard, isNotNull);
    expect(dashboard!.name, 'Workspace Demo');
    await reopened.close();
  });

  test('a chave errada não abre o banco', () async {
    final created = openWith(key);
    await created.customStatement('CREATE TABLE t (x)');
    await created.close();

    final wrong = openWith(generateDatabaseKey());
    await expectLater(
      wrong.customSelect('SELECT count(*) FROM sqlite_master').get(),
      throwsA(anything),
    );
    await wrong.close();
  });

  test('o arquivo criptografado não se lê como texto puro', () async {
    final created = openWith(key);
    await created.customStatement('CREATE TABLE t (x)');
    await created.close();

    expect(isPlaintextDatabase(file), isFalse);
  });

  test('isPlaintextDatabase reconhece um banco sem chave', () async {
    final plain = AppDatabase(NativeDatabase(file));
    await plain.customStatement('CREATE TABLE t (x)');
    await plain.close();

    expect(isPlaintextDatabase(file), isTrue);
  });
}
