import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/core/database/app_database.dart';
import 'package:meu_chamado/features/ministering/data/ministering_repository.dart';
import 'package:meu_chamado/features/ministering/presentation/ministering_companionships_screen.dart';

import 'ministering_harness.dart';

void main() {
  late AppDatabase database;
  late MinisteringRepository repository;

  setUp(() async {
    database = await openMinisteringTestDatabase();
    repository = MinisteringRepository(database);
  });

  tearDown(() async => database.close());

  Future<List<String>> seedBrothers(int count) async {
    final ids = <String>[];
    for (var index = 0; index < count; index++) {
      final brother = await repository.createBrother(
        callingId: ministeringTestCallingId,
        displayLabel: 'Irmão ${String.fromCharCode(65 + index)}',
      );
      ids.add(brother.id);
    }
    return ids;
  }

  Future<void> pump(WidgetTester tester) => pumpMinisteringScreen(
    tester,
    database: database,
    child: const MinisteringCompanionshipsScreen(
      callingId: ministeringTestCallingId,
    ),
  );

  Future<void> select(WidgetTester tester, String brotherId) =>
      tapVisible(tester, find.byKey(Key('companionship-member-$brotherId')));

  testWidgets('avisa que faltam irmãos antes de montar a primeira dupla', (
    tester,
  ) async {
    await seedBrothers(1);
    await pump(tester);

    expect(
      find.textContaining('Cadastre ao menos dois irmãos ativos'),
      findsOneWidget,
    );
    expect(find.text('Nenhuma dupla montada.'), findsOneWidget);
  });

  testWidgets('monta uma dupla de dois integrantes', (tester) async {
    final ids = await seedBrothers(2);
    await pump(tester);

    await tapVisible(tester, find.byKey(const Key('add-companionship-button')));
    await select(tester, ids[0]);
    await select(tester, ids[1]);
    await tapVisible(tester, find.byKey(const Key('companionship-confirm')));

    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
    expect(find.text('Dupla criada.'), findsOneWidget);
  });

  testWidgets('só habilita salvar com dois ou três integrantes', (
    tester,
  ) async {
    final ids = await seedBrothers(4);
    await pump(tester);

    await tapVisible(tester, find.byKey(const Key('add-companionship-button')));

    FilledButton confirm() => tester.widget<FilledButton>(
      find.byKey(const Key('companionship-confirm')),
    );

    expect(confirm().onPressed, isNull);

    await select(tester, ids[0]);
    expect(confirm().onPressed, isNull);

    await select(tester, ids[1]);
    expect(confirm().onPressed, isNotNull);

    await select(tester, ids[2]);
    expect(confirm().onPressed, isNotNull);

    await select(tester, ids[3]);
    expect(confirm().onPressed, isNull);
  });

  testWidgets('rótulo próprio substitui o título e mantém os integrantes', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    await pump(tester);

    await tapVisible(tester, find.byKey(const Key('add-companionship-button')));
    await select(tester, ids[0]);
    await select(tester, ids[1]);
    await tester.enterText(
      find.byKey(const Key('companionship-label-field')),
      'Rota norte',
    );
    await tapVisible(tester, find.byKey(const Key('companionship-confirm')));

    expect(find.text('Rota norte'), findsOneWidget);
    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
  });

  testWidgets('trocar integrante substitui a composição exibida', (
    tester,
  ) async {
    final ids = await seedBrothers(3);
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: [ids[0], ids[1]],
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Editar dupla'));
    await select(tester, ids[1]);
    await select(tester, ids[2]);
    await tapVisible(tester, find.byKey(const Key('companionship-confirm')));

    expect(find.text('Irmão A · Irmão C'), findsOneWidget);
    expect(find.text('Dupla atualizada.'), findsOneWidget);
  });

  testWidgets('desativar tira da lista ativa sem apagar a dupla', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Desativar dupla'));

    expect(find.text('Irmão A · Irmão B'), findsOneWidget);
    expect(find.text('Nenhuma dupla montada.'), findsOneWidget);
    expect(find.byTooltip('Reativar dupla'), findsOneWidget);
  });

  testWidgets('editor avisa quando um integrante ficou inativo', (
    tester,
  ) async {
    final ids = await seedBrothers(3);
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: [ids[0], ids[1]],
    );
    await repository.setBrotherActive(
      callingId: ministeringTestCallingId,
      brotherId: ids[1],
      isActive: false,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Editar dupla'));

    expect(find.textContaining('está inativo'), findsOneWidget);
    expect(find.byKey(Key('companionship-member-${ids[1]}')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('companionship-confirm')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('exclui dupla sem entrevista e mantém os integrantes', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Verificar exclusão da dupla'));
    expect(find.text('Excluir dupla?'), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const Key('confirm-delete-companionship')),
    );

    expect(find.text('Dupla excluída.'), findsOneWidget);
    expect(find.text('Nenhuma dupla montada.'), findsOneWidget);
    final state = await repository.loadModule(
      callingId: ministeringTestCallingId,
    );
    expect(state.brothers, hasLength(2));
  });

  testWidgets('não oferece exclusão para dupla com entrevista', (tester) async {
    final ids = await seedBrothers(2);
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
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Verificar exclusão da dupla'));

    expect(find.text('Exclusão indisponível'), findsOneWidget);
    expect(find.textContaining('1 entrevista registrada'), findsOneWidget);
    expect(find.byKey(const Key('confirm-delete-companionship')), findsNothing);
  });

  testWidgets('não reativa dupla enquanto houver integrante inativo', (
    tester,
  ) async {
    final ids = await seedBrothers(2);
    final companionship = await repository.createCompanionship(
      callingId: ministeringTestCallingId,
      brotherIds: ids,
    );
    await repository.setCompanionshipActive(
      callingId: ministeringTestCallingId,
      companionshipId: companionship,
      isActive: false,
    );
    await repository.setBrotherActive(
      callingId: ministeringTestCallingId,
      brotherId: ids.first,
      isActive: false,
    );
    await pump(tester);

    await tapVisible(tester, find.byTooltip('Reativar dupla'));

    expect(find.textContaining('irmão inativo'), findsOneWidget);
    expect(find.byTooltip('Reativar dupla'), findsOneWidget);
  });
}
