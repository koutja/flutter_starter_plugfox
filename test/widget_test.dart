import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Initial smoke test', (WidgetTester tester) async {
    // await tester.pumpWidget(const Main());

    expect(find.text('Check'), findsOneWidget);
  });
}
