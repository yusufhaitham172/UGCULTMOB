import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import 'bouncy_scale.dart';
import 'glass_container.dart';

enum AppButtonVariant {
  /// Primary solid or tinted glass with role accent
  primary,

  /// Match blend gradient button for milestones & connections
  matchBlend,

  /// Secondary frosted glass lens
  secondary,

  /// Destructive action button with danger styling
  destructive,

  /// Ghost / transparent text button
  ghost,
}

enum AppButtonRole {
  brand,
  creator,
  neutral,
}

/// Production AppButton with micro-haptics & fluid states
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.role = AppButtonRole.neutral,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonRole role;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final (Color bgSolid, Color fgColor, Gradient? gradient, BoxBorder? border, List<BoxShadow>? shadow) =
        switch (variant) {
      AppButtonVariant.primary => switch (role) {
          AppButtonRole.creator => (
              AppColors.babyPinkSolid,
              AppColors.white,
              null,
              null,
              isDisabled
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x38F09BBB),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
            ),
          AppButtonRole.brand => (
              AppColors.babyBlueSolid,
              AppColors.white,
              null,
              null,
              isDisabled
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x3889CFF0),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
            ),
          AppButtonRole.neutral => (
              AppColors.ink900,
              AppColors.white,
              null,
              null,
              isDisabled
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x280B1220),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
            ),
        },
      AppButtonVariant.matchBlend => (
          Colors.transparent,
          AppColors.ink900,
          AppColors.matchGradient,
          Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.0),
          isDisabled
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x40A9D4F7),
                    blurRadius: 20,
                    offset: Offset(-2, 6),
                  ),
                  BoxShadow(
                    color: Color(0x40F8C0D6),
                    blurRadius: 20,
                    offset: Offset(2, 6),
                  ),
                ],
        ),
      AppButtonVariant.secondary => (
          AppColors.white,
          AppColors.ink900,
          null,
          Border.all(color: AppColors.ink100, width: 1.0),
          const [AppColors.shadowSm],
        ),
      AppButtonVariant.destructive => (
          AppColors.dangerBg,
          AppColors.dangerFg,
          null,
          Border.all(color: AppColors.dangerFg.withValues(alpha: 0.2), width: 1.0),
          null,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.ink700,
          null,
          null,
          null,
        ),
    };

    final effectiveBg = isDisabled && variant != AppButtonVariant.ghost
        ? AppColors.ink100
        : bgSolid;

    final effectiveFg = isDisabled ? AppColors.ink300 : fgColor;

    Widget buttonContent = Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        horizontal: isFullWidth ? AppTokens.space4 : AppTokens.space6,
      ),
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBg : null,
        gradient: isDisabled ? null : gradient,
        borderRadius: AppTokens.radiusMd,
        border: border,
        boxShadow: shadow,
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppTokens.space2),
                  ],
                  Text(
                    label,
                    style: AppTypography.headline.copyWith(
                      color: effectiveFg,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (variant == AppButtonVariant.secondary && !isDisabled) {
      buttonContent = GlassContainer(
        borderRadius: AppTokens.radiusMd,
        padding: EdgeInsets.zero,
        child: buttonContent,
      );
    }

    if (isDisabled) {
      return buttonContent;
    }

    return BouncyScale(
      onTap: onPressed,
      child: buttonContent,
    );
  }
}
