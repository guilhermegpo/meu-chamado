import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

void main() {
  testWidgets('mantém proporção quadrada dentro de uma Column esticada', (
    tester,
  ) async {
    // Regressão: dentro de uma Column com CrossAxisAlignment.stretch, o
    // SizedBox recebia largura forçada pelo pai e a marca era pintada
    // esticada na horizontal. Só é percebido no dispositivo, então o teste
    // reproduz exatamente esse arranjo.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [AppsMeuMark(size: 64)],
            ),
          ),
        ),
      ),
    );

    final painted = tester.getSize(
      find.descendant(
        of: find.byType(AppsMeuMark),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(painted.width, 64);
    expect(painted.height, 64);
  });

  testWidgets('expõe rótulo semântico único para leitores de tela', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppsMeuMark(size: 48))),
    );

    expect(find.bySemanticsLabel('Apps Meu'), findsOneWidget);
  });
}
