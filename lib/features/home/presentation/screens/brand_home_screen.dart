import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/app_card.dart';
import 'package:ugcult/core/widgets/avatar_badge.dart';
import 'package:ugcult/core/widgets/glass_container.dart';
import 'package:ugcult/core/widgets/status_pill.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';

class BrandHomeScreen extends ConsumerWidget {
  const BrandHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final brand = authState.brandProfile;
    final companyName = brand?.companyName ?? 'Brand Partner';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.canvasGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space5,
              vertical: AppTokens.space5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
                Row(
                  children: [
                    AvatarBadge(
                      imageUrl: brand?.logoUrl,
                      name: companyName,
                      size: 48.0,
                      role: AvatarRole.brand,
                      isVerified: brand?.isVerified ?? false,
                    ),
                    const SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink900,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                brand?.governorate ?? 'Egypt',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.ink500,
                                    ),
                              ),
                              const SizedBox(width: AppTokens.space2),
                              if (brand != null)
                                StatusPill(
                                  label: brand.industryCategory,
                                  variant: PillVariant.brand,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: AppColors.ink700),
                      tooltip: 'Sign Out',
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppTokens.space6),

                // Hero Brand Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.space6),
                  decoration: BoxDecoration(
                    color: AppColors.babyBlue.withValues(alpha: 0.2),
                    borderRadius: AppTokens.radiusXl,
                    border: Border.all(color: AppColors.babyBlueSolid.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.babyBlue.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to UGCULT, $companyName!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink900,
                            ),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        'Your Brand profile is verified and active. You can create campaigns, review applicant portfolios, and receive lossless UGC video deliverables.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink700,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTokens.space6),

                // Quick Navigation Cards
                AppCard(
                  padding: const EdgeInsets.all(AppTokens.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phase 2 Development Quick Links',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink900,
                            ),
                      ),
                      const SizedBox(height: AppTokens.space4),
                      AppButton(
                        label: 'View Design System Primitives Gallery',
                        variant: AppButtonVariant.primary,
                        role: AppButtonRole.brand,
                        isFullWidth: true,
                        onPressed: () => context.push('/design-system'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      AppButton(
                        label: 'Role Selection Switcher (Dev Mode)',
                        variant: AppButtonVariant.ghost,
                        isFullWidth: true,
                        onPressed: () => context.push('/onboarding/role-selection'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTokens.space5),

                // Brand Governance Card
                GlassContainer(
                  tier: GlassTier.tierA,
                  padding: const EdgeInsets.all(AppTokens.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              color: AppColors.babyBlueSolid, size: 20),
                          const SizedBox(width: AppTokens.space2),
                          Text(
                            'Brand Direct Publishing Active',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink900,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        'UGCULT requires no campaign approval queues. Campaigns are published directly to Egyptian creators once confirmed.',
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
      ),
    );
  }
}
