import 'package:flutter_test/flutter_test.dart';

import 'package:smokeit/main.dart';

void main() {
  testWidgets('Startseite zeigt alle drei Optionen', (WidgetTester tester) async {
    await tester.pumpWidget(const RauchSimApp());

    expect(find.text('Zigarette'), findsOneWidget);
    expect(find.text('Zigarre'), findsOneWidget);
    expect(find.text('Joint'), findsOneWidget);
  });
}
