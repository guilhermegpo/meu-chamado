import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_dashboard_screen.dart';

import 'ministering_harness.dart';

/// Percurso completo do módulo pela navegação real, do painel vazio até o
/// trimestre fechado. Todos os dados são fictícios.
void main() {
  late AppDatabase database;

  setUp(() async {
    database = await openMinisteringTestDatabase(
      callingIds: const [ministeringTestCallingId, 'calling-b'],
    );
  });

  tearDown(() async => database.close());

  Future<void> pumpDashboard(
    WidgetTester tester, {
    String callingId = ministeringTestCallingId,
  }) => pumpMinisteringScreen(
    tester,
    database: database,
    child: MinisteringDashboardScreen(
      callingId: callingId,
      callingTitle: 'Secretário da Ministração',
    ),
  );

  Future<void> addBrother(WidgetTester tester, String label) async {
    await tapVisible(tester, find.byKey(const Key('add-brother-button')));
    await tester.enterText(find.byKey(const Key('brother-label-field')), label);
    await tapVisible(tester, find.byKey(const Key('brother-label-confirm')));
    await settleSnackBars(tester);
  }

  testWidgets('do painel vazio ao trimestre fechado', (tester) async {
    await pumpDashboard(tester);

    // 1. O painel vazio aponta o primeiro passo.
    expect(find.text('Comece por aqui'), findsOneWidget);
    expect(find.text('Nenhuma dupla ativa'), findsOneWidget);

    // 2. Cadastro dos irmãos.
    await tapVisible(tester, find.byKey(const Key('start-brothers-button')));
    expect(find.text('Irmãos ministradores'), findsOneWidget);
    await addBrother(tester, 'Irmão A');
    await addBrother(tester, 'Irmão B');
    await addBrother(tester, 'Irmão C');
    await goBack(tester);

    // 3. Com irmãos cadastrados, o painel libera as duplas.
    expect(
      find.textContaining('Os irmãos já estão cadastrados'),
      findsOneWidget,
    );
    await tapVisible(
      tester,
      find.byKey(const Key('start-companionships-button')),
    );
    expect(find.text('Duplas'), findsWidgets);

    await tapVisible(tester, find.byKey(const Key('add-companionship-button')));
    // O alvo é o rótulo, não a instância: cada toque reconstrói o tile e uma
    // referência guardada antes vira um widget que não está mais na árvore.
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    await tapVisible(tester, find.widgetWithText(CheckboxListTile, 'Irmão A'));
    await tapVisible(tester, find.widgetWithText(CheckboxListTile, 'Irmão B'));
    await tapVisible(tester, find.byKey(const Key('companionship-confirm')));
    await settleSnackBars(tester);
    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
    await goBack(tester);

    // 4. A dupla nova aparece pendente no trimestre corrente.
    final quarter = Quarter.of(DateTime.now());
    expect(find.text(quarter.label), findsOneWidget);
    expect(find.text('0 de 1 dupla entrevistada'), findsOneWidget);
    expect(
      find.text('1 dupla ainda sem entrevista neste trimestre.'),
      findsOneWidget,
    );

    // 5. Registro da entrevista pela linha da dupla.
    await tapVisible(tester, find.text('Irmão A · Irmão B').first);
    expect(find.text('Pendente no ${quarter.label}'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('record-interview-button')));
    await tapVisible(tester, find.byKey(const Key('interview-confirm')));
    await settleSnackBars(tester);
    expect(find.text('Entrevistada no ${quarter.label}'), findsOneWidget);
    await goBack(tester);

    // 6. O painel fecha o trimestre.
    expect(find.text('1 de 1 dupla entrevistada'), findsOneWidget);
    expect(find.text('Nada pendente por aqui.'), findsOneWidget);
    await scrollTo(
      tester,
      find.text(
        'Todas as duplas ativas já foram entrevistadas neste '
        'trimestre.',
      ),
    );
    expect(
      find.text(
        'Todas as duplas ativas já foram entrevistadas neste trimestre.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('o painel de um chamado não enxerga os dados do outro', (
    tester,
  ) async {
    final repository = MinisteringRepository(database);
    final ids = <String>[];
    for (final label in ['Irmão A', 'Irmão B']) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: label,
      );
      ids.add(brother.id);
    }
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );

    await pumpDashboard(tester, callingId: 'calling-b');

    expect(find.text('Comece por aqui'), findsOneWidget);
    expect(find.text('Nenhuma dupla ativa'), findsOneWidget);
    expect(find.text('Irmão A · Irmão B'), findsNothing);

    await tapVisible(tester, find.byKey(const Key('start-brothers-button')));
    expect(find.text('Irmão A'), findsNothing);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsOneWidget);
  });

  testWidgets('desativar a dupla depois da entrevista mantém o histórico', (
    tester,
  ) async {
    final repository = MinisteringRepository(database);
    final ids = <String>[];
    for (final label in ['Irmão A', 'Irmão B']) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: label,
      );
      ids.add(brother.id);
    }
    final companionship = await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );
    await repository.recordInterview(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
      completedOn: DateTime.now(),
      participantBrotherIds: ids,
    );

    await pumpDashboard(tester);
    expect(find.text('1 de 1 dupla entrevistada'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const Key('open-companionships-button')),
    );
    await tapVisible(tester, find.byTooltip('Ações da dupla'));
    await tapVisible(tester, find.text('Desativar dupla').last);
    await settleSnackBars(tester);
    await goBack(tester);

    // Sem duplas ativas o painel volta ao começo, mas nada foi apagado.
    expect(find.text('Nenhuma dupla ativa'), findsOneWidget);

    final interviews = await repository.listInterviews(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
    );
    expect(interviews, hasLength(1));
  });
}
