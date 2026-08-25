import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('explica o modo local e valida cada etapa antes de avançar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: OnboardingScreen(
            onCreateWorkspace: ({
              required workspaceName,
              required administratorName,
              photoPath,
            }) async {},
          ),
        ),
      ),
    );

    expect(find.text('Organize seus chamados no seu ritmo.'), findsOneWidget);
    expect(
      find.textContaining('compartilhamento poderá chegar'),
      findsOneWidget,
    );

    await _tapVisible(tester, find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();

    expect(find.text('Crie seu Workspace'), findsOneWidget);
    expect(find.text('Workspace LOCAL'), findsOneWidget);
    expect(find.textContaining('somente neste dispositivo'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('onboarding-next-button')));
    await tester.pump();
    expect(find.text('Este campo é obrigatório.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('workspace-name-field')),
      'Comunidade Local',
    );
    await _tapVisible(tester, find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();

    expect(find.text('Crie o primeiro usuário'), findsOneWidget);
    expect(find.text('ADMIN · acesso completo'), findsOneWidget);
    expect(find.textContaining('poderá adicionar depois'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('create-workspace-button')));
    await tester.pump();
    expect(find.text('Este campo é obrigatório.'), findsOneWidget);
  });

  testWidgets('repassa nomes e foto opcional para os callbacks de integração', (
    tester,
  ) async {
    String? createdWorkspace;
    String? createdAdministrator;
    String? createdPhotoPath;
    var photoRequests = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: OnboardingScreen(
            onSelectPhoto: () async {
              photoRequests += 1;
              return r'C:\app-data\profiles\admin.jpg';
            },
            onCreateWorkspace:
                ({
                  required workspaceName,
                  required administratorName,
                  photoPath,
                }) async {
                  createdWorkspace = workspaceName;
                  createdAdministrator = administratorName;
                  createdPhotoPath = photoPath;
                },
          ),
        ),
      ),
    );

    await _tapVisible(tester, find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workspace-name-field')),
      '  Comunidade Centro  ',
    );
    await _tapVisible(tester, find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('administrator-name-field')),
      '  Ana Souza  ',
    );

    await _tapVisible(
      tester,
      find.byKey(const Key('select-profile-photo-button')),
    );
    await tester.pumpAndSettle();

    expect(photoRequests, 1);
    expect(find.text('Foto selecionada · alterar'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('create-workspace-button')));
    await tester.pumpAndSettle();

    expect(createdWorkspace, 'Comunidade Centro');
    expect(createdAdministrator, 'Ana Souza');
    expect(createdPhotoPath, r'C:\app-data\profiles\admin.jpg');
  });

  testWidgets('permanece utilizável em tela compacta com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: OnboardingScreen(
            onCreateWorkspace: ({
              required workspaceName,
              required administratorName,
              photoPath,
            }) async {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('onboarding-next-button')));
    await tester.tap(find.byKey(const Key('onboarding-next-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('workspace-name-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
