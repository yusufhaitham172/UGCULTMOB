import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';

/// ShimmerLoader
/// Shimmer skeleton primitive for feed cards, media thumbnails, and text lines
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  const ShimmerLoader.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : isCircle = false;

  const ShimmerLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.ink100.withValues(alpha: 0.6),
      highlightColor: AppColors.white.withValues(alpha: 0.9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.ink100,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : (borderRadius ?? AppTokens.radiusMd),
        ),
      ),
    );
  }
}
