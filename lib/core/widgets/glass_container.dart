import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import 'bouncy_scale.dart';

/// Visual Rendering Tier for Liquid Glass
enum GlassTier {
  /// Tier A: High-fidelity blur (sigma 24) with dynamic specular rim (iOS Metal / Impeller)
  tierA,

  /// Tier B: Standard blur (sigma 16) with tinted shadow (Standard Android/Web)
  tierB,

  /// Tier C: Frost fallback (94% opaque, no backdrop filter) for low-end / reduced transparency
  tierC,
}

/// Visual Style Variant for Liquid Glass
enum GlassVariant {
  /// Standard neutral translucent lens
  regular,

  /// Tinted Baby Blue for Brand realm
  tintedBlue,

  /// Tinted Baby Pink for Creator realm
  tintedPink,

  /// Match Blend linear gradient for achievements & connections
  matchBlend,

  /// Frosted thick sheet for modals and sheets
  thick,
}

/// Liquid Glass Container
/// Implements Apple WWDC physical material & depth specifications from DOCS/Design.md Section 3
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.variant = GlassVariant.regular,
    this.tier = GlassTier.tierA,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
    this.blurSigma,
    this.onTap,
  });

  final Widget child;
  final GlassVariant variant;
  final GlassTier tier;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double? blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppTokens.radiusLg;
    final isReducedMotion = MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;
    final effectiveTier = isReducedMotion ? GlassTier.tierC : tier;

    // Background fill colors & gradients based on variant
    final Decoration backgroundDecoration = switch (variant) {
      GlassVariant.regular => BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.60),
              Colors.white.withValues(alpha: 0.40),
            ],
          ),
        ),
      GlassVariant.tintedBlue => BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blue300.withValues(alpha: 0.42),
              AppColors.blue100.withValues(alpha: 0.26),
            ],
          ),
        ),
      GlassVariant.tintedPink => BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pink300.withValues(alpha: 0.42),
              AppColors.pink100.withValues(alpha: 0.26),
            ],
          ),
        ),
      GlassVariant.matchBlend => BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFA9D4F7).withValues(alpha: 0.65),
              const Color(0xFFF8C0D6).withValues(alpha: 0.65),
            ],
          ),
        ),
      GlassVariant.thick => BoxDecoration(
          borderRadius: effectiveRadius,
          color: Colors.white.withValues(alpha: 0.85),
        ),
    };

    // 1px directional specular highlight rim
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 1.0,
        );

    final effectiveShadow = boxShadow ??
        const [
          BoxShadow(
            color: Color.fromRGBO(70, 110, 180, 0.12),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ];

    // Tier C: Opaque container fallback without BackdropFilter
    if (effectiveTier == GlassTier.tierC) {
      Widget content = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xF0FFFFFF), // 94% opaque white
          borderRadius: effectiveRadius,
          border: effectiveBorder,
          boxShadow: effectiveShadow,
        ),
        child: child,
      );

      if (onTap != null) {
        content = BouncyScale(
          onTap: onTap,
          child: content,
        );
      }
      return content;
    }

    final double effectiveBlur = blurSigma ?? (effectiveTier == GlassTier.tierA ? 24.0 : 16.0);

    Widget glassCard = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            padding: padding,
            decoration: (backgroundDecoration as BoxDecoration).copyWith(
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      glassCard = BouncyScale(
        onTap: onTap,
        child: glassCard,
      );
    }

    return glassCard;
  }
}
