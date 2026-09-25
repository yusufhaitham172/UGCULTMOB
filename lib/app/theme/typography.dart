import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// UGCULT Typography Scale
/// Defined in DOCS/Design.md Section 5
/// Typeface: Readex Pro (Latin for MVP, native Arabic harmony ready for Phase 2)
abstract final class AppTypography {
  static TextStyle get largeTitle => GoogleFonts.readexPro(
        fontSize: 34,
        height: 41 / 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.68,
        color: AppColors.ink900,
      );

  static TextStyle get title1 => GoogleFonts.readexPro(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.42,
        color: AppColors.ink900,
      );

  static TextStyle get title2 => GoogleFonts.readexPro(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.22,
        color: AppColors.ink900,
      );

  static TextStyle get title3 => GoogleFonts.readexPro(
        fontSize: 20,
        height: 25 / 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        color: AppColors.ink900,
      );

  static TextStyle get headline => GoogleFonts.readexPro(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.08,
        color: AppColors.ink900,
      );

  static TextStyle get body => GoogleFonts.readexPro(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: AppColors.ink900,
      );

  static TextStyle get callout => GoogleFonts.readexPro(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: AppColors.ink700,
      );

  static TextStyle get subhead => GoogleFonts.readexPro(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.07,
        color: AppColors.ink700,
      );

  static TextStyle get footnote => GoogleFonts.readexPro(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.13,
        color: AppColors.ink500,
      );

  static TextStyle get caption => GoogleFonts.readexPro(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.18,
        color: AppColors.ink700,
      );

  /// Tabular numbers extension helper for amounts and star counters
  static TextStyle tabular(TextStyle style) {
    return style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
