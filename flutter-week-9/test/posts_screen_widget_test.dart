import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:post_explorer/data/repositories/post_repository.dart';
import 'package:post_explorer/main.dart';
import 'package:post_explorer/presentation/screens/create_post_screen.dart';
import 'package:post_explorer/presentation/screens/post_details_screen.dart';
import 'package:post_explorer/presentation/state/posts_provider.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_adapter.dart';
import 'post_repository_test.dart' show buildRepository;

/// Сетевые ответы в формате JSONPlaceholder. Реальные запросы не выполняются.
FakeAdapter fakeApi({bool failPosts = false}) {
  return FakeAdapter((options) async {
    final path = options.path;
    if (options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      return (201, {...body, 'id': 101});
    }
    if (path == '/users') {
      return (200, [
        {'id': 1, 'name': 'Анна', 'username': 'anna', 'email': 'anna@test.kz'},
      ]);
    }
    if (path.startsWith('/users/')) {
      return (200, {
        'id': 1,
        'name': 'Анна',
        'username': 'anna',
        'email': 'anna@test.kz',
      });
    }
    if (path.endsWith('/comments')) {
      return (200, [
        {
          'id': 1,
          'postId': 2,
          'name': 'Первый комментарий',
          'email': 'c@test.kz',
          'body': 'Текст комментария',
        },
      ]);
    }
    if (path.startsWith('/posts/')) {
      return (200, {'id': 2, 'userId': 1, 'title': 'Post 2', 'body': 'Body 2'});
    }
    if (failPosts) return (500, {'error': 'boom'});
    return (200, fakePosts(count: 3));
  });
}

/// Запускает настоящие экраны с настоящими Provider и Repository.
/// Подменён только сетевой адаптер.
Future<void> pumpApp(WidgetTester tester, FakeAdapter adapter) async {
  final repository = await buildRepository(adapter);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<PostRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => PostsProvider(repository)
            ..loadUsers()
            ..loadInitial(),
        ),
      ],
      child: const PostExplorerApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Экран списка постов', () {
    testWidgets('Показывает заголовок, элементы управления и посты',
        (tester) async {
      await pumpApp(tester, fakeApi());

      expect(find.widgetWithText(AppBar, 'Post Explorer'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Поиск по заголовку'), findsOneWidget);
      expect(find.text('Все авторы'), findsWidgets);
      expect(find.widgetWithIcon(FloatingActionButton, Icons.add),
          findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Сбросить'), findsOneWidget);
      expect(find.text('Post 1'), findsOneWidget);
      expect(find.text('Post 3'), findsOneWidget);
    });

    testWidgets('Поиск сужает список, а кнопка «Сбросить» возвращает его',
        (tester) async {
      await pumpApp(tester, fakeApi());

      await tester.enterText(find.byType(TextField), 'post 2');
      await tester.pump();

      expect(find.text('Post 2'), findsOneWidget);
      expect(find.text('Post 1'), findsNothing);

      await tester.tap(find.text('Сбросить'));
      await tester.pump();

      expect(find.text('Post 1'), findsOneWidget);
      expect(find.text('Post 3'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
    });

    testWidgets('Поиск без совпадений показывает пустое состояние',
        (tester) async {
      await pumpApp(tester, fakeApi());

      await tester.enterText(find.byType(TextField), 'такого поста нет');
      await tester.pump();

      expect(find.text('Поиск не дал результатов'), findsOneWidget);
      expect(find.text('Post 1'), findsNothing);
    });

    testWidgets('Кнопка сортировки разворачивает порядок постов',
        (tester) async {
      await pumpApp(tester, fakeApi());
      double top(String title) => tester.getTopLeft(find.text(title)).dy;

      expect(top('Post 1'), lessThan(top('Post 3')));

      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pump();

      expect(top('Post 3'), lessThan(top('Post 1')));
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('Ошибка сервера показывает сообщение и кнопку «Повторить»',
        (tester) async {
      await pumpApp(tester, fakeApi(failPosts: true));

      expect(find.text('Сервер временно недоступен (500).'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Повторить'), findsOneWidget);
      expect(find.text('Post 1'), findsNothing);
    });
  });

  group('Переход между экранами', () {
    testWidgets('Нажатие на пост открывает детали, «Назад» возвращает к списку',
        (tester) async {
      await pumpApp(tester, fakeApi());

      await tester.tap(find.text('Post 2'));
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailsScreen), findsOneWidget);
      expect(find.text('Пост #2'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
      expect(find.text('Первый комментарий'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailsScreen), findsNothing);
      expect(find.widgetWithText(AppBar, 'Post Explorer'), findsOneWidget);
    });
  });

  group('Форма создания поста', () {
    Future<void> openForm(WidgetTester tester) async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(CreatePostScreen), findsOneWidget);
    }

    testWidgets('Пустая форма показывает ошибки и ничего не отправляет',
        (tester) async {
      final adapter = fakeApi();
      await pumpApp(tester, adapter);
      await openForm(tester);

      await tester.tap(find.text('Отправить'));
      await tester.pump();

      expect(find.text('Введите заголовок'), findsOneWidget);
      expect(find.text('Введите текст'), findsOneWidget);
      expect(find.text('Выберите автора'), findsOneWidget);
      expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
    });

    testWidgets('Слишком короткие значения не проходят проверку',
        (tester) async {
      final adapter = fakeApi();
      await pumpApp(tester, adapter);
      await openForm(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'abc');
      await tester.enterText(find.byType(TextFormField).at(1), 'коротко');
      await tester.tap(find.text('Отправить'));
      await tester.pump();

      expect(find.text('Минимум 5 символов'), findsOneWidget);
      expect(find.text('Минимум 10 символов'), findsOneWidget);
      expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
    });

    testWidgets('Новый пост появляется в списке с пометкой «создан локально»',
        (tester) async {
      await pumpApp(tester, fakeApi());
      await openForm(tester);

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Новый пост студента');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Текст нового поста');
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Анна').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отправить'));
      // Пока открыт диалог, за ним крутится индикатор отправки, поэтому
      // pumpAndSettle здесь не завершится: ждём ответ и анимацию диалога.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Пост создан'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(CreatePostScreen), findsNothing);
      expect(find.text('Новый пост студента'), findsOneWidget);
      expect(find.text('создан локально'), findsOneWidget);
    });
  });
}
