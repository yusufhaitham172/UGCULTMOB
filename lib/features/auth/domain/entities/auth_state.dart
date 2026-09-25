import 'user_entity.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticatedPendingOnboarding,
  authenticated;
}

class UserAuthState {
  final AuthStatus status;
  final String? userId;
  final String? phone;
  final AppUser? user;
  final CreatorProfile? creatorProfile;
  final BrandProfile? brandProfile;
  final String? errorMessage;

  const UserAuthState({
    required this.status,
    this.userId,
    this.phone,
    this.user,
    this.creatorProfile,
    this.brandProfile,
    this.errorMessage,
  });

  const UserAuthState.initial()
      : this(status: AuthStatus.initial);

  const UserAuthState.unauthenticated({String? errorMessage})
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  const UserAuthState.pendingOnboarding({
    required String userId,
    required String phone,
  }) : this(
          status: AuthStatus.authenticatedPendingOnboarding,
          userId: userId,
          phone: phone,
        );

  UserAuthState.authenticated({
    required AppUser user,
    CreatorProfile? creatorProfile,
    BrandProfile? brandProfile,
  }) : this(
          status: AuthStatus.authenticated,
          userId: user.id,
          phone: user.phone,
          user: user,
          creatorProfile: creatorProfile,
          brandProfile: brandProfile,
        );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isPendingOnboarding => status == AuthStatus.authenticatedPendingOnboarding;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isInitial => status == AuthStatus.initial;

  UserRole? get role => user?.role;
  bool get isCreator => role == UserRole.creator;
  bool get isBrand => role == UserRole.brand;
}
