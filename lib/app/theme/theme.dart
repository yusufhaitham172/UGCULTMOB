import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

/// UGCULT Global App Theme
/// Combines Material 3 architecture with Apple Cupertino fidelity & typography
abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS, // Forces Cupertino physics & native gestures
      scaffoldBackgroundColor: Colors.transparent, // Uses ambient canvas gradient
      colorScheme: ColorScheme.light(
        primary: AppColors.blue500,
        secondary: AppColors.pink500,
        surface: AppColors.white,
        error: AppColors.dangerFg,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.ink900,
        onError: AppColors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle,
        displayMedium: AppTypography.title1,
        displaySmall: AppTypography.title2,
        headlineMedium: AppTypography.title3,
        headlineSmall: AppTypography.headline,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.callout,
        bodySmall: AppTypography.subhead,
        labelLarge: AppTypography.headline,
        labelMedium: AppTypography.footnote,
        labelSmall: AppTypography.caption,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ink100,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headline,
        iconTheme: const IconThemeData(color: AppColors.ink900),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radiusXl,
          side: const BorderSide(color: AppColors.ink100, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
