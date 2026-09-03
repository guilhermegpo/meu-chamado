import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/core/security/database_key.dart';
import 'package:meu_chamado/core/security/database_migrator.dart';
import 'package:meu_chamado/core/security/encrypted_database.dart';
import 'package:meu_chamado/core/security/security_exceptions.dart';

/// Migração do banco texto puro da `alpha.2` (schema v4) para o formato
/// criptografado. Nenhum dado real: `Workspace Demo`, `Irmão A`… (ADR 0016).
void main() {
  late Directory directory;
  late File file;
  final key = generateDatabaseKey();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('meu-chamado-mig-');
    file = File('${directory.path}${Platform.pathSeparator}meu_chamado.sqlite');
    await _seedPlaintextV4(file);
  });

  tearDown(() async => directory.delete(recursive: true));

  AppDatabase openEncrypted() => AppDatabase(
    NativeDatabase(file, setup: (db) => applyDatabaseKey(db, key)),
  );

  Future<int> count(AppDatabase db, String table) async =>
      (await db.customSelect('SELECT count(*) AS c FROM $table').getSingle())
          .read<int>('c');

  test('migra preservando todos os dados e o schema', () async {
    await const DatabaseMigrator().ensureEncrypted(file, key);

    expect(isPlaintextDatabase(file), isFalse);

    final db = openEncrypted();
    addTearDown(db.close);

    expect(db.schemaVersion, 4);
    expect(await count(db, 'workspaces'), 1);
    expect(await count(db, 'users'), 1);
    expect(await count(db, 'callings'), 1);
    expect(await count(db, 'ministering_brothers'), 4);
    expect(await count(db, 'ministering_companionships'), 2);
    expect(await count(db, 'ministering_companionship_members'), 4);
    expect(await count(db, 'ministering_leaders'), 1);
    expect(await count(db, 'ministering_appointments'), 1);
    expect(await count(db, 'ministering_interviews'), 1);
    expect(await count(db, 'ministering_interview_participants'), 2);

    final interview = await db
        .customSelect(
          "SELECT interviewer_id FROM ministering_interviews WHERE id = 'i1'",
        )
        .getSingle();
    expect(interview.read<String>('interviewer_id'), 'l1');

    final fkCheck = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(fkCheck, isEmpty);
  });

  test('o arquivo final exige a chave', () async {
    await const DatabaseMigrator().ensureEncrypted(file, key);

    final wrong = AppDatabase(
      NativeDatabase(
        file,
        setup: (db) => applyDatabaseKey(db, generateDatabaseKey()),
      ),
    );
    await expectLater(
      wrong.customSelect('SELECT 1 FROM sqlite_master').get(),
      throwsA(anything),
    );
    await wrong.close();
  });

  test('rodar de novo num banco já criptografado não faz nada', () async {
    await const DatabaseMigrator().ensureEncrypted(file, key);
    final before = await file.readAsBytes();

    await const DatabaseMigrator().ensureEncrypted(file, key);
    expect(await file.readAsBytes(), before);

    expect(File('${file.path}.pre-encryption.bak').existsSync(), isFalse);
  });

  test('instalação nova (sem arquivo) não é migração', () async {
    file.deleteSync();
    await const DatabaseMigrator().ensureEncrypted(file, key);
    expect(file.existsSync(), isFalse);
  });

  test('falha antes do swap mantém o banco original intacto', () async {
    final original = await file.readAsBytes();

    await expectLater(
      const DatabaseMigrator(fault: DatabaseMigrationFault.afterCopyBeforeSwap)
          .ensureEncrypted(file, key),
      throwsA(isA<DatabaseEncryptionMigrationException>()),
    );

    expect(await file.readAsBytes(), original);
    expect(isPlaintextDatabase(file), isTrue);
    expect(File('${file.path}.pre-encryption.bak').existsSync(), isFalse);
    expect(File('${file.path}.encrypting').existsSync(), isFalse);

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect(await count(db, 'ministering_brothers'), 4);
  });

  test('falha depois do swap volta o backup e não perde dados', () async {
    await expectLater(
      const DatabaseMigrator(
        fault: DatabaseMigrationFault.afterSwapBeforeVerify,
      ).ensureEncrypted(file, key),
      throwsA(isA<DatabaseEncryptionMigrationException>()),
    );

    // O oficial voltou a ser o texto puro (restaurado do .bak) com os dados.
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect(await count(db, 'ministering_brothers'), 4);
    expect(await count(db, 'ministering_interviews'), 1);
  });

  test(
    'recupera de uma execução interrompida antes de limpar o backup',
    () async {
      await const DatabaseMigrator().ensureEncrypted(file, key);

      // Simula: swap concluiu, processo morreu antes de apagar o .bak.
      final backup = File('${file.path}.pre-encryption.bak');
      await _seedPlaintextV4(backup); // conteúdo qualquer; será descartado

      await const DatabaseMigrator().ensureEncrypted(file, key);

      expect(backup.existsSync(), isFalse);
      expect(isPlaintextDatabase(file), isFalse);
      final db = openEncrypted();
      addTearDown(db.close);
      expect(await count(db, 'ministering_brothers'), 4);
    },
  );
}

/// Cria o banco no schema v4 (via `onCreate` do `AppDatabase`) e semeia um
/// cenário realista de ministração.
Future<void> _seedPlaintextV4(File file) async {
  final db = AppDatabase(NativeDatabase(file));
  const statements = [
    "INSERT INTO workspaces VALUES ('ws', 'Workspace Demo', 'LOCAL', 0)",
    "INSERT INTO users VALUES ('u1', 'Administrador Demo', NULL, 0)",
    "INSERT INTO memberships VALUES ('ws', 'u1', 'ADMIN', 0)",
    "INSERT INTO callings VALUES ('c-a', 'ws', 'u1', 'Secretário da "
        "Ministração', 'ministering-secretary', 'ACTIVE', 0, NULL)",
    "INSERT INTO ministering_brothers (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('b1', 'c-a', 'Irmão A', 1, 0, 0)",
    "INSERT INTO ministering_brothers (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('b2', 'c-a', 'Irmão B', 1, 0, 0)",
    "INSERT INTO ministering_brothers (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('b3', 'c-a', 'Irmão C', 1, 0, 0)",
    "INSERT INTO ministering_brothers (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('b4', 'c-a', 'Irmão D', 1, 0, 0)",
    "INSERT INTO ministering_companionships (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('cp1', 'c-a', NULL, 1, 0, 0)",
    "INSERT INTO ministering_companionships (id, calling_id, display_label, "
        "is_active, created_at, updated_at) VALUES "
        "('cp2', 'c-a', NULL, 1, 0, 0)",
    "INSERT INTO ministering_companionship_members VALUES "
        "('cp1', 'b1', 'c-a', 0)",
    "INSERT INTO ministering_companionship_members VALUES "
        "('cp1', 'b2', 'c-a', 0)",
    "INSERT INTO ministering_companionship_members VALUES "
        "('cp2', 'b3', 'c-a', 0)",
    "INSERT INTO ministering_companionship_members VALUES "
        "('cp2', 'b4', 'c-a', 0)",
    "INSERT INTO ministering_leaders (id, calling_id, display_label, role, "
        "is_active, created_at, updated_at) VALUES "
        "('l1', 'c-a', 'Irmão P', 'QUORUM_PRESIDENT', 1, 0, 0)",
    "INSERT INTO ministering_interviews (id, calling_id, companionship_id, "
        "interviewer_id, completed_at, created_at) VALUES "
        "('i1', 'c-a', 'cp1', 'l1', 0, 0)",
    "INSERT INTO ministering_interview_participants VALUES "
        "('i1', 'b1', 'c-a', 'cp1')",
    "INSERT INTO ministering_interview_participants VALUES "
        "('i1', 'b2', 'c-a', 'cp1')",
    "INSERT INTO ministering_appointments (id, calling_id, companionship_id, "
        "interviewer_id, scheduled_at, created_at, updated_at) VALUES "
        "('a1', 'c-a', 'cp2', 'l1', 0, 0, 0)",
  ];
  for (final statement in statements) {
    await db.customStatement(statement);
  }
  await db.close();
}
