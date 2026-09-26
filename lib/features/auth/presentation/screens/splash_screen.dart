import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _discConvergence;
  late final Animation<double> _lensBloom;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hapticTriggered = false;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _discConvergence = Tween<double>(begin: 40.0, end: 14.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _lensBloom = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.40 && !_hapticTriggered) {
        _hapticTriggered = true;
        HapticFeedback.lightImpact();
      }
    });

    _controller.forward();

    // Trigger auth check and transition after brief splash presentation
    if (widget.autoNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startNavTimer();
      });
    }
  }

  void _startNavTimer() {
    _navTimer?.cancel();
    _navTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;

      final authState = ref.read(authNotifierProvider);

      if (authState.isAuthenticated) {
        if (authState.isCreator) {
          context.go('/creator/home');
        } else {
          context.go('/brand/home');
        }
      } else if (authState.isPendingOnboarding) {
        context.go('/onboarding/role-selection');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.canvasGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = _discConvergence.value;
                  return SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Baby Blue Disc (Brand Realm)
                        Positioned(
                          left: offset,
                          top: 35,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.babyBlue.withValues(alpha: 0.88),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.babyBlue.withValues(alpha: 0.40),
                                  blurRadius: 28,
                                  offset: const Offset(-4, 6),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Baby Pink Disc (Creator Realm)
                        Positioned(
                          right: offset,
                          top: 35,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.babyPink.withValues(alpha: 0.88),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.babyPink.withValues(alpha: 0.40),
                                  blurRadius: 28,
                                  offset: const Offset(4, 6),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Optical Match Lens Intersection
                        Transform.scale(
                          scale: _lensBloom.value.clamp(0.0, 1.2),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.matchBlend,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: AppColors.ink900.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTokens.space6),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'UGCULT',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.5,
                              color: AppColors.ink900,
                            ),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        'Where Creators & Brands Connect',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink500,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
