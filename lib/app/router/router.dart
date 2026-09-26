import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';
import '../../features/home/presentation/screens/brand_home_screen.dart';
import '../../features/home/presentation/screens/creator_home_screen.dart';
import '../../features/onboarding/presentation/screens/brand_profile_setup_screen.dart';
import '../../features/onboarding/presentation/screens/creator_profile_setup_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier(ref);
});

/// App Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;

      // Allow splash, design system gallery, and onboarding previews without premature interception
      if (location == '/splash' ||
          location == '/design-system' ||
          location.startsWith('/onboarding') ||
          location.startsWith('/creator') ||
          location.startsWith('/brand')) {
        return null;
      }

      // If still evaluating initial session, remain on splash
      if (authState.isInitial) {
        return location == '/splash' ? null : '/splash';
      }

      // If unauthenticated:
      if (authState.isUnauthenticated) {
        if (location == '/login' || location == '/splash') {
          return null;
        }
        return '/login';
      }

      // If authenticated but needs onboarding:
      if (authState.isPendingOnboarding) {
        if (location.startsWith('/onboarding')) {
          return null;
        }
        return '/onboarding/role-selection';
      }

      // If authenticated and onboarding complete:
      if (authState.isAuthenticated) {
        if (location == '/login' ||
            location == '/splash' ||
            location.startsWith('/onboarding')) {
          return authState.isCreator ? '/creator/home' : '/brand/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const PhoneOtpScreen(),
      ),
      GoRoute(
        path: '/onboarding/role-selection',
        name: 'role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/creator-profile',
        name: 'creator_profile_setup',
        builder: (context, state) => const CreatorProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/brand-profile',
        name: 'brand_profile_setup',
        builder: (context, state) => const BrandProfileSetupScreen(),
      ),
      GoRoute(
        path: '/creator/home',
        name: 'creator_home',
        builder: (context, state) => const CreatorHomeScreen(),
      ),
      GoRoute(
        path: '/brand/home',
        name: 'brand_home',
        builder: (context, state) => const BrandHomeScreen(),
      ),
      GoRoute(
        path: '/design-system',
        name: 'design_system',
        builder: (context, state) => const DesignSystemScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
