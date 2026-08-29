import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('WorkspaceRow')
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppUserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MembershipRow')
class Memberships extends Table {
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get role => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {workspaceId, userId};
}

@DataClassName('CallingRow')
class Callings extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get moduleKey => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (workspace_id, user_id) '
        'REFERENCES memberships (workspace_id, user_id) ON DELETE CASCADE',
  ];
}

@DataClassName('AppPreferenceRow')
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Irmão ministrador.
///
/// Não é "membro do quórum": um jovem ordenado mestre ou sacerdote pode compor
/// uma dupla sem pertencer ao Quórum de Élderes. O domínio representa quem
/// ministra, não quem pertence ao quórum.
///
/// `displayLabel` é identificação mínima — primeiro nome ou iniciais. Continua
/// sendo dado pessoal: identifica alguém dentro de uma ala.
@DataClassName('MinisteringBrotherRow')
class MinisteringBrothers extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  TextColumn get displayLabel => text().withLength(min: 1, max: 60)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    // Alvo das FKs compostas: garante no banco que integrante e participante
    // pertencem ao mesmo chamado da dupla ou da entrevista.
    'UNIQUE (id, calling_id)',
  ];
}

/// Dupla de ministração — a unidade que é entrevistada.
@DataClassName('MinisteringCompanionshipRow')
class MinisteringCompanionships extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();

  /// Rótulo opcional. Quando nulo, a interface compõe o nome pelos integrantes.
  TextColumn get displayLabel =>
      text().withLength(min: 1, max: 60).nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['UNIQUE (id, calling_id)'];
}

/// Composição da dupla. Tabela de junção em vez de colunas `brotherA`/`brotherB`
/// porque o Manual admite um terceiro integrante quando um jovem participa.
@DataClassName('MinisteringCompanionshipMemberRow')
class MinisteringCompanionshipMembers extends Table {
  TextColumn get companionshipId => text()();
  TextColumn get brotherId => text()();

  /// Redundante de propósito: é o que torna possível a FK composta abaixo.
  TextColumn get callingId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {companionshipId, brotherId};

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (companionship_id, calling_id) '
        'REFERENCES ministering_companionships (id, calling_id) '
        'ON DELETE CASCADE',
    // RESTRICT no irmão: apagar alguém que já compõe dupla destruiria histórico.
    // A operação exposta pelo produto é desativar, não excluir.
    'FOREIGN KEY (brother_id, calling_id) '
        'REFERENCES ministering_brothers (id, calling_id) ON DELETE RESTRICT',
  ];
}

/// Entrevista de ministração realizada.
///
/// Não há coluna de status: a existência da linha **é** o registro de que a
/// entrevista aconteceu. Pendência é ausência, não estado — o que elimina a
/// possibilidade de a lista de pendentes divergir da lista de duplas.
///
/// Não há colunas de ano e trimestre: ambos são derivados de [completedAt] no
/// momento da consulta, o que torna impossível divergirem da data.
@DataClassName('MinisteringInterviewRow')
class MinisteringInterviews extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  TextColumn get companionshipId => text()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'UNIQUE (id, calling_id)',
    'FOREIGN KEY (companionship_id, calling_id) '
        'REFERENCES ministering_companionships (id, calling_id) '
        'ON DELETE CASCADE',
  ];
}

/// Quem da dupla participou da entrevista.
///
/// O Manual prefere a presença dos dois companheiros, mas não a exige — uma
/// entrevista com apenas um integrante continua sendo uma entrevista. Registrar
/// os participantes preserva esse detalhe sem bloquear o registro.
@DataClassName('MinisteringInterviewParticipantRow')
class MinisteringInterviewParticipants extends Table {
  TextColumn get interviewId => text()();
  TextColumn get brotherId => text()();
  TextColumn get callingId => text()();

  /// Redundante: permite validar que o participante pertence à dupla da
  /// entrevista sem um join extra.
  TextColumn get companionshipId => text()();

  @override
  Set<Column<Object>> get primaryKey => {interviewId, brotherId};

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (interview_id, calling_id) '
        'REFERENCES ministering_interviews (id, calling_id) ON DELETE CASCADE',
    'FOREIGN KEY (brother_id, calling_id) '
        'REFERENCES ministering_brothers (id, calling_id) ON DELETE RESTRICT',
  ];
}

@DriftDatabase(
  tables: [
    Workspaces,
    Users,
    Memberships,
    Callings,
    AppPreferences,
    MinisteringBrothers,
    MinisteringCompanionships,
    MinisteringCompanionshipMembers,
    MinisteringInterviews,
    MinisteringInterviewParticipants,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'meu_chamado'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createMinisteringIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(appPreferences);
        await migrator.alterTable(TableMigration(callings));
      }
      if (from < 3) {
        // Ordem pai → filho. As chaves estrangeiras estão desligadas durante a
        // migração, mas criar nesta ordem mantém o script legível e seguro.
        await migrator.createTable(ministeringBrothers);
        await migrator.createTable(ministeringCompanionships);
        await migrator.createTable(ministeringCompanionshipMembers);
        await migrator.createTable(ministeringInterviews);
        await migrator.createTable(ministeringInterviewParticipants);
        await _createMinisteringIndexes();
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Índices do módulo de ministração.
  ///
  /// Fonte única, chamada tanto na criação quanto na migração, para que os dois
  /// caminhos não possam divergir. O volume é de dezenas de linhas: eles existem
  /// por correção de modelagem e previsibilidade do plano, não por desempenho.
  Future<void> _createMinisteringIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_ministering_brothers_calling '
          'ON ministering_brothers (calling_id, is_active)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_companionships_calling '
          'ON ministering_companionships (calling_id, is_active)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_members_companionship '
          'ON ministering_companionship_members (companionship_id)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_members_brother '
          'ON ministering_companionship_members (brother_id)',
      // Consulta central do painel: entrevistas de um chamado dentro da janela
      // de um trimestre, filtradas por intervalo de completed_at.
      'CREATE INDEX IF NOT EXISTS idx_ministering_interviews_calling_date '
          'ON ministering_interviews (calling_id, completed_at)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_interviews_companionship '
          'ON ministering_interviews (companionship_id)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_participants_interview '
          'ON ministering_interview_participants (interview_id)',
    ];

    for (final statement in statements) {
      await customStatement(statement);
    }
  }
}
