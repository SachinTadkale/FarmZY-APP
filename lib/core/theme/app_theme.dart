import 'package:flutter/material.dart';
import 'app.colors.dart';
import 'package:farmzy/shared/enums/user_role.dart';

class AppTheme {
  static ThemeData getTheme(UserRole role) {
    return switch (role) {
      UserRole.farmer || UserRole.admin || UserRole.owner => _theme(Brightness.light, AppColors.primaryFarmer),
      UserRole.deliveryPartner => _theme(Brightness.light, AppColors.primaryDelivery),
    };
  }

  static ThemeData getDarkTheme(UserRole role) {
    return switch (role) {
      UserRole.farmer || UserRole.admin || UserRole.owner => _theme(Brightness.dark, AppColors.primaryFarmerLight),
      UserRole.deliveryPartner => _theme(Brightness.dark, AppColors.primaryDeliveryLight),
    };
  }

  static ThemeData _theme(Brightness brightness, Color primary) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
          letterSpacing: -0.2,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: outline.withValues(alpha: 0.1), width: 1),
        ),
        color: surface,
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.circular(16),
        ),
        hintStyle: TextStyle(
          color: textSecondary.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Outfit',
          ),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
        displayMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        displaySmall: TextStyle(color: text, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: text, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: text, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: text, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: text, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: text, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      ),

      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: primary,
              secondary: primary.withValues(alpha: 0.8),
              surface: surface,
              onSurface: text,
              onSurfaceVariant: textSecondary,
              outline: outline,
              error: AppColors.error,
              surfaceContainerHighest: isDark ? const Color(0xFF232529) : const Color(0xFFF1F4F9),
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primary.withValues(alpha: 0.8),
              surface: surface,
              onSurface: text,
              onSurfaceVariant: textSecondary,
              outline: outline,
              error: AppColors.error,
              surfaceContainerHighest: const Color(0xFFF1F4F9),
            ),
      
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.5),
        thickness: 1,
        indent: 0,
        endIndent: 0,
      ),
    );
  }
}
