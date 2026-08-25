import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/profile/data/profile_photo_service.dart';
import 'package:meu_chamado/features/profile/presentation/profile_avatar.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

class UserEditorResult {
  const UserEditorResult({
    required this.name,
    required this.role,
    this.photoPath,
    this.removePhoto = false,
  });

  final String name;
  final UserRole role;
  final String? photoPath;
  final bool removePhoto;
}

class UserEditorDialog extends ConsumerStatefulWidget {
  const UserEditorDialog({
    required this.roleEditable,
    this.user,
    this.initialRole = UserRole.user,
    super.key,
  });

  final UserProfile? user;
  final bool roleEditable;
  final UserRole initialRole;

  @override
  ConsumerState<UserEditorDialog> createState() => _UserEditorDialogState();
}

class _UserEditorDialogState extends ConsumerState<UserEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late UserRole _role;
  String? _photoPath;
  String? _selectedManagedPhotoPath;
  bool _choosingPhoto = false;
  bool _removePhoto = false;
  bool _submitted = false;
  late final ProfilePhotoService _photoService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _role = widget.user?.role ?? widget.initialRole;
    _photoPath = widget.user?.photoPath;
    _photoService = ref.read(profilePhotoServiceProvider);
  }

  @override
  void dispose() {
    if (!_submitted && _selectedManagedPhotoPath != null) {
      unawaited(_photoService.deleteIfManaged(_selectedManagedPhotoPath));
    }
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.user != null;
    return AlertDialog(
      title: Text(editing ? 'Editar usuário' : 'Novo usuário'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(
                  name: _nameController.text.trim().isEmpty
                      ? 'Novo usuário'
                      : _nameController.text,
                  photoPath: _photoPath,
                  radius: 42,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _choosingPhoto ? null : _choosePhoto,
                  icon: _choosingPhoto
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _photoPath == null ? 'Escolher foto' : 'Trocar foto',
                  ),
                ),
                if (_photoPath != null)
                  TextButton.icon(
                    onPressed: _choosingPhoto ? null : _clearPhoto,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover foto'),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('user-name-field'),
                  controller: _nameController,
                  autofocus: !editing,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o nome.'
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                if (widget.roleEditable) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    decoration: const InputDecoration(labelText: 'Cargo'),
                    items: UserRole.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(_roleLabel(role)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) setState(() => _role = value);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('save-user-button'),
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _choosePhoto() async {
    setState(() => _choosingPhoto = true);
    try {
      final path = await _photoService.chooseFromGallery();
      if (mounted && path != null) {
        await _photoService.deleteIfManaged(_selectedManagedPhotoPath);
        setState(() {
          _photoPath = path;
          _selectedManagedPhotoPath = path;
          _removePhoto = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível usar a imagem selecionada.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _choosingPhoto = false);
    }
  }

  Future<void> _clearPhoto() async {
    await _photoService.deleteIfManaged(_selectedManagedPhotoPath);
    if (!mounted) return;
    setState(() {
      _photoPath = null;
      _selectedManagedPhotoPath = null;
      _removePhoto = widget.user?.photoPath != null;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _submitted = true;
    Navigator.of(context).pop(
      UserEditorResult(
        name: _nameController.text.trim(),
        role: _role,
        photoPath: _photoPath,
        removePhoto: _removePhoto,
      ),
    );
  }

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.moderator => 'Moderador',
    UserRole.user => 'Usuário',
  };
}
