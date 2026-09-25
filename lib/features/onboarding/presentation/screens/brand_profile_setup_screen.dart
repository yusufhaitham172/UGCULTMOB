import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/app_card.dart';
import 'package:ugcult/core/widgets/app_text_input.dart';
import 'package:ugcult/features/onboarding/presentation/providers/onboarding_provider.dart';

class BrandProfileSetupScreen extends ConsumerStatefulWidget {
  const BrandProfileSetupScreen({super.key});

  @override
  ConsumerState<BrandProfileSetupScreen> createState() =>
      _BrandProfileSetupScreenState();
}

class _BrandProfileSetupScreenState
    extends ConsumerState<BrandProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _logoUrlController = TextEditingController();

  String _selectedIndustry = 'Beauty';
  String _selectedGovernorate = 'Cairo';

  static const List<String> _industries = [
    'Beauty',
    'Tech & Electronics',
    'Fashion & Apparel',
    'Food & Beverage',
    'Fitness & Health',
    'E-commerce & Retail',
    'Real Estate',
    'Marketing Agency',
    'Other',
  ];

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

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(onboardingNotifierProvider.notifier).submitBrandOnboarding(
            companyName: _companyNameController.text.trim(),
            industryCategory: _selectedIndustry,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            websiteUrl: _websiteController.text.trim().isEmpty
                ? null
                : _websiteController.text.trim(),
            logoUrl: _logoUrlController.text.trim().isEmpty
                ? null
                : _logoUrlController.text.trim(),
            governorate: _selectedGovernorate,
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );

      HapticFeedback.mediumImpact();
      if (!mounted) return;
      context.go('/brand/home');
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space5,
                vertical: AppTokens.space6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink900),
                    onPressed: () => context.go('/onboarding/role-selection'),
                  ),
                  const SizedBox(height: AppTokens.space3),

                  Text(
                    'Setup Brand Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink900,
                        ),
                  ),
                  const SizedBox(height: AppTokens.space2),
                  Text(
                    'Publish campaigns, receive 1-tap creator applications, and review lossless UGC video deliverables.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink700,
                        ),
                  ),

                  const SizedBox(height: AppTokens.space6),

                  AppCard(
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextInput(
                          controller: _companyNameController,
                          label: 'Company / Brand Name *',
                          hintText: 'e.g. Glow Cosmetics Egypt',
                        ),
                        const SizedBox(height: AppTokens.space4),

                        Text(
                          'Industry Category *',
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
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedIndustry,
                              items: _industries.map((ind) {
                                return DropdownMenuItem<String>(
                                  value: ind,
                                  child: Text(ind, style: const TextStyle(color: AppColors.ink900)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedIndustry = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _descriptionController,
                          label: 'Company Description',
                          hintText: 'Organic skincare products formulated specifically for the Egyptian climate.',
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _websiteController,
                          label: 'Website URL',
                          hintText: 'https://glowcosmetics.eg',
                        ),
                        const SizedBox(height: AppTokens.space4),

                        Text(
                          'Headquarters Governorate',
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
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedGovernorate,
                              items: _governorates.map((gov) {
                                return DropdownMenuItem<String>(
                                  value: gov,
                                  child: Text(gov, style: const TextStyle(color: AppColors.ink900)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGovernorate = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),

                        AppTextInput(
                          controller: _emailController,
                          label: 'Official Contact Email (Optional)',
                          hintText: 'contact@brand.eg',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.space6),

                  AppButton(
                    label: 'Complete Brand Setup',
                    variant: AppButtonVariant.primary,
                    role: AppButtonRole.brand,
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
