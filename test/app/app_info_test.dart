import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/app/app_info.dart';
import 'package:meu_chamado/app/theme/app_theme.dart';
import 'package:meu_chamado/features/settings/presentation/settings_screen.dart';

void main() {
  test('a versão exibida acompanha o pubspec', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final line = pubspec.firstWhere((line) => line.startsWith('version:'));
    // `0.2.0-alpha.1+2` → `0.2.0-alpha.1`: o número de build é do Android e
    // não faz parte da versão que o usuário lê.
    final declared = line.split(':').last.trim().split('+').first;

    expect(
      AppInfo.version,
      declared,
      reason:
          'AppInfo.version ficou para trás do pubspec. Atualize os dois no '
          'mesmo commit — foi assim que a alpha anterior chegou ao aparelho '
          'anunciando a versão errada.',
    );
  });

  testWidgets('as Configurações mostram a versão instalada', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(AppInfo.version), findsOneWidget);
    expect(find.textContaining('não oficial'), findsOneWidget);
  });
}
