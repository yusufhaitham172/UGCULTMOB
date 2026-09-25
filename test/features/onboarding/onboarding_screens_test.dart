import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/auth/presentation/screens/phone_otp_screen.dart';
import 'package:ugcult/features/auth/presentation/screens/splash_screen.dart';
import 'package:ugcult/features/onboarding/presentation/screens/brand_profile_setup_screen.dart';
import 'package:ugcult/features/onboarding/presentation/screens/creator_profile_setup_screen.dart';
import 'package:ugcult/features/onboarding/presentation/screens/role_selection_screen.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  group('Phase 2 Onboarding & Auth Screen Widget Tests', () {
    testWidgets('SplashScreen renders UGCULT title and brand discs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: SplashScreen(autoNavigate: false),
          ),
        ),
      );

      expect(find.text('UGCULT'), findsOneWidget);
      expect(find.text('Where Creators & Brands Connect'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('RoleSelectionScreen renders Creator & Brand options and allows selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: RoleSelectionScreen(),
          ),
        ),
      );

      expect(find.text('Choose Your Journey'), findsOneWidget);
      expect(find.text("I'm a Creator"), findsOneWidget);
      expect(find.text("I'm a Brand"), findsOneWidget);

      // Tap on Creator card
      await tester.tap(find.text("I'm a Creator"));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Creator'), findsOneWidget);

      // Tap on Brand card
      await tester.tap(find.text("I'm a Brand"));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Brand'), findsOneWidget);
    });

    testWidgets('PhoneOtpScreen displays Egyptian country code and mobile input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: PhoneOtpScreen(),
          ),
        ),
      );

      expect(find.text('Welcome to UGCULT'), findsOneWidget);
      expect(find.text('+20'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
    });

    testWidgets('CreatorProfileSetupScreen renders required fields and PII notice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: CreatorProfileSetupScreen(),
          ),
        ),
      );

      expect(find.text('Create Creator Profile'), findsOneWidget);
      expect(find.text('Creator / Display Name *'), findsOneWidget);
      expect(find.text('Egyptian Governorate *'), findsOneWidget);
      expect(find.text('Private Contact Info (Zero-Trust Protected)'), findsOneWidget);
      expect(find.text('Finish Setup & Enter UGCULT'), findsOneWidget);
    });

    testWidgets('BrandProfileSetupScreen renders company fields and setup CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: BrandProfileSetupScreen(),
          ),
        ),
      );

      expect(find.text('Setup Brand Profile'), findsOneWidget);
      expect(find.text('Company / Brand Name *'), findsOneWidget);
      expect(find.text('Industry Category *'), findsOneWidget);
      expect(find.text('Complete Brand Setup'), findsOneWidget);
    });
  });
}
