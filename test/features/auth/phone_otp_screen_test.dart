import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/features/auth/presentation/screens/phone_otp_screen.dart';

void main() {
  testWidgets('PhoneOtpScreen renders phone input and action buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PhoneOtpScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to UGCULT'), findsOneWidget);
    expect(
      find.textContaining('Enter your mobile phone number'),
      findsOneWidget,
    );
    expect(find.text('Send Verification Code'), findsOneWidget);
  });
}
