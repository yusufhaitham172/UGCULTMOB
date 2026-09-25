import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ugcult/core/storage/secure_storage_service.dart';
import 'package:ugcult/features/auth/domain/entities/auth_state.dart';
import 'package:ugcult/features/auth/domain/entities/user_entity.dart';
import 'package:ugcult/features/auth/domain/repositories/auth_repository.dart';
import 'package:ugcult/features/auth/utils/egyptian_phone_formatter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    SupabaseClient? supabase,
    SecureStorageService? secureStorage,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _secureStorage = secureStorage ?? const SecureStorageService();

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<void> sendPhoneOtp(String phone) async {
    final e164Phone = EgyptianPhoneUtils.toE164(phone);
    await _supabase.auth.signInWithOtp(
      phone: e164Phone,
    );
  }

  @override
  Future<UserAuthState> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final e164Phone = EgyptianPhoneUtils.toE164(phone);
    final response = await _supabase.auth.verifyOTP(
      phone: e164Phone,
      token: token.trim(),
      type: OtpType.sms,
    );

    if (response.user == null) {
      throw const AuthException('Verification failed: User not found in session.');
    }

    // Persist JWT token into Secure Storage
    if (response.session?.accessToken != null) {
      await _secureStorage.write('supabase_access_token', response.session!.accessToken);
    }

    return getCurrentAuthState();
  }

  @override
  Future<UserAuthState> getCurrentAuthState() async {
    final sessionUser = _supabase.auth.currentUser;
    if (sessionUser == null) {
      return const UserAuthState.unauthenticated();
    }

    try {
      final rpcResult = await _supabase.rpc('get_current_user_profile');
      final Map<String, dynamic> data = (rpcResult is Map<String, dynamic>)
          ? rpcResult
          : (rpcResult is String ? jsonDecode(rpcResult) : {});

      final bool isOnboarded = data['onboarded'] as bool? ?? false;
      if (!isOnboarded) {
        return UserAuthState.pendingOnboarding(
          userId: sessionUser.id,
          phone: sessionUser.phone ?? '',
        );
      }

      final userData = data['user'] as Map<String, dynamic>?;
      if (userData == null) {
        return UserAuthState.pendingOnboarding(
          userId: sessionUser.id,
          phone: sessionUser.phone ?? '',
        );
      }

      final appUser = AppUser.fromJson(userData);
      CreatorProfile? creatorProfile;
      BrandProfile? brandProfile;

      if (data['creator_profile'] != null) {
        creatorProfile = CreatorProfile.fromJson(
          data['creator_profile'] as Map<String, dynamic>,
        );
      }

      if (data['brand_profile'] != null) {
        brandProfile = BrandProfile.fromJson(
          data['brand_profile'] as Map<String, dynamic>,
        );
      }

      return UserAuthState.authenticated(
        user: appUser,
        creatorProfile: creatorProfile,
        brandProfile: brandProfile,
      );
    } catch (e) {
      debugPrint('[AuthRepo] Error querying profile status: $e');
      // If table/rpc error occurs or user is not yet in public.users
      return UserAuthState.pendingOnboarding(
        userId: sessionUser.id,
        phone: sessionUser.phone ?? '',
      );
    }
  }

  @override
  Future<UserAuthState> completeOnboarding(Map<String, dynamic> params) async {
    final response = await _supabase.rpc('complete_user_onboarding', params: params);
    debugPrint('[AuthRepo] complete_user_onboarding response: $response');
    return getCurrentAuthState();
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('[AuthRepo] Supabase signOut warning: $e');
    }
    await _secureStorage.deleteAll();
  }
}
