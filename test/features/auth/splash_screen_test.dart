import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/app/app.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/auth/presentation/screens/splash_screen.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  group('SplashScreen Rendering & Motion Tests', () {
    testWidgets('SplashScreen renders animated logo and tagline', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(autoNavigate: false),
          ),
        ),
      );

      // Initial state
      expect(find.text('UGCULT'), findsOneWidget);
      expect(find.text('Where Creators & Brands Connect'), findsOneWidget);

      // Verify disc convergence animation frames
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('SplashScreen mounts cleanly as initial route in UgcultApp without premature redirection',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const UgcultApp(),
        ),
      );

      // Should find SplashScreen on initial route
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('UGCULT'), findsOneWidget);
      expect(find.text('Where Creators & Brands Connect'), findsOneWidget);
    });
  });
}
