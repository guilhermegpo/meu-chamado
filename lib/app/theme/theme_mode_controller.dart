import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final preference = await ref
        .watch(workspaceRepositoryProvider)
        .loadThemePreference();
    return _toFlutterMode(preference);
  }

  Future<void> select(ThemeMode mode) async {
    final previous = state.value;
    state = AsyncData(mode);
    try {
      await ref
          .read(workspaceRepositoryProvider)
          .saveThemePreference(_toPreference(mode));
    } catch (error, stackTrace) {
      state = previous == null
          ? AsyncError(error, stackTrace)
          : AsyncData(previous);
      rethrow;
    }
  }

  ThemeMode _toFlutterMode(ThemePreference preference) => switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  ThemePreference _toPreference(ThemeMode mode) => switch (mode) {
    ThemeMode.system => ThemePreference.system,
    ThemeMode.light => ThemePreference.light,
    ThemeMode.dark => ThemePreference.dark,
  };
}
