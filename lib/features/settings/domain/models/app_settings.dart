import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/**
 * App Settings Model.
 * Represents the global application settings including language and theme.
 */
class AppSettings extends Equatable {
  final String languageCode;
  final ThemeMode themeMode;
  final bool hasSelectedLanguage;

  const AppSettings({
    this.languageCode = 'en',
    this.themeMode = ThemeMode.system,
    this.hasSelectedLanguage = false,
  });

  AppSettings copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? hasSelectedLanguage,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
    );
  }

  @override
  List<Object?> get props => [languageCode, themeMode, hasSelectedLanguage];
}
