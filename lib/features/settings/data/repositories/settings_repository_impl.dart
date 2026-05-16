import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(secureStorageServiceProvider));
});

/**
 * Settings Repository Implementation.
 * Uses SecureStorageService for persistent storage.
 */
class SettingsRepositoryImpl implements SettingsRepository {
  final SecureStorageService _storage;

  SettingsRepositoryImpl(this._storage);

  @override
  Future<String?> getLanguage() async {
    return await _storage.getLanguage();
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _storage.saveLanguage(languageCode);
  }

  @override
  Future<ThemeMode> getTheme() async {
    final themeStr = await _storage.getTheme();
    if (themeStr == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> saveTheme(ThemeMode themeMode) async {
    await _storage.saveTheme(themeMode.name);
  }

  @override
  Future<bool> getHasSelectedLanguage() async {
    return await _storage.getHasSelectedLanguage();
  }

  @override
  Future<void> setHasSelectedLanguage(bool hasSelected) async {
    await _storage.setHasSelectedLanguage(hasSelected);
  }
}
