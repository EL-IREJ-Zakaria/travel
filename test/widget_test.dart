// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:travell/main.dart';

void main() {
  testWidgets('Immersive destination screen renders key sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ImmersiveDestinationApp());
    await tester.pumpAndSettle();

    expect(find.text('Select a destination'), findsOneWidget);
    expect(find.text('RESIDENT'), findsOneWidget);
    expect(find.text('Lisa Nilman'), findsOneWidget);
    expect(find.text('2:45 PM'), findsOneWidget);
    expect(find.text('11:11 PM'), findsOneWidget);
    expect(find.text('1 USD'), findsNWidgets(2));
  });
}
