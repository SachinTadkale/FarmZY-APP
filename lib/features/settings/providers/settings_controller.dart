import 'package:farmzy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:farmzy/features/settings/domain/models/app_settings.dart';
import 'package:farmzy/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(() {
  return SettingsController();
});

/**
 * Settings Controller.
 * Manages the application settings state and handles persistence.
 */
class SettingsController extends Notifier<AppSettings> {
  late final SettingsRepository _repository;

  @override
  AppSettings build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return const AppSettings();
  }

  /**
   * Load settings from persistent storage.
   * Should be called during app initialization.
   */
  Future<void> init() async {
    final language = await _repository.getLanguage();
    final theme = await _repository.getTheme();
    final hasSelected = await _repository.getHasSelectedLanguage();

    state = state.copyWith(
      languageCode: language ?? 'en',
      themeMode: theme,
      hasSelectedLanguage: hasSelected,
    );
  }

  /**
   * Update application language.
   */
  Future<void> updateLanguage(String code) async {
    await _repository.saveLanguage(code);
    state = state.copyWith(languageCode: code);
  }

  /**
   * Update application theme mode.
   */
  Future<void> updateTheme(ThemeMode theme) async {
    await _repository.saveTheme(theme);
    state = state.copyWith(themeMode: theme);
  }

  /**
   * Mark language selection as completed for the first-time user flow.
   */
  Future<void> completeLanguageSelection() async {
    await _repository.setHasSelectedLanguage(true);
    state = state.copyWith(hasSelectedLanguage: true);
  }
}
