import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Auth State Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<UserAuthState> {
  final AuthRepository _repo;
  StreamSubscription? _authSub;

  AuthNotifier(this._repo) : super(const UserAuthState.initial()) {
    _init();
  }

  void _init() {
    _authSub = _repo.authStateChanges.listen((event) {
      // Re-evaluate auth state when Supabase session changes
      checkAuthStatus();
    });
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final stateResult = await _repo.getCurrentAuthState();
      state = stateResult;
    } catch (e) {
      state = UserAuthState.unauthenticated(errorMessage: e.toString());
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _repo.sendPhoneOtp(phone);
    } catch (e) {
      state = UserAuthState.unauthenticated(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<UserAuthState> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final nextState = await _repo.verifyPhoneOtp(phone: phone, token: token);
      state = nextState;
      return nextState;
    } catch (e) {
      state = UserAuthState.unauthenticated(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<UserAuthState> completeOnboarding(Map<String, dynamic> params) async {
    try {
      final nextState = await _repo.completeOnboarding(params);
      state = nextState;
      return nextState;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const UserAuthState.unauthenticated();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
