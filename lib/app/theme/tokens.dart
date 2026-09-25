import 'package:flutter/material.dart';

/// UGCULT Design System Spacing, Radius & Motion Tokens
/// Defined in DOCS/Design.md Section 4 & 6
abstract final class AppTokens {
  // Spacing (4pt base grid)
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space14 = 56.0;

  // Corner Radii
  static const double rXs = 8.0;
  static const double rSm = 12.0;
  static const double rMd = 16.0;
  static const double rLg = 20.0;
  static const double rXl = 28.0;
  static const double r2Xl = 36.0;
  static const double rFull = 999.0;

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius radius2Xl = BorderRadius.all(Radius.circular(r2Xl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(rFull));

  // Motion Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);

  // Curves (iOS fluid physics)
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;
}
