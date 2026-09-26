import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/staggered_slide_fade.dart';

void main() {
  testWidgets('StaggeredSlideFade renders child and animates in', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StaggeredSlideFade(
            index: 0,
            child: Text('Staggered Item'),
          ),
        ),
      ),
    );

    expect(find.text('Staggered Item'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  });
}
