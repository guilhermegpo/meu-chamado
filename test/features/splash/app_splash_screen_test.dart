import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/features/splash/presentation/app_splash_screen.dart';

void main() {
  testWidgets('apresenta identidade própria e anuncia o carregamento', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: AppSplashScreen(message: 'Abrindo dados locais…'),
      ),
    );

    expect(find.text('Meu Chamado'), findsOneWidget);
    expect(find.text('Abrindo dados locais…'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Meu Chamado. Abrindo dados locais…'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Organize. Sirva. Faça a diferença.'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('não transborda com texto ampliado em tela compacta', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const AppSplashScreen(message: 'Preparando seu Workspace local…'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Meu Chamado'), findsOneWidget);
  });
}
