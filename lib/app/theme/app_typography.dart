import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static const double microSize = 10.0;
  static const double captionSize = 11.0;
  static const double bodySmallSize = 12.0;
  static const double bodySize = 13.0;
  static const double subtitleSize = 14.0;
  static const double sectionTitleSize = 16.0;
  static const double pageTitleSize = 18.0;
  static const double kpiDisplaySize = 22.0;

  static TextTheme createTextTheme({required Color textPrimary}) {
    final baseTheme = ThemeData.light().textTheme;
    return GoogleFonts.lexendTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.lexend(
        fontSize: kpiDisplaySize,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.lexend(
        fontSize: kpiDisplaySize,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.lexend(
        fontSize: kpiDisplaySize,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.25,
      ),
      titleLarge: GoogleFonts.lexend(
        fontSize: pageTitleSize,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.lexend(
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.lexend(
        fontSize: subtitleSize,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.35,
      ),
      bodyLarge: GoogleFonts.lexend(
        fontSize: subtitleSize,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.lexend(
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.lexend(
        fontSize: bodySmallSize,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.lexend(
        fontSize: bodySize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.lexend(
        fontSize: bodySmallSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.lexend(
        fontSize: captionSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
    );
  }
}
