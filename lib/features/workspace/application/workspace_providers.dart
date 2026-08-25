import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => WorkspaceRepository(ref.watch(databaseProvider)),
);

final workspaceBootstrapProvider = FutureProvider<WorkspaceDashboard?>(
  (ref) => ref.watch(workspaceRepositoryProvider).loadDashboard(),
);
