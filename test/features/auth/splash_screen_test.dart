import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders animated logo and tagline', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(autoNavigate: false),
        ),
      ),
    );

    // Initial pump
    expect(find.text('UGCULT'), findsOneWidget);
    expect(find.text('Where Creators & Brands Connect'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
  });
}
