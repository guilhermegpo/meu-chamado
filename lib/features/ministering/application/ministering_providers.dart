import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';

final ministeringRepositoryProvider = Provider<MinisteringRepository>(
  (ref) => MinisteringRepository(ref.watch(databaseProvider)),
);

/// Estado do módulo para um chamado.
///
/// A família é indexada pelo `callingId` porque o mesmo aparelho pode guardar
/// mais de um chamado, e um não pode enxergar os dados do outro. Depois de cada
/// escrita a tela invalida a instância correspondente para reler.
final ministeringModuleProvider =
    FutureProvider.family<MinisteringModuleState, String>(
      (ref, callingId) => ref
          .watch(ministeringRepositoryProvider)
          .loadModule(callingId: callingId),
    );
