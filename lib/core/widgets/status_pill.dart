import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import 'bouncy_scale.dart';

enum PillVariant {
  neutral,
  brand,
  creator,
  success,
  warning,
  danger,
  info,
}

/// StatusPill
/// Compact pill/chip for status badges, deliverable types, and campaign categories
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    super.key,
    this.variant = PillVariant.neutral,
    this.icon,
    this.isPulsing = false,
    this.onTap,
  });

  final String label;
  final PillVariant variant;
  final Widget? icon;
  final bool isPulsing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Border border, Color dotColor) = switch (variant) {
      PillVariant.neutral => (
          AppColors.ink100.withValues(alpha: 0.6),
          AppColors.ink700,
          Border.all(color: AppColors.ink100, width: 1),
          AppColors.ink500,
        ),
      PillVariant.brand => (
          AppColors.blue100,
          AppColors.blue700,
          Border.all(color: AppColors.blue300.withValues(alpha: 0.5), width: 1),
          AppColors.blue500,
        ),
      PillVariant.creator => (
          AppColors.pink100,
          AppColors.pink700,
          Border.all(color: AppColors.pink300.withValues(alpha: 0.5), width: 1),
          AppColors.pink500,
        ),
      PillVariant.success => (
          AppColors.successBg,
          AppColors.successFg,
          Border.all(color: AppColors.successFg.withValues(alpha: 0.2), width: 1),
          AppColors.successFg,
        ),
      PillVariant.warning => (
          AppColors.warningBg,
          AppColors.warningFg,
          Border.all(color: AppColors.warningFg.withValues(alpha: 0.2), width: 1),
          AppColors.warningFg,
        ),
      PillVariant.danger => (
          AppColors.dangerBg,
          AppColors.dangerFg,
          Border.all(color: AppColors.dangerFg.withValues(alpha: 0.2), width: 1),
          AppColors.dangerFg,
        ),
      PillVariant.info => (
          AppColors.infoBg,
          AppColors.infoFg,
          Border.all(color: AppColors.infoFg.withValues(alpha: 0.2), width: 1),
          AppColors.infoFg,
        ),
    };

    Widget pill = Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTokens.radiusFull,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPulsing) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsetsDirectional.only(end: AppTokens.space1),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppTokens.space1),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return BouncyScale(
        onTap: onTap,
        child: pill,
      );
    }

    return pill;
  }
}
