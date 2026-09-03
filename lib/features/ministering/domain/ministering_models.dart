/// Trimestre civil.
///
/// Não é entidade persistida: é derivado da data da entrevista sempre que
/// preciso. Guardar `year` e `quarter` junto da entrevista criaria dois valores
/// que podem divergir; derivar torna a divergência impossível.
class Quarter {
  const Quarter(this.year, this.number)
    : assert(number >= 1 && number <= 4, 'trimestre deve estar entre 1 e 4');

  /// Trimestre a que uma data de calendário pertence.
  factory Quarter.of(DateTime date) =>
      Quarter(date.year, ((date.month - 1) ~/ 3) + 1);

  final int year;
  final int number;

  /// Primeiro instante do trimestre, inclusivo.
  DateTime get start => DateTime.utc(year, (number - 1) * 3 + 1);

  /// Primeiro instante do trimestre seguinte, exclusivo.
  ///
  /// A contagem usa `start <= completedAt < nextStart`, então o limite superior
  /// nunca precisa de aritmética de "último dia do mês".
  DateTime get nextStart =>
      number == 4 ? DateTime.utc(year + 1) : DateTime.utc(year, number * 3 + 1);

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(nextStart);

  String get label => '$numberº trimestre de $year';

  @override
  bool operator ==(Object other) =>
      other is Quarter && other.year == year && other.number == number;

  @override
  int get hashCode => Object.hash(year, number);

  @override
  String toString() => 'Quarter($year, $number)';
}

/// Converte uma data escolhida pelo usuário em data de calendário.
///
/// A entrevista aconteceu num dia, não num instante. Normalizar para meia-noite
/// UTC faz o valor representar a data em si — sem isso, uma entrevista em 30/09
/// à noite poderia cair no trimestre seguinte dependendo do fuso do aparelho.
DateTime calendarDate(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day);

/// Normaliza o instante de um agendamento para o minuto inteiro, em UTC.
///
/// Um agendamento tem precisão de minuto — é o que os seletores de data e hora
/// oferecem. Truncar na gravação faz o valor voltar do banco idêntico ao que
/// entrou (o Drift guarda segundos inteiros) e evita comparações frágeis.
DateTime scheduledInstant(DateTime value) {
  const minute = 60 * 1000;
  return DateTime.fromMillisecondsSinceEpoch(
    (value.toUtc().millisecondsSinceEpoch ~/ minute) * minute,
    isUtc: true,
  );
}

/// Reapresenta uma data de calendário UTC como data local, para formatar.
///
/// `MaterialLocalizations` formata pelo fuso do aparelho. Passar direto a
/// meia-noite UTC faria a tela mostrar o dia anterior; o que se quer exibir é
/// a data em si, então ela é remontada com os mesmos campos.
DateTime displayCalendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Cargo na presidência do Quórum de Élderes de quem conduz as entrevistas.
///
/// Domínio eclesiástico, separado do `WorkspaceRole` técnico. A ordem de
/// declaração é a hierarquia usada para ordenar a lista de líderes.
enum MinisteringLeadershipRole {
  quorumPresident('QUORUM_PRESIDENT', 'Presidente do Quórum de Élderes'),
  firstCounselor('FIRST_COUNSELOR', '1º Conselheiro'),
  secondCounselor('SECOND_COUNSELOR', '2º Conselheiro');

  const MinisteringLeadershipRole(this.storageValue, this.label);

  /// Valor persistido na coluna `role`.
  final String storageValue;

  /// Texto exibido ao usuário.
  final String label;

  static MinisteringLeadershipRole fromStorage(String value) =>
      values.firstWhere(
        (role) => role.storageValue == value,
        orElse: () => MinisteringLeadershipRole.quorumPresident,
      );
}

/// Líder responsável pelas entrevistas de ministração.
///
/// Identificação mínima, como a do irmão ministrador — ver
/// [ADR 0014](../../../docs/adr/0014-ministering-leadership-domain.md). Não
/// guarda telefone, endereço, número de registro nem notas.
class MinisteringLeader {
  const MinisteringLeader({
    required this.id,
    required this.displayLabel,
    required this.role,
    required this.isActive,
  });

  final String id;

  /// Identificação mínima — primeiro nome ou iniciais.
  final String displayLabel;
  final MinisteringLeadershipRole role;
  final bool isActive;

  /// Rótulo curto para listas e cartões: "Irmão P · Presidente do Quórum".
  String get title => '$displayLabel · ${role.label}';
}

/// Irmão ministrador.
///
/// Não é membro do quórum: um jovem ordenado mestre ou sacerdote pode compor
/// uma dupla sem pertencer ao Quórum de Élderes.
class MinisteringBrother {
  const MinisteringBrother({
    required this.id,
    required this.displayLabel,
    required this.isActive,
  });

  final String id;

  /// Identificação mínima — primeiro nome ou iniciais. Continua sendo dado
  /// pessoal: identifica alguém dentro de uma ala.
  final String displayLabel;
  final bool isActive;
}

/// Dupla de ministração, com seus integrantes já resolvidos.
class MinisteringCompanionship {
  const MinisteringCompanionship({
    required this.id,
    required this.members,
    required this.isActive,
    this.displayLabel,
  });

  final String id;
  final String? displayLabel;
  final List<MinisteringBrother> members;
  final bool isActive;

  /// Nome exibido: o rótulo próprio quando existe, senão os integrantes.
  String get title =>
      displayLabel ?? members.map((member) => member.displayLabel).join(' · ');
}

/// Entrevista realizada.
///
/// Não há status: a existência do registro é o próprio fato de ter ocorrido.
class MinisteringInterview {
  const MinisteringInterview({
    required this.id,
    required this.companionshipId,
    required this.completedAt,
    required this.participantIds,
    this.interviewerId,
  });

  final String id;
  final String companionshipId;
  final DateTime completedAt;
  final List<String> participantIds;

  /// Líder que conduziu a entrevista. Nulo apenas em entrevistas gravadas antes
  /// do schema v4, quando o módulo ainda não registrava a liderança.
  final String? interviewerId;

  Quarter get quarter => Quarter.of(completedAt);
}

/// Entrevista agendada e ainda não realizada.
///
/// Cancelar apaga o agendamento; concluir cria a [MinisteringInterview] e apaga
/// o agendamento. Cancelar um agendamento nunca toca em entrevistas já
/// realizadas — ver
/// [ADR 0015](../../../docs/adr/0015-ministering-scheduling-model.md).
class MinisteringAppointment {
  const MinisteringAppointment({
    required this.id,
    required this.companionshipId,
    required this.interviewerId,
    required this.scheduledAt,
  });

  final String id;
  final String companionshipId;
  final String interviewerId;

  /// Instante planejado, com hora do dia, no fuso do aparelho.
  final DateTime scheduledAt;

  /// Passou da hora e continua aberto: a tela sinaliza para o secretário
  /// reagendar, concluir ou cancelar.
  bool isOverdueAt(DateTime now) => scheduledAt.isBefore(now);
}

/// O que impede — ou não — excluir um cadastro definitivamente.
///
/// A tela pergunta isto **antes** de oferecer a ação, para o usuário nunca
/// escolher "Excluir" e receber um erro no lugar. Quando há vínculo, os
/// números explicam o motivo em vez de deixar a recusa parecendo arbitrária.
class MinisteringRemovalCheck {
  const MinisteringRemovalCheck({
    required this.companionships,
    required this.interviews,
    this.appointments = 0,
  });

  /// Duplas que citam o cadastro, ativas ou não. Sempre zero para líderes.
  final int companionships;

  /// Entrevistas realizadas que citam o cadastro.
  final int interviews;

  /// Agendamentos abertos que citam o cadastro. É zero para irmãos; duplas e
  /// lideranças podem ser citadas diretamente por um agendamento.
  final int appointments;

  /// Só é seguro apagar o que nunca foi usado.
  bool get canDelete =>
      companionships == 0 && interviews == 0 && appointments == 0;

  bool get hasHistory => interviews > 0;
}

/// Números do trimestre exibidos no painel.
///
/// [interviewed] conta **duplas**, não entrevistas: várias entrevistas da mesma
/// dupla no trimestre contam uma vez só.
class QuarterSummary {
  const QuarterSummary({
    required this.quarter,
    required this.activeCompanionships,
    required this.interviewedCompanionships,
  });

  final Quarter quarter;
  final int activeCompanionships;
  final int interviewedCompanionships;

  int get pending => activeCompanionships - interviewedCompanionships;

  /// Fração apenas para a barra de progresso.
  ///
  /// Nunca exibida como percentual isolado: o número mede trabalho
  /// administrativo do secretário, não desempenho espiritual de ninguém.
  double get progress => activeCompanionships == 0
      ? 0
      : interviewedCompanionships / activeCompanionships;
}

/// Tudo que o painel precisa, numa leitura só.
class MinisteringModuleState {
  const MinisteringModuleState({
    required this.callingId,
    required this.brothers,
    required this.leaders,
    required this.companionships,
    required this.appointments,
    required this.summary,
    required this.interviewedCompanionshipIds,
  });

  final String callingId;
  final List<MinisteringBrother> brothers;
  final List<MinisteringLeader> leaders;
  final List<MinisteringCompanionship> companionships;

  /// Agendamentos abertos do chamado, da data mais próxima para a mais distante.
  final List<MinisteringAppointment> appointments;
  final QuarterSummary summary;

  /// Duplas já entrevistadas no trimestre do resumo.
  final Set<String> interviewedCompanionshipIds;

  List<MinisteringBrother> get activeBrothers =>
      brothers.where((brother) => brother.isActive).toList(growable: false);

  List<MinisteringLeader> get activeLeaders =>
      leaders.where((leader) => leader.isActive).toList(growable: false);

  List<MinisteringCompanionship> get activeCompanionships =>
      companionships.where((item) => item.isActive).toList(growable: false);

  /// Duplas com um agendamento aberto.
  Set<String> get scheduledCompanionshipIds =>
      appointments.map((appointment) => appointment.companionshipId).toSet();

  /// Duplas ativas que ainda não foram entrevistadas no trimestre **nem** têm
  /// agendamento aberto: são as que pedem uma ação do secretário. As agendadas
  /// aparecem em "Próximas entrevistas", não aqui.
  List<MinisteringCompanionship> get pendingCompanionships {
    final scheduled = scheduledCompanionshipIds;
    return activeCompanionships
        .where(
          (item) =>
              !interviewedCompanionshipIds.contains(item.id) &&
              !scheduled.contains(item.id),
        )
        .toList(growable: false);
  }

  bool isInterviewed(String companionshipId) =>
      interviewedCompanionshipIds.contains(companionshipId);

  bool isScheduled(String companionshipId) =>
      scheduledCompanionshipIds.contains(companionshipId);

  /// Agendamento aberto de uma dupla, se houver.
  MinisteringAppointment? appointmentFor(String companionshipId) {
    for (final appointment in appointments) {
      if (appointment.companionshipId == companionshipId) return appointment;
    }
    return null;
  }

  MinisteringLeader? leaderById(String? leaderId) {
    if (leaderId == null) return null;
    for (final leader in leaders) {
      if (leader.id == leaderId) return leader;
    }
    return null;
  }

  MinisteringCompanionship? companionshipById(String companionshipId) {
    for (final companionship in companionships) {
      if (companionship.id == companionshipId) return companionship;
    }
    return null;
  }
}
