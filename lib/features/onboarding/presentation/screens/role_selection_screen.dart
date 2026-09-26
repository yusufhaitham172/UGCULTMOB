import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/bouncy_scale.dart';
import 'package:ugcult/core/widgets/glass_container.dart';
import 'package:ugcult/features/auth/domain/entities/user_entity.dart';
import 'package:ugcult/features/onboarding/presentation/providers/onboarding_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.canvasGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space5,
              vertical: AppTokens.space6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTokens.space4),
                Text(
                  'Choose Your Journey',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.ink900,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Select your role to get started. Your role is permanent and cannot be changed after registration.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink700,
                        height: 1.4,
                      ),
                ),

                const SizedBox(height: AppTokens.space8),

                // Creator Card (Baby Pink Realm)
                _RoleCard(
                  title: "I'm a Creator",
                  subtitle:
                      'Showcase your video portfolio, apply to brand campaigns with 1 tap, and get paid for your authentic content.',
                  icon: Icons.videocam_rounded,
                  accentColor: AppColors.babyPinkSolid,
                  glowColor: const Color(0x38F09BBB),
                  borderColor: state.selectedRole == UserRole.creator
                      ? AppColors.babyPinkSolid
                      : AppColors.ink100,
                  isSelected: state.selectedRole == UserRole.creator,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.selectRole(UserRole.creator);
                  },
                ),

                const SizedBox(height: AppTokens.space4),

                // Brand Card (Baby Blue Realm)
                _RoleCard(
                  title: "I'm a Brand",
                  subtitle:
                      'Publish campaigns without approval delays, review creator applicants, and scale your brand with Egyptian creators.',
                  icon: Icons.business_rounded,
                  accentColor: AppColors.babyBlueSolid,
                  glowColor: const Color(0x3889CFF0),
                  borderColor: state.selectedRole == UserRole.brand
                      ? AppColors.babyBlueSolid
                      : AppColors.ink100,
                  isSelected: state.selectedRole == UserRole.brand,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.selectRole(UserRole.brand);
                  },
                ),

                const Spacer(),

                AppButton(
                  label: state.selectedRole == UserRole.creator
                      ? 'Continue as Creator'
                      : state.selectedRole == UserRole.brand
                          ? 'Continue as Brand'
                          : 'Select a Role',
                  variant: AppButtonVariant.primary,
                  role: state.selectedRole == UserRole.creator
                      ? AppButtonRole.creator
                      : AppButtonRole.brand,
                  isFullWidth: true,
                  onPressed: state.selectedRole == null
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          if (state.selectedRole == UserRole.creator) {
                            context.go('/onboarding/creator-profile');
                          } else {
                            context.go('/onboarding/brand-profile');
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color glowColor;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.glowColor,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyScale(
      onTap: onTap,
      scaleDownFactor: 0.98,
      child: AnimatedContainer(
        duration: AppTokens.durationFast,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: AppTokens.radiusLg,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [AppColors.shadowSm],
        ),
        child: GlassContainer(
          tier: isSelected ? GlassTier.tierA : GlassTier.tierB,
          borderRadius: AppTokens.radiusLg,
          padding: const EdgeInsets.all(AppTokens.space5),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppTokens.durationFast,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.18)
                      : AppColors.ink100.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? accentColor : AppColors.ink500,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink900,
                              ),
                        ),
                        const Spacer(),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.8,
                          duration: AppTokens.durationFast,
                          curve: Curves.easeOutBack,
                          child: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: accentColor,
                                  size: 22,
                                )
                              : Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.ink300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.ink700,
                            height: 1.4,
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
