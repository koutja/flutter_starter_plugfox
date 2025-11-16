import 'package:flutter_test/flutter_test.dart';

import 'package:starter/main.dart';

void main() {
  testWidgets('Initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Check'), findsOneWidget);
  });
}
