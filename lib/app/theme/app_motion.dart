import 'package:flutter/material.dart';

class AppMotion extends ThemeExtension<AppMotion> {
  const AppMotion({
    required this.shortDuration,
    required this.mediumDuration,
    required this.emphasizedDuration,
    required this.standardCurve,
    required this.emphasizedCurve,
  });

  final Duration shortDuration;
  final Duration mediumDuration;
  final Duration emphasizedDuration;
  final Curve standardCurve;
  final Curve emphasizedCurve;

  static const standard = AppMotion(
    shortDuration: Duration(milliseconds: 150),
    mediumDuration: Duration(milliseconds: 300),
    emphasizedDuration: Duration(milliseconds: 500),
    standardCurve: Curves.easeInOutCubic,
    emphasizedCurve: Curves.easeOutCubic,
  );

  @override
  AppMotion copyWith({
    Duration? shortDuration,
    Duration? mediumDuration,
    Duration? emphasizedDuration,
    Curve? standardCurve,
    Curve? emphasizedCurve,
  }) {
    return AppMotion(
      shortDuration: shortDuration ?? this.shortDuration,
      mediumDuration: mediumDuration ?? this.mediumDuration,
      emphasizedDuration: emphasizedDuration ?? this.emphasizedDuration,
      standardCurve: standardCurve ?? this.standardCurve,
      emphasizedCurve: emphasizedCurve ?? this.emphasizedCurve,
    );
  }

  @override
  AppMotion lerp(ThemeExtension<AppMotion>? other, double t) {
    if (other is! AppMotion) return this;
    return this;
  }
}

extension AppMotionContext on BuildContext {
  AppMotion get motion =>
      Theme.of(this).extension<AppMotion>() ?? AppMotion.standard;
}
