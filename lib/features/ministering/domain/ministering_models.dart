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

/// Reapresenta uma data de calendário UTC como data local, para formatar.
///
/// `MaterialLocalizations` formata pelo fuso do aparelho. Passar direto a
/// meia-noite UTC faria a tela mostrar o dia anterior; o que se quer exibir é
/// a data em si, então ela é remontada com os mesmos campos.
DateTime displayCalendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

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
  });

  final String id;
  final String companionshipId;
  final DateTime completedAt;
  final List<String> participantIds;

  Quarter get quarter => Quarter.of(completedAt);
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
    required this.companionships,
    required this.summary,
    required this.interviewedCompanionshipIds,
  });

  final String callingId;
  final List<MinisteringBrother> brothers;
  final List<MinisteringCompanionship> companionships;
  final QuarterSummary summary;

  /// Duplas já entrevistadas no trimestre do resumo.
  final Set<String> interviewedCompanionshipIds;

  List<MinisteringBrother> get activeBrothers =>
      brothers.where((brother) => brother.isActive).toList(growable: false);

  List<MinisteringCompanionship> get activeCompanionships =>
      companionships.where((item) => item.isActive).toList(growable: false);

  List<MinisteringCompanionship> get pendingCompanionships =>
      activeCompanionships
          .where((item) => !interviewedCompanionshipIds.contains(item.id))
          .toList(growable: false);

  bool isInterviewed(String companionshipId) =>
      interviewedCompanionshipIds.contains(companionshipId);
}
