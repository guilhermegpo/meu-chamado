import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    this.photoPath,
    this.radius = 28,
    super.key,
  });

  final String name;
  final String? photoPath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final photo = path == null ? null : File(path);
    final hasPhoto = photo != null && photo.existsSync();

    return Semantics(
      image: true,
      label: hasPhoto ? 'Foto de $name' : 'Avatar de $name',
      child: ExcludeSemantics(
        child: CircleAvatar(
          radius: radius,
          foregroundImage: hasPhoto ? FileImage(photo) : null,
          child: hasPhoto ? null : Text(_initials(name)),
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    final initials = parts
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return initials.isEmpty ? '?' : initials;
  }
}
