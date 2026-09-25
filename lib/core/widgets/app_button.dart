import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
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
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Gradient? gradient;
    BoxBorder? border;
    List<BoxShadow>? shadow;

    if (isDisabled) {
      backgroundColor = AppColors.ink100;
      foregroundColor = AppColors.ink300;
    } else {
      switch (widget.variant) {
        case AppButtonVariant.primary:
          backgroundColor = switch (widget.role) {
            AppButtonRole.brand => AppColors.blue500,
            AppButtonRole.creator => AppColors.pink500,
            AppButtonRole.neutral => AppColors.ink900,
          };
          foregroundColor = AppColors.white;
          shadow = switch (widget.role) {
            AppButtonRole.brand => const [AppColors.glowBlue],
            AppButtonRole.creator => const [AppColors.glowPink],
            AppButtonRole.neutral => const [AppColors.shadowSm],
          };
        case AppButtonVariant.matchBlend:
          gradient = AppColors.matchBlend;
          backgroundColor = Colors.transparent;
          foregroundColor = AppColors.ink900;
          shadow = const [AppColors.shadowMd];
        case AppButtonVariant.secondary:
          backgroundColor = Colors.white.withValues(alpha: 0.60);
          foregroundColor = AppColors.ink900;
          border = Border.all(color: Colors.white.withValues(alpha: 0.80), width: 1);
          shadow = const [AppColors.shadowSm];
        case AppButtonVariant.destructive:
          backgroundColor = AppColors.dangerBg;
          foregroundColor = AppColors.dangerFg;
          border = Border.all(color: AppColors.dangerFg.withValues(alpha: 0.3), width: 1);
        case AppButtonVariant.ghost:
          backgroundColor = Colors.transparent;
          foregroundColor = AppColors.ink700;
      }
    }

    Widget content = SizedBox(
      height: widget.height,
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: AppTokens.space2),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.headline.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (widget.variant == AppButtonVariant.secondary && !isDisabled) {
      content = GlassContainer(
        borderRadius: AppTokens.radiusFull,
        height: widget.height,
        variant: GlassVariant.regular,
        child: Center(child: content),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: AppTokens.radiusFull,
          border: border,
          boxShadow: shadow,
        ),
        child: content,
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: widget.isFullWidth ? content : IntrinsicWidth(child: content),
      ),
    );
  }
}
