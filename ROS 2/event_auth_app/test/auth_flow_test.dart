import 'package:event_auth_app/screens/home_screen.dart';
import 'package:event_auth_app/screens/login_screen.dart';
import 'package:event_auth_app/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

FirebaseException authError(String code) =>
    FirebaseException(plugin: 'firebase_auth', code: code);

Widget app(Widget home) => MaterialApp(
  locale: const Locale('ru'),
  supportedLocales: const [Locale('ru')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: home,
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillRegistration(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('reg_name')), 'Иванов Иван');
  await tester.enterText(find.byKey(const Key('reg_email')), 'ivan@test.ru');
  await tester.enterText(find.byKey(const Key('reg_password')), 'secret1');

  await tapVisible(tester, find.byKey(const Key('reg_date')));
  await tester.tap(find.text('15'));
  await tester.tap(find.text('ОК'));
  await tester.pumpAndSettle();

  await tapVisible(tester, find.byKey(const Key('reg_adult')));
  await tapVisible(tester, find.byTooltip('Больше'));
  await tapVisible(tester, find.byTooltip('Больше'));
  await tapVisible(tester, find.byKey(const Key('reg_female')));

  await tapVisible(tester, find.byKey(const Key('reg_language')));
  await tester.tap(find.text('Kotlin').last);
  await tester.pumpAndSettle();

  await tapVisible(tester, find.byKey(const Key('reg_experience')));
  await tapVisible(tester, find.byKey(const Key('reg_certificate')));
  await tester.enterText(find.byKey(const Key('reg_about')), 'Люблю котиков');
}

void main() {
  testWidgets('пустая форма не отправляется', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var calls = 0;
    await tester.pumpWidget(
      app(RegistrationScreen(register: (_, _) async => calls++)),
    );

    await tapVisible(tester, find.text('Отправить'));

    expect(calls, 0);
    expect(find.text('Вы зарегистрированы'), findsNothing);
    expect(find.text('Укажите дату рождения.'), findsOneWidget);
  });

  testWidgets('в окошке показаны все ответы, пароль скрыт', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final registered = <String>[];
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RegistrationScreen(
                    register: (email, password) async =>
                        registered.addAll([email, password]),
                  ),
                ),
              ),
              child: const Text('открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    await fillRegistration(tester);
    await tapVisible(tester, find.text('Отправить'));

    expect(registered, ['ivan@test.ru', 'secret1']);
    final dialog = find.byType(AlertDialog);
    for (final answer in [
      'ФИО: Иванов Иван',
      'Почта: ivan@test.ru',
      'Пароль: •••••••',
      'Мне исполнилось 14 лет: да',
      'Количество котов: 2',
      'Пол: Ж',
      'Любимый язык: Kotlin',
      'Опыт программирования (лет): 5',
      'Нужен сертификат: да',
      'О себе: Люблю котиков',
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.text(answer)),
        findsOneWidget,
        reason: answer,
      );
    }
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining('Дата рождения: 15.'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('ОК'));
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationScreen), findsNothing);
  });

  testWidgets('занятая почта: окошка нет, виден текст ошибки', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        RegistrationScreen(
          register: (_, _) async => throw authError('email-already-in-use'),
        ),
      ),
    );

    await fillRegistration(tester);
    await tapVisible(tester, find.text('Отправить'));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Эта почта уже зарегистрирована.'), findsOneWidget);
  });

  testWidgets('вход передаёт почту и пароль', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(
      app(
        LoginScreen(
          signIn: (email, password) async => calls.addAll([email, password]),
          register: (_, _) async => null,
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('login_email')), ' a@b.ru ');
    await tester.enterText(find.byKey(const Key('login_password')), 'qwerty1');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(calls, ['a@b.ru', 'qwerty1']);
  });

  testWidgets('неверный пароль показывает ошибку', (tester) async {
    await tester.pumpWidget(
      app(
        LoginScreen(
          signIn: (_, _) async => throw authError('invalid-credential'),
          register: (_, _) async => null,
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('login_email')), 'a@b.ru');
    await tester.enterText(find.byKey(const Key('login_password')), 'wrong');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('Неверная почта или пароль.'), findsOneWidget);
  });

  testWidgets('ссылка ведёт на форму регистрации', (tester) async {
    await tester.pumpWidget(
      app(
        LoginScreen(
          signIn: (_, _) async => null,
          register: (_, _) async => null,
        ),
      ),
    );

    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationScreen), findsOneWidget);
  });

  testWidgets('главный экран и выход', (tester) async {
    var signedOut = false;
    await tester.pumpWidget(
      app(HomeScreen(email: 'a@b.ru', signOut: () async => signedOut = true)),
    );

    expect(find.text('Главный экран приложения'), findsOneWidget);
    await tester.tap(find.text('Выйти'));
    expect(signedOut, isTrue);
  });
}
