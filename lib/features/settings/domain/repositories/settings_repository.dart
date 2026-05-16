import 'package:flutter/material.dart';

/**
 * Settings Repository.
 * Abstract interface for app settings persistence.
 */
abstract class SettingsRepository {
  Future<String?> getLanguage();
  Future<void> saveLanguage(String languageCode);
  Future<ThemeMode> getTheme();
  Future<void> saveTheme(ThemeMode themeMode);
  Future<bool> getHasSelectedLanguage();
  Future<void> setHasSelectedLanguage(bool hasSelected);
}
