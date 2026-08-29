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

/// Chamado e dupla de um histórico de entrevistas.
typedef MinisteringInterviewsQuery = ({
  String callingId,
  String companionshipId,
});

/// Histórico de uma dupla, da entrevista mais recente para a mais antiga.
///
/// Fica fora de [ministeringModuleProvider] de propósito: o painel só precisa
/// saber quais duplas já foram entrevistadas no trimestre, e carregar o
/// histórico de todas elas junto seria ler muito para mostrar pouco.
final ministeringInterviewsProvider =
    FutureProvider.family<
      List<MinisteringInterview>,
      MinisteringInterviewsQuery
    >(
      (ref, query) => ref
          .watch(ministeringRepositoryProvider)
          .listInterviews(
            callingId: query.callingId,
            companionshipId: query.companionshipId,
          ),
    );
