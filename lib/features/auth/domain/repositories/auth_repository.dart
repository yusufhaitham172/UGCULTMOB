import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/auth_state.dart';

abstract class AuthRepository {
  /// Sends a 6-digit SMS OTP to the provided Egyptian phone number
  Future<void> sendPhoneOtp(String phone);

  /// Verifies the 6-digit OTP code and restores/creates session
  Future<UserAuthState> verifyPhoneOtp({
    required String phone,
    required String token,
  });

  /// Checks the current Supabase session and fetches user profile via RPC
  Future<UserAuthState> getCurrentAuthState();

  /// Completes the atomic onboarding wizard via Supabase RPC
  Future<UserAuthState> completeOnboarding(Map<String, dynamic> params);

  /// Signs out of Supabase and clears secure storage
  Future<void> signOut();

  /// Stream of raw Supabase Auth changes
  Stream<AuthState> get authStateChanges;
}
