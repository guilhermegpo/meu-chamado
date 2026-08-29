import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_brothers_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = await openMinisteringTestDatabase();
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

    await tapVisible(tester, find.byTooltip('Editar identificação'));
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

    await tapVisible(tester, find.byTooltip('Desativar'));

    expect(find.text('Irmão A'), findsOneWidget);
    expect(find.textContaining('Nenhum irmão cadastrado'), findsOneWidget);
    expect(find.byTooltip('Reativar'), findsOneWidget);
    expect(find.textContaining('continuam nas'), findsOneWidget);
  });

  testWidgets('reativar devolve o irmão para a seleção ativa', (tester) async {
    await pump(tester);
    await addBrother(tester, 'Irmão A');
    await tapVisible(tester, find.byTooltip('Desativar'));
    await tapVisible(tester, find.byTooltip('Reativar'));

    expect(find.byTooltip('Desativar'), findsOneWidget);
    expect(find.text('Nenhum irmão inativo.'), findsOneWidget);
  });
}
