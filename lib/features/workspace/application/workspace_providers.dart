import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/security/application/security_providers.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';
import 'package:meu_chamado/features/profile/data/profile_photo_service.dart';

/// Acesso síncrono ao banco. Só é lido depois que [appDatabaseProvider]
/// resolveu (chave, migração e abertura criptografada) — o que acontece antes
/// de qualquer tela de dados. Os testes de widget sobrescrevem este provider
/// diretamente com um banco em memória.
final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(appDatabaseProvider).requireValue,
);

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => WorkspaceRepository(ref.watch(databaseProvider)),
);

final profilePhotoServiceProvider = Provider<ProfilePhotoService>(
  (ref) => ProfilePhotoService(),
);

final workspaceBootstrapProvider = FutureProvider<WorkspaceDashboard?>(
  (ref) => ref.watch(workspaceRepositoryProvider).loadDashboard(),
);
