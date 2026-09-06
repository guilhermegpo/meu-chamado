import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_clock.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';

/// Hora de referência do módulo: é daqui que sai o trimestre corrente e, com
/// ele, a decisão de congelar os trimestres já encerrados. Fica num provider
/// próprio para os testes exercitarem a virada de trimestre sem tocar no
/// relógio do sistema — em produção é sempre [systemClock].
final ministeringClockProvider = Provider<MinisteringClock>(
  (ref) => systemClock,
);

final ministeringRepositoryProvider = Provider<MinisteringRepository>(
  (ref) => MinisteringRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(ministeringClockProvider),
  ),
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

/// Lista de trimestres do histórico, do corrente (em andamento) para o mais
/// antigo. O denominador de cada trimestre encerrado vem do snapshot congelado;
/// o do corrente, do estado atual das duplas ativas.
final ministeringQuarterHistoryProvider =
    FutureProvider.family<List<MinisteringHistoricalQuarter>, String>(
      (ref, callingId) => ref
          .watch(ministeringRepositoryProvider)
          .loadQuarterHistory(callingId: callingId),
    );

/// Chamado e trimestre de um detalhe de histórico.
typedef MinisteringQuarterDetailQuery = ({String callingId, Quarter quarter});

/// Detalhe de um trimestre: as duplas do escopo separadas entre entrevistadas
/// e pendentes. Devolve `null` quando o trimestre não é o corrente e ainda não
/// tem snapshot.
final ministeringQuarterDetailProvider =
    FutureProvider.family<
      MinisteringQuarterDetail?,
      MinisteringQuarterDetailQuery
    >(
      (ref, query) => ref
          .watch(ministeringRepositoryProvider)
          .loadQuarterDetail(
            callingId: query.callingId,
            quarter: query.quarter,
          ),
    );
