import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/glass_container.dart';

void main() {
  testWidgets('GlassContainer renders BackdropFilter and child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            child: Text('Glass Text'),
          ),
        ),
      ),
    );

    expect(find.text('Glass Text'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('GlassContainer supports tap with interactive spring', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            onTap: () => tapped = true,
            child: const Text('Tappable Glass'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tappable Glass'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
