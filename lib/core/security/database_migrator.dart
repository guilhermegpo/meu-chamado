import 'dart:io';

import 'package:meu_chamado/core/security/encrypted_database.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';
import 'package:sqlite3/sqlite3.dart';

/// Leva um banco texto puro da `alpha.2` (schema v4) para o formato
/// criptografado, sem apagar nada antes de confirmar.
///
/// Ver [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class DatabaseMigrator {
  const DatabaseMigrator();

  /// Garante que [file] está criptografado com [key].
  ///
  /// - arquivo ausente ou vazio: instalação nova, nada a fazer;
  /// - arquivo já criptografado: nada a fazer;
  /// - arquivo texto puro: migra de forma atômica, preservando o original até
  ///   a confirmação.
  Future<void> ensureEncrypted(File file, String key) async {
    final backup = File('${file.path}.pre-encryption.bak');
    final working = File('${file.path}.encrypting');

    _recoverFromInterruptedRun(file, key, backup, working);

    if (!_hasContent(file)) return;
    if (!isPlaintextDatabase(file)) return;

    await _migratePlaintext(file, key, backup, working);
  }

  /// Uma execução anterior pode ter parado no meio. Deixa o disco num estado
  /// conhecido antes de decidir se há o que migrar.
  void _recoverFromInterruptedRun(
    File file,
    String key,
    File backup,
    File working,
  ) {
    if (working.existsSync()) working.deleteSync();
    if (!backup.existsSync()) return;

    if (!_hasContent(file)) {
      // O swap parou depois de mover o original: o backup é a verdade.
      backup.renameSync(file.path);
      return;
    }
    if (!isPlaintextDatabase(file)) {
      // O swap concluiu, só faltou limpar. Confirma e apaga o backup.
      _verifyEncrypted(file, key, null);
      backup.deleteSync();
      return;
    }
    // O oficial ainda é texto puro: o backup é lixo de uma tentativa abortada.
    backup.deleteSync();
  }

  Future<void> _migratePlaintext(
    File file,
    String key,
    File backup,
    File working,
  ) async {
    // 1. Copia schema + dados para o arquivo criptografado temporário e
    //    confere a contagem de linhas antes de tocar no original.
    final expectedCounts = _copyToEncrypted(file, key, working);

    // 2. Swap: original -> .bak, criptografado -> nome oficial.
    file.renameSync(backup.path);
    try {
      working.renameSync(file.path);
    } catch (_) {
      backup.renameSync(file.path);
      _safeDelete(working);
      throw const DatabaseEncryptionMigrationException();
    }

    // 3. Confirma que o oficial abre criptografado com os mesmos dados.
    try {
      _verifyEncrypted(file, key, expectedCounts);
    } catch (_) {
      _safeDelete(file);
      backup.copySync(file.path);
      // Mantém o .bak: os dados do usuário não se perdem, mesmo com erro.
      throw const DatabaseEncryptionMigrationException(
        'A proteção do banco não pôde ser confirmada. Uma cópia dos seus '
        'dados foi mantida no dispositivo.',
      );
    }

    // 4. Tudo certo: o backup já não é necessário.
    _safeDelete(backup);
  }

  /// Copia via `sqlcipher_export` (disponível no SQLite3 Multiple Ciphers) e
  /// devolve a contagem de linhas por tabela do original.
  Map<String, int> _copyToEncrypted(File source, String key, File target) {
    _safeDelete(target);
    final db = sqlite3.open(source.path);
    try {
      final counts = _tableRowCounts(db);
      final userVersion =
          db.select('PRAGMA user_version;').first.values.first as int;

      db.execute(
        "ATTACH DATABASE '${_escape(target.path)}' AS enc "
        "KEY '${_escape(key)}';",
      );
      db.execute("SELECT sqlcipher_export('enc');");
      // sqlcipher_export não copia o user_version; o Drift usa isso como
      // schemaVersion, então precisa ir à mão.
      db.execute('PRAGMA enc.user_version = $userVersion;');
      db.execute('DETACH DATABASE enc;');
      return counts;
    } catch (_) {
      _safeDelete(target);
      throw const DatabaseEncryptionMigrationException();
    } finally {
      db.close();
    }
  }

  void _verifyEncrypted(
    File file,
    String key,
    Map<String, int>? expectedCounts,
  ) {
    final db = sqlite3.open(file.path);
    try {
      applyDatabaseKey(db, key);
      final counts = _tableRowCounts(db);
      if (counts.isEmpty) {
        throw const DatabaseEncryptionMigrationException();
      }
      if (expectedCounts != null) {
        for (final entry in expectedCounts.entries) {
          if (counts[entry.key] != entry.value) {
            throw const DatabaseEncryptionMigrationException();
          }
        }
      }
    } finally {
      db.close();
    }
  }

  Map<String, int> _tableRowCounts(Database db) {
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
    );
    final counts = <String, int>{};
    for (final row in tables) {
      final name = row['name'] as String;
      final count =
          db.select('SELECT count(*) AS c FROM "$name";').first['c'] as int;
      counts[name] = count;
    }
    return counts;
  }

  bool _hasContent(File file) => file.existsSync() && file.lengthSync() > 0;

  void _safeDelete(File file) {
    if (file.existsSync()) file.deleteSync();
  }

  String _escape(String value) => value.replaceAll("'", "''");
}
