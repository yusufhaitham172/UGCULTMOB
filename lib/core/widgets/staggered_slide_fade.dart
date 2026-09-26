import 'dart:async';
import 'package:flutter/material.dart';

/// Staggered Slide & Fade animation container for feed cards, list items, and form groups
class StaggeredSlideFade extends StatefulWidget {
  const StaggeredSlideFade({
    required this.child,
    super.key,
    this.index = 0,
    this.offsetDelta = const Offset(0.0, 0.12),
    this.duration = const Duration(milliseconds: 380),
    this.staggerDuration = const Duration(milliseconds: 40),
  });

  final Widget child;
  final int index;
  final Offset offsetDelta;
  final Duration duration;
  final Duration staggerDuration;

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offsetDelta,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    final delay = widget.staggerDuration * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _staggerTimer = Timer(delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
