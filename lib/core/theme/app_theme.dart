import 'package:flutter/material.dart';
import 'app.colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightHeader,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            const BorderSide(color: AppColors.lightPrimary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      background: AppColors.lightBackground,
    ),
  );

  // ----------------------------------------------------

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkHeader,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.darkPrimary),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            const BorderSide(color: AppColors.darkPrimary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      fillColor: AppColors.darkSurface,
      filled: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.black,
        shape: const StadiumBorder(),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      background: AppColors.darkBackground,
    ),
  );
}