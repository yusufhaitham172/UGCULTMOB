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

class CreatorHomeScreen extends ConsumerWidget {
  const CreatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final creator = authState.creatorProfile;
    final displayName = creator?.displayName ?? 'Creator';

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
                      imageUrl: creator?.avatarUrl,
                      name: displayName,
                      size: 48.0,
                      role: AvatarRole.creator,
                    ),
                    const SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink900,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                creator?.governorate ?? 'Egypt',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.ink500,
                                    ),
                              ),
                              const SizedBox(width: AppTokens.space2),
                              if (creator != null && creator.nicheCategories.isNotEmpty)
                                StatusPill(
                                  label: creator.nicheCategories.first,
                                  variant: PillVariant.creator,
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

                // Hero Match Blend Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.space6),
                  decoration: BoxDecoration(
                    gradient: AppColors.matchBlend,
                    borderRadius: AppTokens.radiusXl,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.babyPink.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to UGCULT, $displayName!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink900,
                            ),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        'You are officially onboarded as an Egyptian UGC Creator. Browse active campaigns or view the design gallery.',
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
                        variant: AppButtonVariant.secondary,
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

                // Bio & PII Privacy Card
                GlassContainer(
                  tier: GlassTier.tierA,
                  padding: const EdgeInsets.all(AppTokens.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: AppColors.babyPinkSolid, size: 20),
                          const SizedBox(width: AppTokens.space2),
                          Text(
                            'Zero-Trust Privacy Active',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink900,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Text(
                        'Your Instapay handle, phone number, and shipping address are isolated via Row-Level Security in Supabase until a brand approves your campaign application.',
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
