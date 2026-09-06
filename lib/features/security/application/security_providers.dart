import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/core/security/biometric_service.dart';
import 'package:meu_chamado/core/security/database_location.dart';
import 'package:meu_chamado/core/security/database_migrator.dart';
import 'package:meu_chamado/core/security/secure_store.dart';
import 'package:meu_chamado/core/security/security_repository.dart';

final secureStoreProvider = Provider<SecureStore>((ref) => SystemSecureStore());

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => SystemBiometricService(),
);

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => SecurityRepository(ref.watch(secureStoreProvider)),
);

final databaseMigratorProvider = Provider<DatabaseMigrator>(
  (ref) => const DatabaseMigrator(),
);

/// Resolve o banco criptografado: chave → migração texto puro → abertura.
///
/// Roda enquanto a splash está visível. A partir daqui todo acesso a dados usa
/// [databaseProvider], que só é lido depois que este resolve.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final security = ref.watch(securityRepositoryProvider);
  final file = await resolveDatabaseFile();
  final key = await security.databaseKey();
  await ref.watch(databaseMigratorProvider).ensureEncrypted(file, key);

  final database = AppDatabase.encrypted(file, key);
  ref.onDispose(database.close);
  return database;
});

/// Se a proteção por PIN já foi configurada neste dispositivo.
final pinConfiguredProvider = FutureProvider<bool>(
  (ref) => ref.watch(securityRepositoryProvider).isPinConfigured(),
);
