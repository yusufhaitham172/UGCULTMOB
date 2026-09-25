import 'package:flutter/material.dart';
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
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // Trigger auth check and transition after brief splash presentation
    if (widget.autoNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateAfterDelay();
      });
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
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
  }

  @override
  void dispose() {
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
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Baby Blue Disc (Brand Realm)
                      Positioned(
                        left: 14,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.babyBlue.withValues(alpha: 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.babyBlue.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(-4, 6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Baby Pink Disc (Creator Realm)
                      Positioned(
                        right: 14,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.babyPink.withValues(alpha: 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.babyPink.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(4, 6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Optical Match Lens Intersection
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.matchBlend,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink900.withValues(alpha: 0.08),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space6),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'UGCULT',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.0,
                            color: AppColors.ink900,
                          ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Text(
                      'Where Creators & Brands Connect',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.ink500,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
