import 'package:flutter_test/flutter_test.dart';
import 'package:travell/main.dart';

void main() {
  testWidgets('Safr splash renders title and subtitle', (tester) async {
    await tester.pumpWidget(const SafrApp());

    expect(find.text('Safr'), findsOneWidget);
    expect(find.text('Explore the world your way'), findsOneWidget);
  });
}
