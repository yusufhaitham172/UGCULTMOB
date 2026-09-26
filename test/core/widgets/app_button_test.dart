import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/app_text_input.dart';
import 'package:ugcult/core/widgets/status_pill.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('AppButton renders label and fires onPressed callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit Action',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Action'), findsOneWidget);
      await tester.tap(find.text('Submit Action'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('AppButton renders MatchBlend variant with gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Match Moment',
              variant: AppButtonVariant.matchBlend,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Match Moment'), findsOneWidget);
    });
  });

  group('AppTextInput Widget Tests', () {
    testWidgets('AppTextInput renders label and errorText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextInput(
              label: 'Full Name',
              hintText: 'Enter your name',
              errorText: 'Name is required',
            ),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);
    });
  });

  group('StatusPill Widget Tests', () {
    testWidgets('StatusPill renders label and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Approved',
              variant: PillVariant.success,
              icon: Icon(Icons.check, size: 12),
            ),
          ),
        ),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
