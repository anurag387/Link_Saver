import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displaySmall: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: primaryText),
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: primaryText),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: primaryText),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: primaryText),
      bodyLarge: TextStyle(fontSize: 16, color: primaryText, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryText, height: 1.4),
      labelSmall: TextStyle(fontSize: 12, color: secondaryText),
    );
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimary,
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    textTheme:
        _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    // Note: CardThemeData (not the older CardTheme) is required here on
    // current Flutter — ThemeData.cardTheme's parameter type was changed
    // to CardThemeData in Flutter 3.27+.
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard, vertical: AppSpacing.standard),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xLarge),
      ),
      backgroundColor: AppColors.lightSurface,
      side: const BorderSide(color: AppColors.lightBorder),
    ),
    dividerColor: AppColors.lightBorder,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    textTheme:
        _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard, vertical: AppSpacing.standard),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xLarge),
      ),
      backgroundColor: AppColors.darkSurface,
      side: const BorderSide(color: AppColors.darkBorder),
    ),
    dividerColor: AppColors.darkBorder,
  );
}
