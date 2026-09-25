import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/app/app.dart';
import 'package:ugcult/core/widgets/widgets.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'helpers/fake_auth_repository.dart';

void main() {
  group('Phase 1 Design System Primitives Test Suite', () {
    testWidgets('GlassContainer renders across Tier A, B, and C', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                GlassContainer(
                  tier: GlassTier.tierA,
                  child: Text('Tier A Glass'),
                ),
                GlassContainer(
                  tier: GlassTier.tierB,
                  variant: GlassVariant.tintedBlue,
                  child: Text('Tier B Glass'),
                ),
                GlassContainer(
                  tier: GlassTier.tierC,
                  variant: GlassVariant.tintedPink,
                  child: Text('Tier C Glass'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tier A Glass'), findsOneWidget);
      expect(find.text('Tier B Glass'), findsOneWidget);
      expect(find.text('Tier C Glass'), findsOneWidget);
    });

    testWidgets('AppButton executes onPressed callback and displays loading state',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Apply with 1 Tap',
              role: AppButtonRole.creator,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Apply with 1 Tap'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Loading state test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Apply with 1 Tap',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Apply with 1 Tap'), findsNothing);
    });

    testWidgets('AppTextInput renders label, hint, and error text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextInput(
              label: 'Phone Number',
              hintText: '01012345678',
              errorText: 'Invalid Egyptian number',
            ),
          ),
        ),
      );

      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
      expect(find.text('Invalid Egyptian number'), findsOneWidget);
    });

    testWidgets('AvatarBadge extracts initials and shows verification icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarBadge(
              name: 'Salma UGC',
              role: AvatarRole.creator,
              isVerified: true,
            ),
          ),
        ),
      );

      expect(find.text('SU'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('StatusPill displays correct label and variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Approved',
              variant: PillVariant.success,
            ),
          ),
        ),
      );

      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('UgcultApp mounts cleanly with Riverpod ProviderScope',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const UgcultApp(),
        ),
      );
      await tester.pump();

      expect(find.text('UGCULT'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
