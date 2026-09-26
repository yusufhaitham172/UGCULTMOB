import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';

/// ShimmerLoader
/// High-fidelity dual-tone shimmer skeleton for cards, avatars, and text placeholders.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius,
    this.isCircle = false,
  });

  const ShimmerLoader.rectangular({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius,
  }) : isCircle = false;

  const ShimmerLoader.circular({
    required double size,
    super.key,
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
      baseColor: const Color(0xFFE8EDF5),
      highlightColor: const Color(0xFFF7FAFF),
      period: const Duration(milliseconds: 1400),
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
