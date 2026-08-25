import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meu_chamado/features/profile/data/profile_photo_service.dart';

void main() {
  late Directory sandbox;
  late ProfilePhotoService service;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('meu-chamado-photo-test-');
    service = ProfilePhotoService(
      documentsDirectoryProvider: () async => sandbox,
    );
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('copies a selected photo into app-owned storage', () async {
    final source = File('${sandbox.path}${Platform.pathSeparator}source.png');
    await source.writeAsBytes([1, 2, 3, 4]);

    final storedPath = await service.store(XFile(source.path));

    expect(storedPath, contains('profile_photos'));
    expect(storedPath, endsWith('.png'));
    expect(await File(storedPath).readAsBytes(), [1, 2, 3, 4]);
    expect(await source.exists(), isTrue);
  });

  test('deletes only photos managed by the application', () async {
    final source = File('${sandbox.path}${Platform.pathSeparator}source.jpg');
    await source.writeAsBytes([1]);
    final storedPath = await service.store(XFile(source.path));

    await service.deleteIfManaged(source.path);
    expect(await source.exists(), isTrue);

    await service.deleteIfManaged(storedPath);
    expect(await File(storedPath).exists(), isFalse);
  });

  test('reports a safe error when the selected file disappeared', () async {
    final missing = XFile(
      '${sandbox.path}${Platform.pathSeparator}missing-personal-photo.jpg',
    );

    await expectLater(
      service.store(missing),
      throwsA(
        isA<ProfilePhotoException>().having(
          (error) => error.message,
          'message',
          'A imagem selecionada não está mais disponível.',
        ),
      ),
    );
  });
}
