import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugcult/features/auth/domain/entities/user_entity.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';

class OnboardingDraftState {
  final UserRole? selectedRole;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingDraftState({
    this.selectedRole,
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingDraftState copyWith({
    UserRole? selectedRole,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingDraftState(
      selectedRole: selectedRole ?? this.selectedRole,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingDraftState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingDraftState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, errorMessage: null);
  }

  Future<void> submitCreatorOnboarding({
    required String displayName,
    String? bio,
    String? avatarUrl,
    required List<String> nicheCategories,
    String? customNiche,
    required String governorate,
    String? tiktokHandle,
    String? instagramHandle,
    String? youtubeHandle,
    String? email,
    // Private Contacts PII
    String? fullLegalName,
    required String contactPhone,
    String? instapayHandle,
    String? shippingGovernorate,
    String? shippingCity,
    String? shippingStreetAddress,
    String? shippingBuildingDetails,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final params = <String, dynamic>{
        'p_role': 'creator',
        'p_display_name': displayName,
        'p_bio': bio,
        'p_avatar_url': avatarUrl,
        'p_niche_categories': nicheCategories,
        'p_custom_niche': customNiche,
        'p_governorate': governorate,
        'p_tiktok_handle': tiktokHandle,
        'p_instagram_handle': instagramHandle,
        'p_youtube_handle': youtubeHandle,
        'p_email': email,
        'p_full_legal_name': fullLegalName ?? displayName,
        'p_contact_phone': contactPhone,
        'p_instapay_handle': instapayHandle,
        'p_shipping_governorate': shippingGovernorate ?? governorate,
        'p_shipping_city': shippingCity,
        'p_shipping_street_address': shippingStreetAddress,
        'p_shipping_building_details': shippingBuildingDetails,
      };

      await _ref.read(authNotifierProvider.notifier).completeOnboarding(params);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> submitBrandOnboarding({
    required String companyName,
    required String industryCategory,
    String? description,
    String? websiteUrl,
    String? logoUrl,
    String? governorate,
    String? email,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final params = <String, dynamic>{
        'p_role': 'brand',
        'p_company_name': companyName,
        'p_industry_category': industryCategory,
        'p_description': description,
        'p_website_url': websiteUrl,
        'p_logo_url': logoUrl,
        'p_governorate': governorate,
        'p_email': email,
      };

      await _ref.read(authNotifierProvider.notifier).completeOnboarding(params);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingDraftState>((ref) {
  return OnboardingNotifier(ref);
});
