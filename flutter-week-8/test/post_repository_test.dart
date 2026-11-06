import 'package:flutter_test/flutter_test.dart';
import 'package:post_explorer/core/error/app_exception.dart';
import 'package:post_explorer/core/network/dio_client.dart';
import 'package:post_explorer/data/local/post_cache.dart';
import 'package:post_explorer/data/remote/post_api.dart';
import 'package:post_explorer/data/repositories/post_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_adapter.dart';

Future<PostRepository> buildRepository(FakeAdapter adapter) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final dio = DioClient(adapter: adapter).dio;
  return PostRepository(PostApi(dio), PostCache(prefs));
}

void main() {
  test('3. Успешная загрузка постов через репозиторий', () async {
    final adapter = FakeAdapter((_) async => (200, fakePosts()));
    final repo = await buildRepository(adapter);

    final posts = await repo.fetchPosts(page: 1);

    expect(posts.length, 10);
    expect(posts.first.title, 'Post 1');
    expect(adapter.requests.single.uri.queryParameters,
        {'_page': '1', '_limit': '10'});
  });

  test('4. Обработка ошибки сервера (500)', () async {
    final adapter = FakeAdapter((_) async => (500, {'error': 'boom'}));
    final repo = await buildRepository(adapter);

    expect(
      () => repo.fetchPosts(page: 1),
      throwsA(isA<AppException>()
          .having((e) => e.type, 'type', AppErrorType.server)
          .having((e) => e.statusCode, 'statusCode', 500)),
    );
  });

  test('Некорректный JSON -> ошибка парсинга, а не падение', () async {
    final adapter = FakeAdapter((_) async => (200, [
          {'id': 'не число', 'title': 1},
        ]));
    final repo = await buildRepository(adapter);

    expect(
      () => repo.fetchPosts(page: 1),
      throwsA(isA<AppException>()
          .having((e) => e.type, 'type', AppErrorType.parse)),
    );
  });

  test('POST создания поста через mock-адаптер', () async {
    final adapter = FakeAdapter((options) async {
      final body = Map<String, dynamic>.from(options.data as Map);
      return (201, {...body, 'id': 101});
    });
    final repo = await buildRepository(adapter);

    final created =
        await repo.createPost(userId: 1, title: 'Hello', body: 'World text');

    expect(created.id, 101);
    expect(created.title, 'Hello');
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/posts');
  });
}
