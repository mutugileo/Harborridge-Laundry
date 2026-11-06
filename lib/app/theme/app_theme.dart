import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';

class AppTheme {
  static ThemeData createLightTheme() {
    const colors = AppColors.light;
    const spacing = AppSpacing.regular;
    const motion = AppMotion.standard;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.brandPrimary,
        secondary: colors.brandSecondary,
        surface: colors.cardBackground,
        error: colors.statusError,
      ),
      textTheme: AppTypography.createTextTheme(textPrimary: colors.textPrimary),
      extensions: const [colors, spacing, motion],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.cardBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle),
          borderRadius: BorderRadius.circular(spacing.cardRadius),
        ),
      ),
    );
  }

  static ThemeData createDarkTheme() {
    const colors = AppColors.dark;
    const spacing = AppSpacing.regular;
    const motion = AppMotion.standard;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        primary: colors.brandPrimary,
        secondary: colors.brandSecondary,
        surface: colors.cardBackground,
        error: colors.statusError,
      ),
      textTheme: AppTypography.createTextTheme(textPrimary: colors.textPrimary),
      extensions: const [colors, spacing, motion],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.cardBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle),
          borderRadius: BorderRadius.circular(spacing.cardRadius),
        ),
      ),
    );
  }
}
