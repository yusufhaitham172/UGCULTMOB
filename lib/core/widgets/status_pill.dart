import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

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
    super.key,
    required this.label,
    this.variant = PillVariant.neutral,
    this.icon,
    this.onTap,
  });

  final String label;
  final PillVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Border border) = switch (variant) {
      PillVariant.neutral => (
          AppColors.ink100.withValues(alpha: 0.6),
          AppColors.ink700,
          Border.all(color: AppColors.ink100, width: 1),
        ),
      PillVariant.brand => (
          AppColors.blue100,
          AppColors.blue700,
          Border.all(color: AppColors.blue300.withValues(alpha: 0.5), width: 1),
        ),
      PillVariant.creator => (
          AppColors.pink100,
          AppColors.pink700,
          Border.all(color: AppColors.pink300.withValues(alpha: 0.5), width: 1),
        ),
      PillVariant.success => (
          AppColors.successBg,
          AppColors.successFg,
          Border.all(color: AppColors.successFg.withValues(alpha: 0.2), width: 1),
        ),
      PillVariant.warning => (
          AppColors.warningBg,
          AppColors.warningFg,
          Border.all(color: AppColors.warningFg.withValues(alpha: 0.2), width: 1),
        ),
      PillVariant.danger => (
          AppColors.dangerBg,
          AppColors.dangerFg,
          Border.all(color: AppColors.dangerFg.withValues(alpha: 0.2), width: 1),
        ),
      PillVariant.info => (
          AppColors.infoBg,
          AppColors.infoFg,
          Border.all(color: AppColors.infoFg.withValues(alpha: 0.2), width: 1),
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
      return GestureDetector(
        onTap: onTap,
        child: pill,
      );
    }

    return pill;
  }
}
