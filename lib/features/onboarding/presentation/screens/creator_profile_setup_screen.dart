import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/app_text_input.dart';
import 'package:ugcult/core/widgets/bouncy_scale.dart';
import 'package:ugcult/core/widgets/glass_container.dart';
import 'package:ugcult/core/widgets/status_pill.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/onboarding/presentation/providers/onboarding_provider.dart';

class CreatorProfileSetupScreen extends ConsumerStatefulWidget {
  const CreatorProfileSetupScreen({super.key});

  @override
  ConsumerState<CreatorProfileSetupScreen> createState() =>
      _CreatorProfileSetupScreenState();
}

class _CreatorProfileSetupScreenState
    extends ConsumerState<CreatorProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _customNicheController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _emailController = TextEditingController();

  // PII Controllers
  final _contactPhoneController = TextEditingController();
  final _instapayController = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _shippingBuildingController = TextEditingController();

  String _selectedGovernorate = 'Cairo';
  final Set<String> _selectedNiches = {'Beauty'};
  bool _isOtherNicheSelected = false;

  static const List<String> _governorates = [
    'Cairo',
    'Giza',
    'Alexandria',
    'Dakahlia',
    'Red Sea',
    'Beheira',
    'Faiyum',
    'Gharbia',
    'Ismailia',
    'Menofia',
    'Minya',
    'Qalyubia',
    'New Valley',
    'Suez',
    'Aswan',
    'Assiut',
    'Beni Suef',
    'Port Said',
    'Damietta',
    'Sharkia',
    'South Sinai',
    'Kafr El Sheikh',
    'Matrouh',
    'Luxor',
    'Qena',
    'North Sinai',
    'Sohag',
  ];

  static const List<String> _fixedNiches = [
    'Beauty',
    'Tech',
    'Food',
    'Fashion',
    'Fitness',
    'Lifestyle',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate phone with verified auth phone
    final authState = ref.read(authNotifierProvider);
    if (authState.phone != null && authState.phone!.isNotEmpty) {
      _contactPhoneController.text = authState.phone!;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _customNicheController.dispose();
    _tiktokController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _emailController.dispose();
    _contactPhoneController.dispose();
    _instapayController.dispose();
    _shippingCityController.dispose();
    _shippingAddressController.dispose();
    _shippingBuildingController.dispose();
    super.dispose();
  }

  int get _completionPercentage {
    int score = 0;
    if (_displayNameController.text.trim().isNotEmpty) score += 20;
    if (_bioController.text.trim().isNotEmpty) score += 15;
    if (_selectedNiches.isNotEmpty) score += 15;
    if (_tiktokController.text.trim().isNotEmpty ||
        _instagramController.text.trim().isNotEmpty ||
        _youtubeController.text.trim().isNotEmpty) {
      score += 15;
    }
    if (_instapayController.text.trim().isNotEmpty) score += 15;
    if (_shippingAddressController.text.trim().isNotEmpty) score += 20;
    return score.clamp(0, 100);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNiches.isEmpty && !_isOtherNicheSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one niche category.')),
      );
      return;
    }

    try {
      final List<String> finalNiches = List.from(_selectedNiches);
      if (_isOtherNicheSelected && _customNicheController.text.trim().isNotEmpty) {
        finalNiches.add('Other');
      }

      await ref.read(onboardingNotifierProvider.notifier).submitCreatorOnboarding(
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
            nicheCategories: finalNiches,
            customNiche: _isOtherNicheSelected ? _customNicheController.text.trim() : null,
            governorate: _selectedGovernorate,
            tiktokHandle: _tiktokController.text.trim().isEmpty ? null : _tiktokController.text.trim(),
            instagramHandle: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
            youtubeHandle: _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            fullLegalName: _displayNameController.text.trim(),
            contactPhone: _contactPhoneController.text.trim(),
            instapayHandle: _instapayController.text.trim().isEmpty ? null : _instapayController.text.trim(),
            shippingGovernorate: _selectedGovernorate,
            shippingCity: _shippingCityController.text.trim().isEmpty ? null : _shippingCityController.text.trim(),
            shippingStreetAddress: _shippingAddressController.text.trim().isEmpty ? null : _shippingAddressController.text.trim(),
            shippingBuildingDetails: _shippingBuildingController.text.trim().isEmpty ? null : _shippingBuildingController.text.trim(),
          );

      HapticFeedback.mediumImpact();
      if (!mounted) return;
      context.go('/creator/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Setup failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final completionPct = _completionPercentage;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.canvasGradient,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space5,
                vertical: AppTokens.space6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BouncyScale(
                        onTap: () => context.go('/onboarding/role-selection'),
                        child: Container(
                          padding: const EdgeInsets.all(AppTokens.space2),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppTokens.radiusSm,
                            boxShadow: const [AppColors.shadowSm],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.ink900),
                        ),
                      ),
                      const Spacer(),
                      StatusPill(
                        label: '$completionPct% Complete',
                        variant: completionPct >= 80
                            ? PillVariant.success
                            : PillVariant.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space3),

                  Text(
                    'Create Creator Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.ink900,
                        ),
                  ),
                  const SizedBox(height: AppTokens.space2),
                  Text(
                    'Tell Egyptian brands about yourself. This information will appear on your public creator portfolio.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink700,
                        ),
                  ),

                  const SizedBox(height: AppTokens.space6),

                  // Public Profile Section
                  GlassContainer(
                    tier: GlassTier.tierA,
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Public Information',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink900,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _displayNameController,
                          label: 'Creator / Display Name *',
                          hintText: 'e.g. Salma Ahmed',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _bioController,
                          label: 'Short Bio',
                          hintText: 'UGC creator passionate about authentic skincare & lifestyle routines.',
                          maxLines: 3,
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        Text(
                          'Egyptian Governorate *',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink900,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space4),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppTokens.radiusMd,
                            border: Border.all(color: AppColors.ink100, width: 1.5),
                            boxShadow: const [AppColors.shadowSm],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedGovernorate,
                              items: _governorates.map((gov) {
                                return DropdownMenuItem<String>(
                                  value: gov,
                                  child: Text(gov, style: const TextStyle(color: AppColors.ink900, fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedGovernorate = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        Text(
                          'Niche Categories *',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink900,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Wrap(
                          spacing: AppTokens.space2,
                          runSpacing: AppTokens.space2,
                          children: [
                            ..._fixedNiches.map((niche) {
                              final isSelected = _selectedNiches.contains(niche);
                              return BouncyScale(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    if (isSelected) {
                                      _selectedNiches.remove(niche);
                                    } else {
                                      _selectedNiches.add(niche);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: AppTokens.durationFast,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTokens.space3,
                                    vertical: AppTokens.space2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.babyPinkChip
                                        : AppColors.white,
                                    borderRadius: AppTokens.radiusFull,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.babyPinkSolid
                                          : AppColors.ink100,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: const [AppColors.shadowSm],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: AppColors.babyPinkSolid,
                                        ),
                                        const SizedBox(width: AppTokens.space1),
                                      ],
                                      Text(
                                        niche,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.babyPinkText
                                              : AppColors.ink700,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            BouncyScale(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isOtherNicheSelected = !_isOtherNicheSelected);
                              },
                              child: AnimatedContainer(
                                duration: AppTokens.durationFast,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.space3,
                                  vertical: AppTokens.space2,
                                ),
                                decoration: BoxDecoration(
                                  color: _isOtherNicheSelected
                                      ? AppColors.babyPinkChip
                                      : AppColors.white,
                                  borderRadius: AppTokens.radiusFull,
                                  border: Border.all(
                                    color: _isOtherNicheSelected
                                        ? AppColors.babyPinkSolid
                                        : AppColors.ink100,
                                    width: _isOtherNicheSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: const [AppColors.shadowSm],
                                ),
                                child: Text(
                                  'Other',
                                  style: TextStyle(
                                    color: _isOtherNicheSelected
                                        ? AppColors.babyPinkText
                                        : AppColors.ink700,
                                    fontWeight: _isOtherNicheSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_isOtherNicheSelected) ...[
                          const SizedBox(height: AppTokens.space3),
                          AppTextInput(
                            controller: _customNicheController,
                            label: 'Custom Niche Name',
                            hintText: 'e.g. Travel & Hotels',
                            accentColor: AppColors.babyPinkSolid,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.space5),

                  // Social Media Section
                  GlassContainer(
                    tier: GlassTier.tierA,
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Social Media Profiles',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink900,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        AppTextInput(
                          controller: _tiktokController,
                          label: 'TikTok Handle',
                          hintText: '@creator_name',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        AppTextInput(
                          controller: _instagramController,
                          label: 'Instagram Handle',
                          hintText: '@creator_name',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        AppTextInput(
                          controller: _youtubeController,
                          label: 'YouTube Handle / Channel',
                          hintText: '@creator_channel',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.space5),

                  // Zero-Trust Private Contacts (PII)
                  GlassContainer(
                    tier: GlassTier.tierA,
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                size: 18, color: AppColors.babyPinkSolid),
                            const SizedBox(width: AppTokens.space2),
                            Text(
                              'Private Contact Info (Zero-Trust Protected)',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink900,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          'Your phone, Instapay handle, and address are hidden by PostgreSQL RLS until a brand explicitly approves your campaign application.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.ink500,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _contactPhoneController,
                          label: 'Contact Mobile Number *',
                          hintText: '+201012345678',
                          accentColor: AppColors.babyPinkSolid,
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _instapayController,
                          label: 'Instapay Handle (for off-platform payment)',
                          hintText: 'username@instapay',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _shippingCityController,
                          label: 'Shipping City',
                          hintText: 'e.g. Nasr City, New Cairo, Maadi',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _shippingAddressController,
                          label: 'Street Address',
                          hintText: 'e.g. 15 Abbas El Akkad Street',
                          accentColor: AppColors.babyPinkSolid,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _shippingBuildingController,
                          label: 'Building & Apartment Details',
                          hintText: 'Building 12, Floor 3, Apt 6',
                          accentColor: AppColors.babyPinkSolid,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.space6),

                  AppButton(
                    label: 'Finish Setup & Enter UGCULT',
                    variant: AppButtonVariant.primary,
                    role: AppButtonRole.creator,
                    isLoading: onboardingState.isSubmitting,
                    isFullWidth: true,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
