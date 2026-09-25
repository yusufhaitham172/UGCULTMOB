import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';

/// AppCard
/// The standard Layer 2 Paper container for feed cards, detail panels, and lists
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.ink100,
    this.borderWidth = 1.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppTokens.radiusXl;

    Widget card = Container(
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: const [AppColors.shadowMd],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: card,
        ),
      );
    }

    return card;
  }
}
