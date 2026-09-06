import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

/// Constrói o executor Drift para um arquivo criptografado com SQLite3 Multiple
/// Ciphers.
///
/// A [key] entra como passphrase — o SQLite3 Multiple Ciphers roda a própria
/// KDF por cima. Nunca é logada e nunca vai para o nome do arquivo. Ver
/// [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
QueryExecutor encryptedExecutor(File file, String key) {
  return LazyDatabase(() async {
    final parent = file.parent;
    if (!parent.existsSync()) {
      await parent.create(recursive: true);
    }
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) => applyDatabaseKey(raw, key),
    );
  });
}

/// Aplica a chave a um handle já aberto e confirma que o binário tem cifra.
///
/// Se o SQLite embutido não for o SQLite3 Multiple Ciphers, `PRAGMA cipher`
/// volta vazio e isto lança — erro de build explícito, não um banco que abre
/// sem proteção em silêncio.
void applyDatabaseKey(Database raw, String key) {
  raw.execute("PRAGMA key = '${key.replaceAll("'", "''")}';");
  if (raw.select('PRAGMA cipher;').isEmpty) {
    throw StateError(
      'O SQLite embutido não tem suporte a criptografia. Confira o define '
      'hooks/user_defines/sqlite3/source: sqlite3mc no pubspec.yaml.',
    );
  }
}

/// `true` se [file] abre e lê o schema **sem** chave — ou seja, ainda é texto
/// puro. Um arquivo criptografado falha ao ler `sqlite_master` sem a chave.
bool isPlaintextDatabase(File file) {
  if (!file.existsSync() || file.lengthSync() == 0) return false;
  Database? db;
  try {
    db = sqlite3.open(file.path, mode: OpenMode.readOnly);
    db.select('SELECT count(*) FROM sqlite_master;');
    return true;
  } on SqliteException {
    return false;
  } finally {
    db?.close();
  }
}
