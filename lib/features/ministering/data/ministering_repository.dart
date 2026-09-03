import 'package:drift/drift.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_exceptions.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

/// Acesso aos dados do módulo de ministração.
///
/// Todo método opera dentro de um `callingId`: os dados pertencem à instância
/// do chamado, não ao Workspace nem ao usuário. As chaves estrangeiras
/// compostas do schema v3 garantem isso no banco; o repositório apenas nunca
/// oferece um caminho que atravesse chamados.
///
/// Não recebe `actorId`. Diferente do `WorkspaceRepository`, aqui não há
/// decisão de autorização a tomar: o papel do Workspace (`ADMIN`, `MODERATOR`,
/// `USER`) é técnico e não representa autoridade eclesiástica. Aceitar o
/// parâmetro sugeriria uma verificação que não existe.
class MinisteringRepository {
  MinisteringRepository(this._database);

  final AppDatabase _database;

  int _lastIdentifier = 0;

  /// Carrega tudo que o painel precisa em uma leitura só.
  ///
  /// Uma chamada em vez de várias evita a cascata de futures encadeados que
  /// faria a tela piscar enquanto cada parte chega.
  Future<MinisteringModuleState> loadModule({
    required String callingId,
    Quarter? quarter,
  }) async {
    final targetQuarter = quarter ?? Quarter.of(DateTime.now());

    final brothers = await _loadBrothers(callingId);
    final leaders = await _loadLeaders(callingId);
    final companionships = await _loadCompanionships(callingId, brothers);
    final appointments = await _loadAppointments(callingId);
    final interviewed = await _interviewedCompanionshipIds(
      callingId: callingId,
      quarter: targetQuarter,
    );

    final active = companionships.where((item) => item.isActive).toList();
    final activeInterviewed = active
        .where((item) => interviewed.contains(item.id))
        .length;

    return MinisteringModuleState(
      callingId: callingId,
      brothers: brothers,
      leaders: leaders,
      companionships: companionships,
      appointments: appointments,
      interviewedCompanionshipIds: interviewed,
      summary: QuarterSummary(
        quarter: targetQuarter,
        activeCompanionships: active.length,
        interviewedCompanionships: activeInterviewed,
      ),
    );
  }

  // ------------------------------------------------------- liderança --

  /// Cadastra um líder responsável pelas entrevistas.
  ///
  /// Domínio separado do papel de Workspace: nada aqui infere autoridade
  /// eclesiástica do usuário logado.
  Future<MinisteringLeader> createLeader({
    required String callingId,
    required String displayLabel,
    required MinisteringLeadershipRole role,
  }) async {
    final safeLabel = _validatedLabel(displayLabel);
    final now = DateTime.now().toUtc();
    final id = 'leader-${_nextIdentifier()}';

    await _database
        .into(_database.ministeringLeaders)
        .insert(
          MinisteringLeadersCompanion.insert(
            id: id,
            callingId: callingId,
            displayLabel: safeLabel,
            role: role.storageValue,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return MinisteringLeader(
      id: id,
      displayLabel: safeLabel,
      role: role,
      isActive: true,
    );
  }

  Future<void> updateLeader({
    required String callingId,
    required String leaderId,
    required String displayLabel,
    required MinisteringLeadershipRole role,
  }) async {
    final safeLabel = _validatedLabel(displayLabel);
    final updated =
        await (_database.update(_database.ministeringLeaders)..where(
              (row) =>
                  row.id.equals(leaderId) & row.callingId.equals(callingId),
            ))
            .write(
              MinisteringLeadersCompanion(
                displayLabel: Value(safeLabel),
                role: Value(role.storageValue),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );

    if (updated == 0) throw const MinisteringRecordNotFoundException();
  }

  /// Desativa ou reativa um líder.
  ///
  /// Como o irmão ministrador, um líder com histórico é desativado, nunca
  /// apagado. Um líder inativo não pode ser escolhido para novas entrevistas,
  /// mas permanece nas entrevistas e nos agendamentos que já conduziu.
  Future<void> setLeaderActive({
    required String callingId,
    required String leaderId,
    required bool isActive,
  }) async {
    final updated =
        await (_database.update(_database.ministeringLeaders)..where(
              (row) =>
                  row.id.equals(leaderId) & row.callingId.equals(callingId),
            ))
            .write(
              MinisteringLeadersCompanion(
                isActive: Value(isActive),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );

    if (updated == 0) throw const MinisteringRecordNotFoundException();
  }

  /// O que cita este líder hoje: entrevistas realizadas e agendamentos abertos.
  Future<MinisteringRemovalCheck> inspectLeaderRemoval({
    required String callingId,
    required String leaderId,
  }) async {
    await _requireLeader(callingId: callingId, leaderId: leaderId);

    final interviews =
        await (_database.select(_database.ministeringInterviews)..where(
              (row) =>
                  row.callingId.equals(callingId) &
                  row.interviewerId.equals(leaderId),
            ))
            .get();
    final appointments =
        await (_database.select(_database.ministeringAppointments)..where(
              (row) =>
                  row.callingId.equals(callingId) &
                  row.interviewerId.equals(leaderId),
            ))
            .get();

    return MinisteringRemovalCheck(
      companionships: 0,
      interviews: interviews.length,
      appointments: appointments.length,
    );
  }

  /// Exclui definitivamente um líder que nunca foi usado.
  Future<void> deleteLeader({
    required String callingId,
    required String leaderId,
  }) async {
    await _database.transaction(() async {
      final check = await inspectLeaderRemoval(
        callingId: callingId,
        leaderId: leaderId,
      );
      if (!check.canDelete) {
        throw MinisteringRecordInUseException.leader(check);
      }

      await (_database.delete(_database.ministeringLeaders)..where(
            (row) => row.id.equals(leaderId) & row.callingId.equals(callingId),
          ))
          .go();
    });
  }

  Future<MinisteringBrother> createBrother({
    required String callingId,
    required String displayLabel,
  }) async {
    final safeLabel = _validatedLabel(displayLabel);
    final now = DateTime.now().toUtc();
    final id = 'brother-${_nextIdentifier()}';

    await _database
        .into(_database.ministeringBrothers)
        .insert(
          MinisteringBrothersCompanion.insert(
            id: id,
            callingId: callingId,
            displayLabel: safeLabel,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return MinisteringBrother(id: id, displayLabel: safeLabel, isActive: true);
  }

  Future<void> updateBrother({
    required String callingId,
    required String brotherId,
    required String displayLabel,
  }) async {
    final safeLabel = _validatedLabel(displayLabel);
    final updated =
        await (_database.update(_database.ministeringBrothers)..where(
              (row) =>
                  row.id.equals(brotherId) & row.callingId.equals(callingId),
            ))
            .write(
              MinisteringBrothersCompanion(
                displayLabel: Value(safeLabel),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );

    if (updated == 0) throw const MinisteringRecordNotFoundException();
  }

  /// Desativa ou reativa um irmão.
  ///
  /// Não existe exclusão: apagar alguém que já compôs dupla ou participou de
  /// entrevista destruiria histórico. O banco recusa a exclusão com RESTRICT.
  Future<void> setBrotherActive({
    required String callingId,
    required String brotherId,
    required bool isActive,
  }) async {
    final updated =
        await (_database.update(_database.ministeringBrothers)..where(
              (row) =>
                  row.id.equals(brotherId) & row.callingId.equals(callingId),
            ))
            .write(
              MinisteringBrothersCompanion(
                isActive: Value(isActive),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );

    if (updated == 0) throw const MinisteringRecordNotFoundException();
  }

  /// O que cita este irmão hoje.
  ///
  /// A tela chama antes de mostrar a ação de excluir, para nunca oferecer algo
  /// que vai falhar.
  Future<MinisteringRemovalCheck> inspectBrotherRemoval({
    required String callingId,
    required String brotherId,
  }) async {
    await _requireBrother(callingId: callingId, brotherId: brotherId);

    final memberships =
        await (_database.select(_database.ministeringCompanionshipMembers)
              ..where(
                (row) =>
                    row.callingId.equals(callingId) &
                    row.brotherId.equals(brotherId),
              ))
            .get();
    final participations =
        await (_database.select(_database.ministeringInterviewParticipants)
              ..where(
                (row) =>
                    row.callingId.equals(callingId) &
                    row.brotherId.equals(brotherId),
              ))
            .get();

    return MinisteringRemovalCheck(
      companionships: memberships
          .map((row) => row.companionshipId)
          .toSet()
          .length,
      interviews: participations.map((row) => row.interviewId).toSet().length,
    );
  }

  /// Exclui definitivamente um irmão que nunca foi usado.
  ///
  /// A checagem acontece dentro da transação da exclusão: fora dela, uma dupla
  /// criada no intervalo entre consultar e apagar passaria despercebida.
  Future<void> deleteBrother({
    required String callingId,
    required String brotherId,
  }) async {
    await _database.transaction(() async {
      final check = await inspectBrotherRemoval(
        callingId: callingId,
        brotherId: brotherId,
      );
      if (!check.canDelete) {
        throw MinisteringRecordInUseException.brother(check);
      }

      await (_database.delete(_database.ministeringBrothers)..where(
            (row) => row.id.equals(brotherId) & row.callingId.equals(callingId),
          ))
          .go();
    });
  }

  Future<String> createCompanionship({
    required String callingId,
    required List<String> brotherIds,
    String? displayLabel,
  }) async {
    final safeLabel = displayLabel == null || displayLabel.trim().isEmpty
        ? null
        : _validatedLabel(displayLabel);
    final id = 'companionship-${_nextIdentifier()}';
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _assertUsableMembers(callingId: callingId, brotherIds: brotherIds);

      await _database
          .into(_database.ministeringCompanionships)
          .insert(
            MinisteringCompanionshipsCompanion.insert(
              id: id,
              callingId: callingId,
              displayLabel: Value(safeLabel),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _writeMembers(
        callingId: callingId,
        companionshipId: id,
        brotherIds: brotherIds,
        now: now,
      );
    });

    return id;
  }

  Future<void> updateCompanionship({
    required String callingId,
    required String companionshipId,
    required List<String> brotherIds,
    String? displayLabel,
  }) async {
    final safeLabel = displayLabel == null || displayLabel.trim().isEmpty
        ? null
        : _validatedLabel(displayLabel);
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _assertUsableMembers(callingId: callingId, brotherIds: brotherIds);

      final updated =
          await (_database.update(_database.ministeringCompanionships)..where(
                (row) =>
                    row.id.equals(companionshipId) &
                    row.callingId.equals(callingId),
              ))
              .write(
                MinisteringCompanionshipsCompanion(
                  displayLabel: Value(safeLabel),
                  updatedAt: Value(now),
                ),
              );

      if (updated == 0) throw const MinisteringRecordNotFoundException();

      await (_database.delete(
        _database.ministeringCompanionshipMembers,
      )..where((row) => row.companionshipId.equals(companionshipId))).go();

      await _writeMembers(
        callingId: callingId,
        companionshipId: companionshipId,
        brotherIds: brotherIds,
        now: now,
      );
    });
  }

  /// Desativa ou reativa uma dupla.
  ///
  /// Dupla inativa sai do denominador do trimestre, mas suas entrevistas
  /// anteriores permanecem registradas. Reativar exige que todos os integrantes
  /// ainda estejam ativos; do contrário o painel voltaria a contar uma dupla
  /// que não pode ser usada em novos registros. Desativar cancela um
  /// agendamento aberto: uma dupla inativa não tem plano de entrevista.
  Future<void> setCompanionshipActive({
    required String callingId,
    required String companionshipId,
    required bool isActive,
  }) async {
    await _database.transaction(() async {
      if (isActive) {
        final members = await _memberIds(
          callingId: callingId,
          companionshipId: companionshipId,
        );
        if (members.isEmpty) throw const MinisteringRecordNotFoundException();
        await _assertUsableMembers(
          callingId: callingId,
          brotherIds: members.toList(growable: false),
        );
      }

      final updated =
          await (_database.update(_database.ministeringCompanionships)..where(
                (row) =>
                    row.id.equals(companionshipId) &
                    row.callingId.equals(callingId),
              ))
              .write(
                MinisteringCompanionshipsCompanion(
                  isActive: Value(isActive),
                  updatedAt: Value(DateTime.now().toUtc()),
                ),
              );

      if (updated == 0) throw const MinisteringRecordNotFoundException();

      if (!isActive) {
        await (_database.delete(_database.ministeringAppointments)..where(
              (row) =>
                  row.companionshipId.equals(companionshipId) &
                  row.callingId.equals(callingId),
            ))
            .go();
      }
    });
  }

  /// O que impede excluir uma dupla: entrevistas realizadas ou um agendamento
  /// aberto.
  Future<MinisteringRemovalCheck> inspectCompanionshipRemoval({
    required String callingId,
    required String companionshipId,
  }) async {
    final members = await _memberIds(
      callingId: callingId,
      companionshipId: companionshipId,
    );
    if (members.isEmpty) throw const MinisteringRecordNotFoundException();

    final interviews =
        await (_database.select(_database.ministeringInterviews)..where(
              (row) =>
                  row.callingId.equals(callingId) &
                  row.companionshipId.equals(companionshipId),
            ))
            .get();
    final appointments =
        await (_database.select(_database.ministeringAppointments)..where(
              (row) =>
                  row.callingId.equals(callingId) &
                  row.companionshipId.equals(companionshipId),
            ))
            .get();

    // A composição em si não é histórico: os integrantes continuam existindo
    // como irmãos. O que não pode sumir é a entrevista; o agendamento aberto
    // deve ser cancelado de propósito, não levado junto em silêncio.
    return MinisteringRemovalCheck(
      companionships: 0,
      interviews: interviews.length,
      appointments: appointments.length,
    );
  }

  /// Exclui uma dupla montada por engano, desde que não tenha entrevistas.
  ///
  /// A FK de entrevista para dupla é CASCADE, então apagar uma dupla com
  /// histórico levaria as entrevistas junto e em silêncio. A checagem roda
  /// dentro da mesma transação da exclusão justamente por isso.
  Future<void> deleteCompanionship({
    required String callingId,
    required String companionshipId,
  }) async {
    await _database.transaction(() async {
      final check = await inspectCompanionshipRemoval(
        callingId: callingId,
        companionshipId: companionshipId,
      );
      if (!check.canDelete) {
        throw MinisteringRecordInUseException.companionship(check);
      }

      await (_database.delete(_database.ministeringCompanionships)..where(
            (row) =>
                row.id.equals(companionshipId) &
                row.callingId.equals(callingId),
          ))
          .go();
    });
  }

  // ---------------------------------------------------- agendamento --

  /// Agenda uma entrevista para uma dupla pendente.
  ///
  /// `Dupla → data/hora → entrevistador → salvar`. O entrevistador é sempre
  /// escolhido — nunca inferido. No máximo um agendamento aberto por dupla.
  Future<MinisteringAppointment> scheduleInterview({
    required String callingId,
    required String companionshipId,
    required DateTime scheduledAt,
    required String interviewerId,
  }) async {
    final id = 'appointment-${_nextIdentifier()}';
    final now = DateTime.now().toUtc();
    final instant = _validatedScheduledInstant(scheduledAt);

    await _database.transaction(() async {
      await _requireActiveCompanionship(
        callingId: callingId,
        companionshipId: companionshipId,
      );
      await _assertUsableInterviewer(
        callingId: callingId,
        interviewerId: interviewerId,
      );

      final existing =
          await (_database.select(_database.ministeringAppointments)..where(
                (row) =>
                    row.callingId.equals(callingId) &
                    row.companionshipId.equals(companionshipId),
              ))
              .getSingleOrNull();
      if (existing != null) {
        throw const CompanionshipAlreadyScheduledException();
      }

      await _database
          .into(_database.ministeringAppointments)
          .insert(
            MinisteringAppointmentsCompanion.insert(
              id: id,
              callingId: callingId,
              companionshipId: companionshipId,
              interviewerId: interviewerId,
              scheduledAt: instant,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    return MinisteringAppointment(
      id: id,
      companionshipId: companionshipId,
      interviewerId: interviewerId,
      scheduledAt: instant,
    );
  }

  /// Reagenda: muda a data/hora, o entrevistador, ou ambos, na mesma linha.
  Future<void> rescheduleInterview({
    required String callingId,
    required String appointmentId,
    required DateTime scheduledAt,
    required String interviewerId,
  }) async {
    final instant = _validatedScheduledInstant(scheduledAt);

    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.ministeringAppointments)..where(
                (row) =>
                    row.id.equals(appointmentId) &
                    row.callingId.equals(callingId),
              ))
              .getSingleOrNull();
      if (existing == null) throw const MinisteringRecordNotFoundException();

      await _assertUsableInterviewer(
        callingId: callingId,
        interviewerId: interviewerId,
      );

      await (_database.update(
        _database.ministeringAppointments,
      )..where((row) => row.id.equals(appointmentId))).write(
        MinisteringAppointmentsCompanion(
          scheduledAt: Value(instant),
          interviewerId: Value(interviewerId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  /// Cancela um agendamento. Apaga a linha do plano e **não toca** nas
  /// entrevistas já realizadas — cancelar um agendamento nunca é apagar uma
  /// entrevista.
  Future<void> cancelAppointment({
    required String callingId,
    required String appointmentId,
  }) async {
    final removed =
        await (_database.delete(_database.ministeringAppointments)..where(
              (row) =>
                  row.id.equals(appointmentId) &
                  row.callingId.equals(callingId),
            ))
            .go();

    if (removed == 0) throw const MinisteringRecordNotFoundException();
  }

  /// Conclui um agendamento: cria a entrevista realizada mantendo o
  /// entrevistador do plano e remove o agendamento.
  Future<MinisteringInterview> completeAppointment({
    required String callingId,
    required String appointmentId,
    required DateTime completedOn,
    required List<String> participantBrotherIds,
  }) => _database.transaction(() async {
    final appointment =
        await (_database.select(_database.ministeringAppointments)..where(
              (row) =>
                  row.id.equals(appointmentId) &
                  row.callingId.equals(callingId),
            ))
            .getSingleOrNull();
    if (appointment == null) throw const MinisteringRecordNotFoundException();

    final interview = await _writeInterview(
      callingId: callingId,
      companionshipId: appointment.companionshipId,
      completedOn: completedOn,
      participantBrotherIds: participantBrotherIds,
      interviewerId: appointment.interviewerId,
    );

    await (_database.delete(
      _database.ministeringAppointments,
    )..where((row) => row.id.equals(appointmentId))).go();

    return interview;
  });

  /// Registra uma entrevista realizada.
  ///
  /// Várias entrevistas da mesma dupla no mesmo trimestre são permitidas: o
  /// Manual exige *pelo menos* uma, e proibir a segunda apagaria histórico real.
  /// A dupla continua contando uma vez só no resumo.
  ///
  /// [interviewerId] é anulável só por compatibilidade com entrevistas gravadas
  /// antes do schema v4; toda tela da v4 em diante informa o entrevistador.
  Future<MinisteringInterview> recordInterview({
    required String callingId,
    required String companionshipId,
    required DateTime completedOn,
    required List<String> participantBrotherIds,
    String? interviewerId,
  }) => _database.transaction(
    () => _writeInterview(
      callingId: callingId,
      companionshipId: companionshipId,
      completedOn: completedOn,
      participantBrotherIds: participantBrotherIds,
      interviewerId: interviewerId,
    ),
  );

  /// Corrige uma entrevista já registrada.
  ///
  /// Errar a data, o participante ou o entrevistador é o engano comum, e sem
  /// isto a única saída seria apagar e registrar de novo — o que perde o
  /// registro original e parece, para quem olha, que a entrevista nunca
  /// aconteceu.
  Future<void> updateInterview({
    required String callingId,
    required String interviewId,
    required DateTime completedOn,
    required List<String> participantBrotherIds,
    String? interviewerId,
  }) async {
    final date = calendarDate(completedOn);
    if (date.isAfter(calendarDate(DateTime.now()))) {
      throw const FutureInterviewDateException();
    }
    if (participantBrotherIds.isEmpty) {
      throw const InterviewWithoutParticipantsException();
    }

    final participants = participantBrotherIds.toSet().toList(growable: false);

    await _database.transaction(() async {
      final interview =
          await (_database.select(_database.ministeringInterviews)..where(
                (row) =>
                    row.id.equals(interviewId) &
                    row.callingId.equals(callingId),
              ))
              .getSingleOrNull();
      if (interview == null) throw const MinisteringRecordNotFoundException();

      final members = await _memberIds(
        callingId: callingId,
        companionshipId: interview.companionshipId,
      );
      if (!members.containsAll(participants)) {
        throw const ParticipantOutsideCompanionshipException();
      }
      if (interviewerId != null) {
        // Corrigir aceita atribuir um entrevistador a uma entrevista antiga
        // sem um, mas não exige que ele ainda esteja ativo: pode ter sido
        // liberado do chamado depois de conduzir a entrevista.
        await _assertUsableInterviewer(
          callingId: callingId,
          interviewerId: interviewerId,
          requireActive: false,
        );
      }

      await (_database.update(
        _database.ministeringInterviews,
      )..where((row) => row.id.equals(interviewId))).write(
        MinisteringInterviewsCompanion(
          completedAt: Value(date),
          interviewerId: Value(interviewerId),
        ),
      );

      await (_database.delete(
        _database.ministeringInterviewParticipants,
      )..where((row) => row.interviewId.equals(interviewId))).go();

      await _database.batch((batch) {
        batch.insertAll(_database.ministeringInterviewParticipants, [
          for (final brotherId in participants)
            MinisteringInterviewParticipantsCompanion.insert(
              interviewId: interviewId,
              brotherId: brotherId,
              callingId: callingId,
              companionshipId: interview.companionshipId,
            ),
        ]);
      });
    });
  }

  /// Remove uma entrevista registrada por engano. Participantes vão em cascata.
  Future<void> deleteInterview({
    required String callingId,
    required String interviewId,
  }) async {
    final removed =
        await (_database.delete(_database.ministeringInterviews)..where(
              (row) =>
                  row.id.equals(interviewId) & row.callingId.equals(callingId),
            ))
            .go();

    if (removed == 0) throw const MinisteringRecordNotFoundException();
  }

  /// Entrevistas de uma dupla, da mais recente para a mais antiga.
  Future<List<MinisteringInterview>> listInterviews({
    required String callingId,
    required String companionshipId,
  }) async {
    final rows =
        await (_database.select(_database.ministeringInterviews)
              ..where(
                (row) =>
                    row.callingId.equals(callingId) &
                    row.companionshipId.equals(companionshipId),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.completedAt)]))
            .get();

    final result = <MinisteringInterview>[];
    for (final row in rows) {
      final participants = await (_database.select(
        _database.ministeringInterviewParticipants,
      )..where((item) => item.interviewId.equals(row.id))).get();
      result.add(
        MinisteringInterview(
          id: row.id,
          companionshipId: row.companionshipId,
          // O Drift guarda `DateTime` como epoch e devolve no fuso do
          // aparelho. Sem voltar para UTC, a meia-noite normalizada na
          // gravação vira o dia anterior ao ser lida a oeste de Greenwich —
          // e uma entrevista no primeiro dia do trimestre cairia no anterior.
          completedAt: row.completedAt.toUtc(),
          interviewerId: row.interviewerId,
          participantIds: participants
              .map((item) => item.brotherId)
              .toList(growable: false),
        ),
      );
    }
    return result;
  }

  // ---------------------------------------------------------------- privado --

  /// Cria a entrevista realizada e seus participantes. Compartilhado pelo
  /// registro direto e pela conclusão de um agendamento; roda sempre dentro de
  /// uma transação.
  Future<MinisteringInterview> _writeInterview({
    required String callingId,
    required String companionshipId,
    required DateTime completedOn,
    required List<String> participantBrotherIds,
    required String? interviewerId,
  }) async {
    final date = calendarDate(completedOn);
    if (date.isAfter(calendarDate(DateTime.now()))) {
      throw const FutureInterviewDateException();
    }
    if (participantBrotherIds.isEmpty) {
      throw const InterviewWithoutParticipantsException();
    }

    final participants = participantBrotherIds.toSet().toList(growable: false);
    final id = 'interview-${_nextIdentifier()}';
    final now = DateTime.now().toUtc();

    final members = await _memberIds(
      callingId: callingId,
      companionshipId: companionshipId,
    );
    if (members.isEmpty) throw const MinisteringRecordNotFoundException();
    if (!members.containsAll(participants)) {
      throw const ParticipantOutsideCompanionshipException();
    }
    if (interviewerId != null) {
      // Concluir carrega o entrevistador do agendamento mesmo que ele já tenha
      // sido liberado do chamado: conduziu a entrevista antes de sair.
      await _assertUsableInterviewer(
        callingId: callingId,
        interviewerId: interviewerId,
        requireActive: false,
      );
    }

    await _database
        .into(_database.ministeringInterviews)
        .insert(
          MinisteringInterviewsCompanion.insert(
            id: id,
            callingId: callingId,
            companionshipId: companionshipId,
            interviewerId: Value(interviewerId),
            completedAt: date,
            createdAt: now,
          ),
        );

    await _database.batch((batch) {
      batch.insertAll(_database.ministeringInterviewParticipants, [
        for (final brotherId in participants)
          MinisteringInterviewParticipantsCompanion.insert(
            interviewId: id,
            brotherId: brotherId,
            callingId: callingId,
            companionshipId: companionshipId,
          ),
      ]);
    });

    return MinisteringInterview(
      id: id,
      companionshipId: companionshipId,
      completedAt: date,
      participantIds: participants,
      interviewerId: interviewerId,
    );
  }

  Future<List<MinisteringLeader>> _loadLeaders(String callingId) async {
    final rows = await (_database.select(
      _database.ministeringLeaders,
    )..where((row) => row.callingId.equals(callingId))).get();

    final leaders = rows
        .map(
          (row) => MinisteringLeader(
            id: row.id,
            displayLabel: row.displayLabel,
            role: MinisteringLeadershipRole.fromStorage(row.role),
            isActive: row.isActive,
          ),
        )
        .toList();
    // Presidência primeiro, depois pelos rótulos: a lista segue a hierarquia.
    leaders.sort((a, b) {
      final byRole = a.role.index.compareTo(b.role.index);
      return byRole != 0 ? byRole : a.displayLabel.compareTo(b.displayLabel);
    });
    return leaders;
  }

  Future<List<MinisteringAppointment>> _loadAppointments(
    String callingId,
  ) async {
    final rows =
        await (_database.select(_database.ministeringAppointments)
              ..where((row) => row.callingId.equals(callingId))
              ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
            .get();

    return rows
        .map(
          (row) => MinisteringAppointment(
            id: row.id,
            companionshipId: row.companionshipId,
            interviewerId: row.interviewerId,
            // Instante puro: guardado em UTC, volta em UTC, a tela converte
            // para o fuso do aparelho ao formatar.
            scheduledAt: row.scheduledAt.toUtc(),
          ),
        )
        .toList(growable: false);
  }

  /// Garante que o líder existe neste chamado e, por padrão, que está ativo.
  Future<void> _assertUsableInterviewer({
    required String callingId,
    required String interviewerId,
    bool requireActive = true,
  }) async {
    final row =
        await (_database.select(_database.ministeringLeaders)..where(
              (item) =>
                  item.id.equals(interviewerId) &
                  item.callingId.equals(callingId),
            ))
            .getSingleOrNull();
    if (row == null) throw const MinisteringRecordNotFoundException();
    if (requireActive && !row.isActive) {
      throw const InactiveInterviewerException();
    }
  }

  /// Garante que o líder existe neste chamado.
  Future<void> _requireLeader({
    required String callingId,
    required String leaderId,
  }) async {
    final row =
        await (_database.select(_database.ministeringLeaders)..where(
              (item) =>
                  item.id.equals(leaderId) & item.callingId.equals(callingId),
            ))
            .getSingleOrNull();
    if (row == null) throw const MinisteringRecordNotFoundException();
  }

  /// Garante que a dupla existe neste chamado e está ativa: só duplas ativas
  /// recebem agendamento.
  Future<void> _requireActiveCompanionship({
    required String callingId,
    required String companionshipId,
  }) async {
    final row =
        await (_database.select(_database.ministeringCompanionships)..where(
              (item) =>
                  item.id.equals(companionshipId) &
                  item.callingId.equals(callingId),
            ))
            .getSingleOrNull();
    if (row == null || !row.isActive) {
      throw const MinisteringRecordNotFoundException();
    }
  }

  Future<List<MinisteringBrother>> _loadBrothers(String callingId) async {
    final rows =
        await (_database.select(_database.ministeringBrothers)
              ..where((row) => row.callingId.equals(callingId))
              ..orderBy([(row) => OrderingTerm.asc(row.displayLabel)]))
            .get();

    return rows
        .map(
          (row) => MinisteringBrother(
            id: row.id,
            displayLabel: row.displayLabel,
            isActive: row.isActive,
          ),
        )
        .toList(growable: false);
  }

  Future<List<MinisteringCompanionship>> _loadCompanionships(
    String callingId,
    List<MinisteringBrother> brothers,
  ) async {
    final byId = {for (final brother in brothers) brother.id: brother};

    final rows =
        await (_database.select(_database.ministeringCompanionships)
              ..where((row) => row.callingId.equals(callingId))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();

    final memberRows = await (_database.select(
      _database.ministeringCompanionshipMembers,
    )..where((row) => row.callingId.equals(callingId))).get();

    final grouped = <String, List<MinisteringBrother>>{};
    for (final member in memberRows) {
      final brother = byId[member.brotherId];
      if (brother == null) continue;
      grouped.putIfAbsent(member.companionshipId, () => []).add(brother);
    }
    for (final members in grouped.values) {
      members.sort((a, b) => a.displayLabel.compareTo(b.displayLabel));
    }

    return rows
        .map(
          (row) => MinisteringCompanionship(
            id: row.id,
            displayLabel: row.displayLabel,
            isActive: row.isActive,
            members: grouped[row.id] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  /// Duplas com ao menos uma entrevista dentro do trimestre.
  ///
  /// O conjunto é o equivalente em Dart do `COUNT(DISTINCT companionship_id)`:
  /// várias entrevistas da mesma dupla colapsam em uma entrada.
  Future<Set<String>> _interviewedCompanionshipIds({
    required String callingId,
    required Quarter quarter,
  }) async {
    final rows =
        await (_database.selectOnly(_database.ministeringInterviews)
              ..addColumns([_database.ministeringInterviews.companionshipId])
              ..where(
                _database.ministeringInterviews.callingId.equals(callingId) &
                    _database.ministeringInterviews.completedAt
                        .isBiggerOrEqualValue(quarter.start) &
                    _database.ministeringInterviews.completedAt
                        .isSmallerThanValue(quarter.nextStart),
              )
              ..groupBy([_database.ministeringInterviews.companionshipId]))
            .get();

    return rows
        .map(
          (row) => row.read(_database.ministeringInterviews.companionshipId)!,
        )
        .toSet();
  }

  /// Garante que o irmão existe neste chamado.
  Future<void> _requireBrother({
    required String callingId,
    required String brotherId,
  }) async {
    final row =
        await (_database.select(_database.ministeringBrothers)..where(
              (item) =>
                  item.id.equals(brotherId) & item.callingId.equals(callingId),
            ))
            .getSingleOrNull();
    if (row == null) throw const MinisteringRecordNotFoundException();
  }

  Future<Set<String>> _memberIds({
    required String callingId,
    required String companionshipId,
  }) async {
    final rows =
        await (_database.select(_database.ministeringCompanionshipMembers)
              ..where(
                (row) =>
                    row.callingId.equals(callingId) &
                    row.companionshipId.equals(companionshipId),
              ))
            .get();

    return rows.map((row) => row.brotherId).toSet();
  }

  /// Valida a composição antes de escrever: tamanho, repetição, pertencimento
  /// ao chamado e atividade dos irmãos.
  Future<void> _assertUsableMembers({
    required String callingId,
    required List<String> brotherIds,
  }) async {
    final unique = brotherIds.toSet();
    if (unique.length != brotherIds.length) {
      throw const InvalidCompanionshipSizeException();
    }
    if (unique.length < 2 || unique.length > 3) {
      throw const InvalidCompanionshipSizeException();
    }

    final rows =
        await (_database.select(_database.ministeringBrothers)..where(
              (row) => row.callingId.equals(callingId) & row.id.isIn(unique),
            ))
            .get();

    if (rows.length != unique.length) {
      throw const MinisteringRecordNotFoundException();
    }
    if (rows.any((row) => !row.isActive)) {
      throw const InactiveBrotherException();
    }
  }

  Future<void> _writeMembers({
    required String callingId,
    required String companionshipId,
    required List<String> brotherIds,
    required DateTime now,
  }) async {
    await _database.batch((batch) {
      batch.insertAll(_database.ministeringCompanionshipMembers, [
        for (final brotherId in brotherIds)
          MinisteringCompanionshipMembersCompanion.insert(
            companionshipId: companionshipId,
            brotherId: brotherId,
            callingId: callingId,
            createdAt: now,
          ),
      ]);
    });
  }

  DateTime _validatedScheduledInstant(DateTime value) {
    final instant = scheduledInstant(value);
    final currentMinute = scheduledInstant(DateTime.now());
    if (instant.isBefore(currentMinute)) {
      throw const PastAppointmentDateTimeException();
    }
    return instant;
  }

  String _validatedLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const InvalidMinisteringLabelException(
        'Informe uma identificação.',
      );
    }
    if (trimmed.length > 60) {
      throw const InvalidMinisteringLabelException('Use até 60 caracteres.');
    }
    return trimmed;
  }

  String _nextIdentifier() {
    final current = DateTime.now().toUtc().microsecondsSinceEpoch;
    _lastIdentifier = current > _lastIdentifier ? current : _lastIdentifier + 1;
    return _lastIdentifier.toString();
  }
}
