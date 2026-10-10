import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Home screen shows tabs and list items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Список'), findsOneWidget);
    expect(find.text('Сетка'), findsOneWidget);
    expect(find.text('Товар №1'), findsOneWidget);
  });

  testWidgets('Switching to Grid tab shows numbered cells', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Сетка'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
