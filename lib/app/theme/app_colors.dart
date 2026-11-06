import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.statusSuccess,
    required this.statusError,
    required this.statusWarning,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.headerBanner,
    required this.harborNavy,
    required this.harborGold,
    required this.freshSkyBlue,
    required this.accentGreen,
    required this.accentOrange,
    required this.tagBlue,
    required this.tagBackground,
    required this.tableHeader,
  });

  final Color brandPrimary;
  final Color brandSecondary;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color statusSuccess;
  final Color statusError;
  final Color statusWarning;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color headerBanner;
  final Color harborNavy;
  final Color harborGold;
  final Color freshSkyBlue;
  final Color accentGreen;
  final Color accentOrange;
  final Color tagBlue;
  final Color tagBackground;
  final Color tableHeader;

  static const light = AppColors(
    brandPrimary: Color(0xFF162347),
    brandSecondary: Color(0xFF2DA1E7),
    background: Color(0xFFEEF3F8),
    surface: Color(0xFFF5F8FC),
    cardBackground: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFDCE5F0),
    textPrimary: Color(0xFF152042),
    textSecondary: Color(0xFF52637A),
    textTertiary: Color(0xFF8798AD),
    statusSuccess: Color(0xFF10B981),
    statusError: Color(0xFFDC2626),
    statusWarning: Color(0xFFDCA842),
    shimmerBase: Color(0xFFDCE5F0),
    shimmerHighlight: Color(0xFFEEF3F8),
    headerBanner: Color(0xFF152244),
    harborNavy: Color(0xFF152042),
    harborGold: Color(0xFFDCA842),
    freshSkyBlue: Color(0xFF2DA1E7),
    accentGreen: Color(0xFF1E9E6A),
    accentOrange: Color(0xFFDCA842),
    tagBlue: Color(0xFF2DA1E7),
    tagBackground: Color(0xFFEAF5FC),
    tableHeader: Color(0xFFE9EFF6),
  );

  static const dark = AppColors(
    brandPrimary: Color(0xFF2DA1E7),
    brandSecondary: Color(0xFFDCA842),
    background: Color(0xFF0E162B),
    surface: Color(0xFF152244),
    cardBackground: Color(0xFF162347),
    borderSubtle: Color(0xFF253864),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF9FB0C7),
    textTertiary: Color(0xFF6E829E),
    statusSuccess: Color(0xFF10B981),
    statusError: Color(0xFFEF4444),
    statusWarning: Color(0xFFDCA842),
    shimmerBase: Color(0xFF152244),
    shimmerHighlight: Color(0xFF253864),
    headerBanner: Color(0xFF111B36),
    harborNavy: Color(0xFF152042),
    harborGold: Color(0xFFDCA842),
    freshSkyBlue: Color(0xFF2DA1E7),
    accentGreen: Color(0xFF10B981),
    accentOrange: Color(0xFFDCA842),
    tagBlue: Color(0xFF2DA1E7),
    tagBackground: Color(0xFF1B2C54),
    tableHeader: Color(0xFF1E305A),
  );

  @override
  AppColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? statusSuccess,
    Color? statusError,
    Color? statusWarning,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? headerBanner,
    Color? harborNavy,
    Color? harborGold,
    Color? freshSkyBlue,
    Color? accentGreen,
    Color? accentOrange,
    Color? tagBlue,
    Color? tagBackground,
    Color? tableHeader,
  }) {
    return AppColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusError: statusError ?? this.statusError,
      statusWarning: statusWarning ?? this.statusWarning,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      headerBanner: headerBanner ?? this.headerBanner,
      harborNavy: harborNavy ?? this.harborNavy,
      harborGold: harborGold ?? this.harborGold,
      freshSkyBlue: freshSkyBlue ?? this.freshSkyBlue,
      accentGreen: accentGreen ?? this.accentGreen,
      accentOrange: accentOrange ?? this.accentOrange,
      tagBlue: tagBlue ?? this.tagBlue,
      tagBackground: tagBackground ?? this.tagBackground,
      tableHeader: tableHeader ?? this.tableHeader,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      headerBanner: Color.lerp(headerBanner, other.headerBanner, t)!,
      harborNavy: Color.lerp(harborNavy, other.harborNavy, t)!,
      harborGold: Color.lerp(harborGold, other.harborGold, t)!,
      freshSkyBlue: Color.lerp(freshSkyBlue, other.freshSkyBlue, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      tagBlue: Color.lerp(tagBlue, other.tagBlue, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
      tableHeader: Color.lerp(tableHeader, other.tableHeader, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
