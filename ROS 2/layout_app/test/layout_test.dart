import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout_app/main.dart';

void main() {
  final opened = <Uri>[];

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    opened.clear();
    await tester.pumpWidget(
      MaterialApp(home: HomePage(openUrl: (url) async => opened.add(url))),
    );
  }

  for (final size in const [Size(360, 640), Size(412, 915), Size(800, 500)]) {
    testWidgets('расположение элементов на экране $size', (tester) async {
      await pump(tester, size);

      final text = tester.getRect(find.text(initialText));
      final git = tester.getRect(
        find.widgetWithText(ElevatedButton, 'перейти на гит'),
      );
      final smolgu = tester.getRect(
        find.widgetWithText(ElevatedButton, 'перейти на сайт СмолГУ!'),
      );
      final cat = tester.getRect(find.byKey(const Key('cat')));

      expect(text.left, 8, reason: 'лейбл слева');
      expect(git.center.dx, size.width / 2, reason: 'кнопка гита по центру');
      expect(smolgu.right, size.width - 8, reason: 'кнопка СмолГУ справа');
      expect(cat.center.dx, size.width / 2, reason: 'котик по центру');
      expect(size.height - cat.bottom, 42, reason: 'ровно 42 пикселя снизу');
      expect(cat.top, greaterThanOrEqualTo(smolgu.bottom));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('нажатия на котика чередуют текст', (tester) async {
    await pump(tester, const Size(360, 640));
    final cat = find.byKey(const Key('cat'));

    for (final expected in [catText, initialText, catText, initialText]) {
      await tester.tap(cat);
      await tester.pump();
      expect(find.text(expected), findsOneWidget);
    }
  });

  testWidgets('кнопки открывают нужные страницы', (tester) async {
    await pump(tester, const Size(360, 640));

    await tester.tap(find.text('перейти на гит'));
    await tester.tap(find.text('перейти на сайт СмолГУ!'));

    expect(opened, [gitUrl, smolguUrl]);
  });
}
