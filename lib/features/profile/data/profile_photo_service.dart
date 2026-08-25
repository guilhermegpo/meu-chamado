import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef AppDocumentsDirectoryProvider = Future<Directory> Function();

/// Selects one image from the system gallery and copies it into app-owned
/// storage. The original gallery file is never modified.
class ProfilePhotoService {
  ProfilePhotoService({
    ImagePicker? picker,
    AppDocumentsDirectoryProvider? documentsDirectoryProvider,
  }) : _picker = picker ?? ImagePicker(),
       _documentsDirectoryProvider =
           documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  final ImagePicker _picker;
  final AppDocumentsDirectoryProvider _documentsDirectoryProvider;

  Future<String?> chooseFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
      maxHeight: 1440,
      imageQuality: 88,
      requestFullMetadata: false,
    );
    if (picked == null) return null;

    return store(XFile(picked.path));
  }

  Future<String> store(XFile image) async {
    final root = await _documentsDirectoryProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}profile_photos',
    );
    await directory.create(recursive: true);

    final source = File(image.path);
    if (!await source.exists()) {
      throw const ProfilePhotoException(
        'A imagem selecionada não está mais disponível.',
      );
    }

    final extension = _safeExtension(image.name);
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final destination = File(
      '${directory.path}${Platform.pathSeparator}profile-$timestamp$extension',
    );
    await source.copy(destination.path);
    return destination.path;
  }

  Future<void> deleteIfManaged(String? photoPath) async {
    if (photoPath == null || photoPath.trim().isEmpty) return;

    final root = await _documentsDirectoryProvider();
    final managedRoot = Directory(
      '${root.path}${Platform.pathSeparator}profile_photos',
    ).absolute.path;
    final photo = File(photoPath).absolute;
    final expectedPrefix = '$managedRoot${Platform.pathSeparator}';
    if (!photo.path.startsWith(expectedPrefix)) return;
    if (await photo.exists()) await photo.delete();
  }

  String _safeExtension(String originalName) {
    final lastDot = originalName.lastIndexOf('.');
    if (lastDot < 0) return '.jpg';
    final extension = originalName.substring(lastDot).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp', '.heic'}.contains(extension)
        ? extension
        : '.jpg';
  }
}

class ProfilePhotoException implements Exception {
  const ProfilePhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}
