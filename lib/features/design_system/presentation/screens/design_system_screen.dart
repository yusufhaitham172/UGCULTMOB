import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/widgets.dart';

/// Design System Showcase Screen
/// Allows visual & interactive verification of all Phase 1 foundations, tokens, and primitives
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _inputError;
  bool _isLoadingButton = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.ambientCanvas,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Design System Gallery'),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppTokens.space4),
              child: StatusPill(
                label: 'Phase 1',
                variant: PillVariant.brand,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space5,
            vertical: AppTokens.space4,
          ),
          children: [
            // 1. Header Banner
            _buildSectionHeader('1. Brand Metaphor', 'Two Tints, One Lens'),
            const SizedBox(height: AppTokens.space3),
            GlassContainer(
              variant: GlassVariant.matchBlend,
              borderRadius: AppTokens.radiusXl,
              padding: const EdgeInsets.all(AppTokens.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.blue400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space1),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.pink400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space3),
                      Text(
                        'The Match Blend',
                        style: AppTypography.headline.copyWith(
                          color: AppColors.ink900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space2),
                  Text(
                    'Egypt’s premier UGC marketplace. Baby Blue denotes brand trust; Baby Pink denotes creator energy; the blend signifies connection.',
                    style: AppTypography.subhead.copyWith(
                      color: AppColors.ink700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTokens.space8),

            // 2. Liquid Glass Containers
            _buildSectionHeader('2. Liquid Glass Primitives', '3 Hardware Tiers & Variants'),
            const SizedBox(height: AppTokens.space3),
            Wrap(
              spacing: AppTokens.space3,
              runSpacing: AppTokens.space3,
              children: [
                SizedBox(
                  width: 155,
                  child: GlassContainer(
                    variant: GlassVariant.regular,
                    padding: const EdgeInsets.all(AppTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Regular Lens', style: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppTokens.space1),
                        Text('Tier A / Blur 24', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 155,
                  child: GlassContainer(
                    variant: GlassVariant.tintedBlue,
                    padding: const EdgeInsets.all(AppTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Brand Tint', style: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600, color: AppColors.blue700)),
                        const SizedBox(height: AppTokens.space1),
                        Text('Baby Blue 300', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 155,
                  child: GlassContainer(
                    variant: GlassVariant.tintedPink,
                    padding: const EdgeInsets.all(AppTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Creator Tint', style: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600, color: AppColors.pink700)),
                        const SizedBox(height: AppTokens.space1),
                        Text('Baby Pink 300', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 155,
                  child: GlassContainer(
                    tier: GlassTier.tierC,
                    variant: GlassVariant.regular,
                    padding: const EdgeInsets.all(AppTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tier C Frost', style: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppTokens.space1),
                        Text('94% Opaque fallback', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTokens.space8),

            // 3. UI Primitives: Buttons
            _buildSectionHeader('3. Interactive Buttons', 'Fluid Springs & Micro-Haptics'),
            const SizedBox(height: AppTokens.space3),
            AppButton(
              label: 'Brand Primary Action',
              role: AppButtonRole.brand,
              onPressed: () {},
            ),
            const SizedBox(height: AppTokens.space3),
            AppButton(
              label: 'Creator Primary Action',
              role: AppButtonRole.creator,
              onPressed: () {},
            ),
            const SizedBox(height: AppTokens.space3),
            AppButton(
              label: 'Match Moment Action',
              variant: AppButtonVariant.matchBlend,
              onPressed: () {
                setState(() {
                  _isLoadingButton = !_isLoadingButton;
                });
              },
              isLoading: _isLoadingButton,
            ),
            const SizedBox(height: AppTokens.space3),
            AppButton(
              label: 'Secondary Glass Action',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: AppTokens.space3),
            AppButton(
              label: 'Destructive Action',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
            ),

            const SizedBox(height: AppTokens.space8),

            // 4. Text Input
            _buildSectionHeader('4. Input Fields', 'Concentric Paper Container & Focus Rings'),
            const SizedBox(height: AppTokens.space3),
            AppTextInput(
              controller: _textController,
              label: 'Egyptian Mobile Number',
              hintText: 'e.g. 01012345678',
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.ink500),
              errorText: _inputError,
              onChanged: (val) {
                if (val.isNotEmpty && !val.startsWith('01')) {
                  setState(() {
                    _inputError = 'Must start with 010, 011, 012, or 015';
                  });
                } else {
                  setState(() {
                    _inputError = null;
                  });
                }
              },
            ),

            const SizedBox(height: AppTokens.space8),

            // 5. Paper Cards & Concentricity
            _buildSectionHeader('5. Paper Cards', 'Layer 2 Pure White + Tinted Blue Shadow'),
            const SizedBox(height: AppTokens.space3),
            AppCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AvatarBadge(
                        name: 'Glow Cosmetics',
                        role: AvatarRole.brand,
                        isVerified: true,
                        size: 44,
                      ),
                      const SizedBox(width: AppTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glow Cosmetics Egypt', style: AppTypography.headline),
                            Text('Beauty & Skincare · Cairo', style: AppTypography.caption),
                          ],
                        ),
                      ),
                      const StatusPill(label: 'Cash + Gift', variant: PillVariant.success),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space3),
                  Text(
                    'Summer Skincare Reel Campaign',
                    style: AppTypography.title3,
                  ),
                  const SizedBox(height: AppTokens.space1),
                  Text(
                    'Looking for 5 passionate creators to test our organic hyaluronic serum and create 30-sec reels.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Row(
                    children: [
                      const StatusPill(label: 'Video', variant: PillVariant.brand),
                      const SizedBox(width: AppTokens.space2),
                      const StatusPill(label: '3 spots left', variant: PillVariant.warning),
                      const Spacer(),
                      Text(
                        '750 EGP',
                        style: AppTypography.tabular(
                          AppTypography.headline.copyWith(color: AppColors.ink900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTokens.space8),

            // 6. Avatars & Status Pills
            _buildSectionHeader('6. Avatars & Badges', 'Role Borders & Status Indicators'),
            const SizedBox(height: AppTokens.space3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                AvatarBadge(name: 'Salma UGC', role: AvatarRole.creator, size: 54),
                AvatarBadge(name: 'Tech Brand', role: AvatarRole.brand, isVerified: true, size: 54),
                AvatarBadge(name: 'Guest User', role: AvatarRole.neutral, size: 54),
              ],
            ),
            const SizedBox(height: AppTokens.space4),
            Wrap(
              spacing: AppTokens.space2,
              runSpacing: AppTokens.space2,
              children: const [
                StatusPill(label: 'Approved', variant: PillVariant.success),
                StatusPill(label: 'Revision Requested', variant: PillVariant.warning),
                StatusPill(label: 'Disputed', variant: PillVariant.danger),
                StatusPill(label: 'Creator', variant: PillVariant.creator),
                StatusPill(label: 'Brand', variant: PillVariant.brand),
                StatusPill(label: 'Neutral', variant: PillVariant.neutral),
              ],
            ),

            const SizedBox(height: AppTokens.space8),

            // 7. Shimmer Skeletons
            _buildSectionHeader('7. Shimmer Skeleton', 'Perceived Performance Loaders'),
            const SizedBox(height: AppTokens.space3),
            Row(
              children: const [
                ShimmerLoader.circular(size: 48),
                SizedBox(width: AppTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoader.rectangular(width: double.infinity, height: 16),
                      SizedBox(height: AppTokens.space2),
                      ShimmerLoader.rectangular(width: 140, height: 12),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTokens.space14),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title2),
        const SizedBox(height: AppTokens.space1),
        Text(subtitle, style: AppTypography.footnote),
      ],
    );
  }
}
