import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';

/// App Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/design-system',
    routes: [
      GoRoute(
        path: '/design-system',
        name: 'design_system',
        builder: (context, state) => const DesignSystemScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/design-system',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
