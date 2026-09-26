import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/bouncy_scale.dart';

void main() {
  testWidgets('BouncyScale renders child and handles tap gesture', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncyScale(
              onTap: () => tapped = true,
              child: const SizedBox(
                width: 100,
                height: 100,
                key: Key('target'),
                child: Text('Click me'),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byKey(const Key('target'));
    expect(finder, findsOneWidget);
    expect(find.text('Click me'), findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(milliseconds: 50));

    // Verify Transform widget is present for scaling
    expect(find.byType(Transform), findsWidgets);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
