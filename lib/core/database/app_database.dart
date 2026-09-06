import 'dart:io';

import 'package:drift/drift.dart';
import 'package:meu_chamado/core/security/encrypted_database.dart';

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

/// Liderança responsável pelas entrevistas de ministração.
///
/// Domínio **separado** do `WorkspaceRole` (`ADMIN`, `MODERATOR`, `USER`), que é
/// técnico e não representa autoridade eclesiástica. Quem conduz uma entrevista
/// é sempre um líder escolhido de propósito — nunca inferido do usuário logado,
/// e o Secretário da Ministração não vira entrevistador por organizar a agenda.
///
/// `displayLabel` é identificação mínima, como a do irmão ministrador. `role`
/// guarda o cargo na presidência do quórum. Ver
/// [ADR 0014](../../../docs/adr/0014-ministering-leadership-domain.md).
@DataClassName('MinisteringLeaderRow')
class MinisteringLeaders extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  TextColumn get displayLabel => text().withLength(min: 1, max: 60)();

  /// `QUORUM_PRESIDENT`, `FIRST_COUNSELOR` ou `SECOND_COUNSELOR`. Guardado como
  /// texto pela mesma razão dos outros enums do app: a coluna descreve um cargo,
  /// e novos cargos entram sem migração de tipo.
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    // Alvo da FK composta de entrevistador em agendamentos: garante no banco que
    // o líder pertence ao mesmo chamado.
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
///
/// [interviewerId] entrou no schema v4. É anulável apenas para as entrevistas
/// gravadas antes da v4, quando o módulo ainda não tinha liderança; todo caminho
/// de gravação da v4 em diante informa o entrevistador. A FK é de coluna única
/// (não composta por `calling_id` como as demais) porque o `ALTER TABLE ADD
/// COLUMN` do SQLite não aceita restrição composta, e recriar esta tabela — que
/// `ministering_interview_participants` referencia — custaria mais do que a
/// garantia vale. O repositório valida o chamado do entrevistador.
@DataClassName('MinisteringInterviewRow')
class MinisteringInterviews extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  TextColumn get companionshipId => text()();

  /// Líder que conduziu a entrevista. Ver nota da classe sobre a nulabilidade.
  TextColumn get interviewerId => text().nullable().references(
    MinisteringLeaders,
    #id,
    onDelete: KeyAction.restrict,
  )();
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

/// Entrevista **agendada e ainda não realizada**.
///
/// Tabela separada da entrevista realizada de propósito. A entrevista realizada
/// é um fato consumado; o agendamento é um plano, que muda de data, troca de
/// entrevistador ou é cancelado. Fundir os dois numa linha só com uma coluna
/// `status` recriaria exatamente os estados impossíveis que o módulo evita:
/// agendada com `completed_at` preenchido, realizada sem participantes,
/// cancelada pendurada na tabela. Ver
/// [ADR 0015](../../../docs/adr/0015-ministering-scheduling-model.md).
///
/// Não há `status` aqui tampouco: a existência da linha **é** o fato de haver
/// uma entrevista planejada. Cancelar é apagar a linha; concluir é criar a
/// entrevista realizada e apagar esta. No máximo um agendamento aberto por
/// dupla — reagendar edita a linha, não cria outra.
@DataClassName('MinisteringAppointmentRow')
class MinisteringAppointments extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  TextColumn get companionshipId => text()();
  TextColumn get interviewerId => text()();

  /// Instante planejado, **com hora do dia** — ao contrário de
  /// `MinisteringInterviews.completedAt`, que é data de calendário. Um
  /// agendamento tem horário; uma entrevista aconteceu num dia.
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    // Um agendamento aberto por dupla.
    'UNIQUE (companionship_id)',
    'FOREIGN KEY (companionship_id, calling_id) '
        'REFERENCES ministering_companionships (id, calling_id) '
        'ON DELETE CASCADE',
    'FOREIGN KEY (interviewer_id, calling_id) '
        'REFERENCES ministering_leaders (id, calling_id) ON DELETE RESTRICT',
  ];
}

/// Escopo congelado de um trimestre concluído.
///
/// O denominador do painel do trimestre corrente é derivado do estado atual das
/// duplas. Isso deixa um trimestre já encerrado à mercê de mutações futuras:
/// criar, remover ou desativar uma dupla mudaria o "X de Y" de um passado que
/// não deveria mais se mover. O snapshot congela **quais duplas faziam parte do
/// escopo daquele trimestre** — nunca as entrevistas, que continuam sendo a
/// fonte de verdade e podem ser corrigidas.
///
/// Um snapshot por trimestre por chamado. Só existe para trimestres já
/// encerrados; o corrente permanece live. Ver
/// [ADR 0017](../../../docs/adr/0017-ministering-quarter-snapshots.md).
@DataClassName('MinisteringQuarterSnapshotRow')
class MinisteringQuarterSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get callingId =>
      text().references(Callings, #id, onDelete: KeyAction.cascade)();
  IntColumn get year => integer()();

  /// 1 a 4.
  IntColumn get quarter => integer()();

  /// Quando o escopo foi congelado — logo após o trimestre encerrar, na
  /// primeira leitura ou mutação seguinte.
  DateTimeColumn get finalizedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'UNIQUE (id, calling_id)',
    // Um snapshot por trimestre por chamado. É o que torna a finalização
    // idempotente: uma segunda tentativa esbarra aqui em vez de recongelar.
    'UNIQUE (calling_id, year, quarter)',
  ];
}

/// Dupla que fazia parte do escopo de um trimestre congelado.
///
/// Guarda apenas o `companionship_id` — o rótulo e a composição continuam
/// resolvidos pelo cadastro vivo. O que precisa ficar imutável é o **conjunto**,
/// não o texto.
@DataClassName('MinisteringQuarterSnapshotCompanionshipRow')
class MinisteringQuarterSnapshotCompanionships extends Table {
  TextColumn get snapshotId => text()();
  TextColumn get companionshipId => text()();

  /// Redundante de propósito: sustenta as FKs compostas por chamado.
  TextColumn get callingId => text()();

  @override
  Set<Column<Object>> get primaryKey => {snapshotId, companionshipId};

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (snapshot_id, calling_id) '
        'REFERENCES ministering_quarter_snapshots (id, calling_id) '
        'ON DELETE CASCADE',
    // RESTRICT: uma dupla que consta no escopo de um trimestre concluído não
    // pode ser apagada definitivamente — isso encolheria o denominador
    // histórico. Desativar continua permitido; não toca no snapshot.
    'FOREIGN KEY (companionship_id, calling_id) '
        'REFERENCES ministering_companionships (id, calling_id) '
        'ON DELETE RESTRICT',
  ];
}

/// Composição congelada de uma dupla no escopo de um trimestre.
///
/// IDs dos integrantes, não nomes: a minimização do domínio continua valendo no
/// histórico. Os rótulos são resolvidos pelo cadastro de irmãos vivo; o que o
/// snapshot preserva é **quem** compunha a dupla naquele trimestre, mesmo que a
/// composição mude depois.
@DataClassName('MinisteringQuarterSnapshotMemberRow')
class MinisteringQuarterSnapshotMembers extends Table {
  TextColumn get snapshotId => text()();
  TextColumn get companionshipId => text()();
  TextColumn get brotherId => text()();
  TextColumn get callingId => text()();

  @override
  Set<Column<Object>> get primaryKey => {
    snapshotId,
    companionshipId,
    brotherId,
  };

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY (snapshot_id, companionship_id) '
        'REFERENCES ministering_quarter_snapshot_companionships '
        '(snapshot_id, companionship_id) ON DELETE CASCADE',
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
    MinisteringLeaders,
    MinisteringCompanionships,
    MinisteringCompanionshipMembers,
    MinisteringInterviews,
    MinisteringInterviewParticipants,
    MinisteringAppointments,
    MinisteringQuarterSnapshots,
    MinisteringQuarterSnapshotCompanionships,
    MinisteringQuarterSnapshotMembers,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Caminho de produção: abre [file] criptografado com [key]
  /// ([ADR 0016](../../../docs/adr/0016-local-security-and-encrypted-storage.md)).
  AppDatabase.encrypted(File file, String key)
    : super(encryptedExecutor(file, key));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createMinisteringIndexes();
      await _createMinisteringOperationsIndexes();
      await _createMinisteringHistoryIndexes();
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
      if (from < 4) {
        // Operação das entrevistas: liderança, entrevistador e agendamento.
        // Tudo aditivo.
        await migrator.createTable(ministeringLeaders);
        if (from == 3) {
          // A tabela de entrevistas já existe da v3, sem a coluna. Um banco que
          // vem de antes da v3 criou a tabela acima com o schema atual, que já
          // tem `interviewer_id` — daí a guarda. `addColumn` de coluna anulável
          // e sem default aceita a cláusula `REFERENCES` no `ALTER TABLE`.
          await migrator.addColumn(
            ministeringInterviews,
            ministeringInterviews.interviewerId,
          );
        }
        await migrator.createTable(ministeringAppointments);
        await _createMinisteringOperationsIndexes();
      }
      if (from < 5) {
        // Histórico trimestral: só três tabelas novas, nada alterado. As
        // consultas de escopo passado leem daqui; o banco existente continua
        // exatamente como estava.
        await migrator.createTable(ministeringQuarterSnapshots);
        await migrator.createTable(ministeringQuarterSnapshotCompanionships);
        await migrator.createTable(ministeringQuarterSnapshotMembers);
        await _createMinisteringHistoryIndexes();
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Índices da fundação do módulo (schema v3).
  ///
  /// Fonte única, chamada tanto na criação quanto na migração v2 → v3, para que
  /// os dois caminhos não possam divergir. O volume é de dezenas de linhas: eles
  /// existem por correção de modelagem e previsibilidade do plano, não por
  /// desempenho.
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

  /// Índices da operação das entrevistas (schema v4): liderança, entrevistador
  /// e agendamento. Separado de [_createMinisteringIndexes] porque a migração
  /// v2 → v3 roda antes destas tabelas existirem.
  Future<void> _createMinisteringOperationsIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_ministering_leaders_calling '
          'ON ministering_leaders (calling_id, is_active)',
      // Apagar um líder percorre as tabelas que o citam por causa do RESTRICT:
      // os índices por entrevistador mantêm essa checagem previsível.
      'CREATE INDEX IF NOT EXISTS idx_ministering_interviews_interviewer '
          'ON ministering_interviews (interviewer_id)',
      // Consulta das próximas entrevistas: agendamentos de um chamado em ordem
      // de data.
      'CREATE INDEX IF NOT EXISTS idx_ministering_appointments_calling_date '
          'ON ministering_appointments (calling_id, scheduled_at)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_appointments_interviewer '
          'ON ministering_appointments (interviewer_id)',
    ];

    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  /// Índices do histórico trimestral (schema v5).
  Future<void> _createMinisteringHistoryIndexes() async {
    const statements = [
      // Lista do histórico: snapshots de um chamado, mais recente primeiro.
      'CREATE INDEX IF NOT EXISTS idx_ministering_quarter_snapshots_calling '
          'ON ministering_quarter_snapshots (calling_id, year, quarter)',
      // Escopo congelado de um trimestre.
      'CREATE INDEX IF NOT EXISTS '
          'idx_ministering_snapshot_companionships_snapshot '
          'ON ministering_quarter_snapshot_companionships (snapshot_id)',
      // RESTRICT ao apagar uma dupla percorre esta tabela: mantê-la indexada
      // por dupla torna a checagem previsível.
      'CREATE INDEX IF NOT EXISTS '
          'idx_ministering_snapshot_companionships_companionship '
          'ON ministering_quarter_snapshot_companionships (companionship_id)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_snapshot_members_snapshot '
          'ON ministering_quarter_snapshot_members '
          '(snapshot_id, companionship_id)',
      'CREATE INDEX IF NOT EXISTS idx_ministering_snapshot_members_brother '
          'ON ministering_quarter_snapshot_members (brother_id)',
    ];

    for (final statement in statements) {
      await customStatement(statement);
    }
  }
}
