import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';

void main() {
  testWidgets('shows initials and an accessible label without a photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileAvatar(name: 'Usuário Demo')),
      ),
    );

    expect(find.text('UD'), findsOneWidget);
    expect(find.bySemanticsLabel('Avatar de Usuário Demo'), findsOneWidget);
  });
}
