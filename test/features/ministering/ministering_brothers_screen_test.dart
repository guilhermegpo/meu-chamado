import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;
  late MinisteringRepository repository;

  setUp(() async {
    database = await openMinisteringTestDatabase();
    repository = MinisteringRepository(database);
  });

  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: const MinisteringBrothersScreen(callingId: ministeringTestCallingId),
  );

  Future<void> addBrother(WidgetTester tester, String label) async {
    await tapVisible(tester, find.byKey(const Key('add-brother-button')));
    await tester.enterText(find.byKey(const Key('brother-label-field')), label);
    await tapVisible(tester, find.byKey(const Key('brother-label-confirm')));
  }

  Future<void> chooseAction(WidgetTester tester, String label) async {
    await tapVisible(tester, find.byTooltip('Ações do cadastro').first);
    await tapVisible(tester, find.text(label).last);
  }

  testWidgets('parte do estado vazio e lembra a política de privacidade', (
    tester,
  ) async {
    await pump(tester);

    expect(find.textContaining('primeiro nome ou as iniciais'), findsOneWidget);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsOneWidget);
    expect(find.text('Nenhum irmão inativo.'), findsOneWidget);
  });

  testWidgets('adiciona um irmão e ele aparece entre os ativos', (
    tester,
  ) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');

    expect(find.text('Irmão A'), findsOneWidget);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsNothing);
    expect(find.text('Irmão adicionado.'), findsOneWidget);
  });

  testWidgets('não aceita identificação vazia', (tester) async {
    await pump(tester);

    await tapVisible(tester, find.byKey(const Key('add-brother-button')));
    await tapVisible(tester, find.byKey(const Key('brother-label-confirm')));

    expect(find.text('Informe uma identificação.'), findsOneWidget);
    expect(find.byKey(const Key('brother-label-field')), findsOneWidget);
  });

  testWidgets('edita a identificação de um irmão', (tester) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');

    await chooseAction(tester, 'Editar identificação');
    await tester.enterText(
      find.byKey(const Key('brother-label-field')),
      'Irmão B',
    );
    await tapVisible(tester, find.byKey(const Key('brother-label-confirm')));

    expect(find.text('Irmão B'), findsOneWidget);
    expect(find.text('Irmão A'), findsNothing);
  });

  testWidgets('desativar move para inativos sem apagar o irmão', (
    tester,
  ) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');

    await chooseAction(tester, 'Desativar');

    expect(find.text('Irmão A'), findsOneWidget);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsOneWidget);
    expect(find.text('Inativo'), findsOneWidget);
    expect(find.textContaining('continuam nas'), findsOneWidget);
  });

  testWidgets('reativar devolve o irmão para a seleção ativa', (tester) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');
    await chooseAction(tester, 'Desativar');
    await chooseAction(tester, 'Reativar');

    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Nenhum irmão inativo.'), findsOneWidget);
  });

  testWidgets('exclui definitivamente um cadastro nunca usado', (tester) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');
    await settleSnackBars(tester);

    await chooseAction(tester, 'Verificar exclusão');
    expect(find.text('Excluir cadastro?'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('confirm-delete-brother')));

    expect(find.text('Cadastro excluído.'), findsOneWidget);
    expect(find.text('Irmão A'), findsNothing);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsOneWidget);
  });

  testWidgets('não oferece exclusão quando o cadastro compõe dupla', (
    tester,
  ) async {
    final first = await repository.createBrother(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão A',
    );
    final second = await repository.createBrother(
      callingId: ministeringTestCallingId,
      displayLabel: 'Irmão B',
    );
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: [first.id, second.id],
    );
    await pump(tester);

    await chooseAction(tester, 'Verificar exclusão');

    expect(find.text('Exclusão indisponível'), findsOneWidget);
    expect(find.textContaining('compõe 1 dupla'), findsOneWidget);
    expect(find.byKey(const Key('confirm-delete-brother')), findsNothing);
  });
}
