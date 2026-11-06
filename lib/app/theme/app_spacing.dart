import 'package:flutter/material.dart';

class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.cardRadius,
    required this.buttonRadius,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double cardRadius;
  final double buttonRadius;

  static const regular = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
    cardRadius: 16.0,
    buttonRadius: 12.0,
  );

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? cardRadius,
    double? buttonRadius,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: (xs + (other.xs - xs) * t),
      sm: (sm + (other.sm - sm) * t),
      md: (md + (other.md - md) * t),
      lg: (lg + (other.lg - lg) * t),
      xl: (xl + (other.xl - xl) * t),
      xxl: (xxl + (other.xxl - xxl) * t),
      cardRadius: (cardRadius + (other.cardRadius - cardRadius) * t),
      buttonRadius: (buttonRadius + (other.buttonRadius - buttonRadius) * t),
    );
  }
}

extension AppSpacingContext on BuildContext {
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? AppSpacing.regular;
}
