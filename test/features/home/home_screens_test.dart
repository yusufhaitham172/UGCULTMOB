import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/home/presentation/screens/creator_home_screen.dart';
import 'package:ugcult/features/home/presentation/screens/brand_home_screen.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  testWidgets('CreatorHomeScreen renders welcome message and widgets', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MaterialApp(
          home: CreatorHomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome to UGCULT'), findsOneWidget);
    expect(find.text('Phase 2 Development Quick Links'), findsOneWidget);
  });

  testWidgets('BrandHomeScreen renders welcome message and widgets', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MaterialApp(
          home: BrandHomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome to UGCULT'), findsOneWidget);
    expect(find.text('Phase 2 Development Quick Links'), findsOneWidget);
  });
}
