import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
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
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: GlassContainer(
          tier: isSelected ? GlassTier.tierA : GlassTier.tierB,
          padding: const EdgeInsets.all(AppTokens.space5),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.16)
                      : AppColors.ink100.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? accentColor : AppColors.ink500,
                  size: 26,
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
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: accentColor,
                            size: 22,
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
