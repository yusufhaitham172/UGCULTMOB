import 'package:flutter/material.dart';

/// UGCULT Color Primitives & Semantics
/// Defined in DOCS/Design.md Section 4
abstract final class AppColors {
  // Baby Blue (Brand Realm & Trust Foundation)
  static const Color blue50 = Color(0xFFF3F9FF);
  static const Color blue100 = Color(0xFFE3F1FD);
  static const Color blue200 = Color(0xFFCBE5FB);
  static const Color blue300 = Color(0xFFA9D4F7);
  static const Color blue400 = Color(0xFF89CFF0); // Canonical Baby Blue
  static const Color blue500 = Color(0xFF5DB4E8); // Brand solid accent
  static const Color blue600 = Color(0xFF3A93CC);
  static const Color blue700 = Color(0xFF2A73A6); // Brand text (5.1:1 AA on white)
  static const Color blue800 = Color(0xFF1F5680);
  static const Color blue900 = Color(0xFF163B59);

  // Baby Pink (Creator Realm & Creative Energy)
  static const Color pink50 = Color(0xFFFFF5F8);
  static const Color pink100 = Color(0xFFFEE9F0);
  static const Color pink200 = Color(0xFFFCD7E4);
  static const Color pink300 = Color(0xFFF8C0D6);
  static const Color pink400 = Color(0xFFF09BBB); // Canonical Baby Pink
  static const Color pink500 = Color(0xFFE5729D); // Creator solid accent
  static const Color pink600 = Color(0xFFC9507F);
  static const Color pink700 = Color(0xFFA23A64); // Creator text (6.3:1 AA on white)
  static const Color pink800 = Color(0xFF7A2C4C);
  static const Color pink900 = Color(0xFF522034);

  // Ink Neutrals (Blue-Slate Tints - Never dead grey or pure harsh black)
  static const Color ink900 = Color(0xFF1A2138); // Primary text (16:1 AA)
  static const Color ink700 = Color(0xFF3A4360); // Secondary text (9.8:1 AA)
  static const Color ink500 = Color(0xFF67708C); // Tertiary / timestamps (4.9:1 AA)
  static const Color ink300 = Color(0xFFA4ABC0); // Placeholder / disabled
  static const Color ink100 = Color(0xFFDDE1EC); // Dividers & card borders
  static const Color white = Color(0xFFFFFFFF);

  // Feedback Semantics (WCAG AA Compliant)
  static const Color successBg = Color(0xFFD6F3E7);
  static const Color successFg = Color(0xFF1F7A5A);

  static const Color warningBg = Color(0xFFFDEBCB);
  static const Color warningFg = Color(0xFF8A5A12);

  static const Color dangerBg = Color(0xFFFFDCE1);
  static const Color dangerFg = Color(0xFFB3263F);

  static const Color infoBg = Color(0xFFE3F1FD);
  static const Color infoFg = Color(0xFF2A73A6);

  // Gradients
  /// The Match Blend: Application approval, content acceptance, connection
  static const LinearGradient matchBlend = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA9D4F7), Color(0xFFF8C0D6)],
  );

  /// Ambient Canvas Gradient: Top Baby Blue to Bottom Baby Pink
  static const LinearGradient ambientCanvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [blue50, pink50],
  );

  // Tinted Box Shadows (never neutral grey shadows)
  static const BoxShadow shadowSm = BoxShadow(
    color: Color.fromRGBO(70, 110, 180, 0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMd = BoxShadow(
    color: Color.fromRGBO(70, 110, 180, 0.12),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow shadowLg = BoxShadow(
    color: Color.fromRGBO(70, 110, 180, 0.18),
    blurRadius: 40,
    offset: Offset(0, 16),
  );

  static const BoxShadow glowBlue = BoxShadow(
    color: Color.fromRGBO(93, 180, 232, 0.35),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static const BoxShadow glowPink = BoxShadow(
    color: Color.fromRGBO(240, 155, 187, 0.35),
    blurRadius: 20,
    spreadRadius: 2,
  );
}
