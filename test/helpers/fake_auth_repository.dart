import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ugcult/features/auth/domain/entities/auth_state.dart';
import 'package:ugcult/features/auth/domain/entities/user_entity.dart';
import 'package:ugcult/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final UserAuthState initialAuthState;

  FakeAuthRepository({
    this.initialAuthState = const UserAuthState.unauthenticated(),
  });

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<UserAuthState> getCurrentAuthState() async => initialAuthState;

  @override
  Future<void> sendPhoneOtp(String phone) async {}

  @override
  Future<UserAuthState> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return UserAuthState.authenticated(
      user: const AppUser(
        id: 'mock-user-id',
        role: UserRole.creator,
        phone: '+201012345678',
        phoneVerified: true,
      ),
    );
  }

  @override
  Future<UserAuthState> completeOnboarding(Map<String, dynamic> params) async {
    return UserAuthState.authenticated(
      user: const AppUser(
        id: 'mock-user-id',
        role: UserRole.creator,
        phone: '+201012345678',
        phoneVerified: true,
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}
