import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/core/security/encrypted_database.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';
import 'package:sqlite3/sqlite3.dart';

/// Ponto de injeção de falha da migração. Só existe para os testes provarem que
/// o rollback funciona sem depender de truques de sistema de arquivos.
@visibleForTesting
enum DatabaseMigrationFault { afterCopyBeforeSwap, afterSwapBeforeVerify }

/// Leva um banco texto puro da `alpha.2` (schema v4) para o formato
/// criptografado, sem apagar nada antes de confirmar.
///
/// Ver [ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md).
class DatabaseMigrator {
  const DatabaseMigrator({@visibleForTesting this.fault});

  @visibleForTesting
  final DatabaseMigrationFault? fault;

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
    //    confere a contagem de linhas antes de tocar no original. Qualquer
    //    falha aqui deixa o texto puro original intacto.
    final Map<String, int> expectedCounts;
    try {
      expectedCounts = await _copyToEncrypted(file, key, working);
      if (fault == DatabaseMigrationFault.afterCopyBeforeSwap) {
        throw StateError('fault');
      }
    } catch (_) {
      _safeDelete(working);
      throw const DatabaseEncryptionMigrationException();
    }

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
      if (fault == DatabaseMigrationFault.afterSwapBeforeVerify) {
        throw StateError('fault');
      }
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

  /// Monta o arquivo criptografado com o schema v4 completo e copia os dados do
  /// texto puro, coluna a coluna por nome — um banco `alpha.2` que chegou à v4
  /// por migração pode ter as colunas em ordem diferente de um `createAll`.
  ///
  /// Devolve a contagem de linhas por tabela do original, para conferência.
  Future<Map<String, int>> _copyToEncrypted(
    File source,
    String key,
    File target,
  ) async {
    _safeDelete(target);

    // 1. Schema: o onCreate do AppDatabase cria tabelas, índices e grava
    //    user_version = 4 no arquivo já criptografado.
    final schema = AppDatabase(
      NativeDatabase(target, setup: (db) => applyDatabaseKey(db, key)),
    );
    try {
      await schema.customSelect('SELECT 1').get();
    } finally {
      await schema.close();
    }

    // 2. Dados: anexa o texto puro e copia tabela a tabela, sem FK durante a
    //    cópia.
    final db = sqlite3.open(target.path);
    try {
      applyDatabaseKey(db, key);
      db.execute("ATTACH DATABASE '${_escape(source.path)}' AS plain KEY '';");
      db.execute('PRAGMA foreign_keys = OFF;');

      final counts = <String, int>{};
      final tables = db.select(
        "SELECT name FROM plain.sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );
      for (final row in tables) {
        final name = row['name'] as String;
        final columns = db
            .select('PRAGMA plain.table_info("$name");')
            .map((c) => '"${c['name']}"')
            .join(', ');
        db.execute(
          'INSERT INTO main."$name" ($columns) '
          'SELECT $columns FROM plain."$name";',
        );
        counts[name] =
            db.select('SELECT count(*) AS c FROM plain."$name";').first['c']
                as int;
      }
      db.execute('DETACH DATABASE plain;');
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
    if (file.existsSync()) {
      file.deleteSync();
    } else if (Directory(file.path).existsSync()) {
      Directory(file.path).deleteSync(recursive: true);
    }
  }

  String _escape(String value) => value.replaceAll("'", "''");
}
