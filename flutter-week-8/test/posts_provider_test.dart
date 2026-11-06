import 'package:flutter_test/flutter_test.dart';
import 'package:post_explorer/presentation/state/posts_provider.dart';

import 'helpers/fake_adapter.dart';
import 'post_repository_test.dart' show buildRepository;

void main() {
  test('5. Фильтрация постов по автору и по заголовку', () async {
    final adapter = FakeAdapter((options) async {
      final userId = options.queryParameters['userId'];
      if (userId == 2) return (200, fakePosts(from: 11, count: 3, userId: 2));
      return (200, fakePosts());
    });
    final provider = PostsProvider(await buildRepository(adapter));

    await provider.loadInitial();
    expect(provider.visiblePosts.length, 10);

    // Фильтр по автору: уходит запрос с userId, старые посты не смешиваются.
    provider.selectUser(2);
    await Future<void>.delayed(Duration.zero);
    await pumpUntilIdle();
    expect(adapter.requests.last.queryParameters['userId'], 2);
    expect(provider.visiblePosts.every((p) => p.userId == 2), isTrue);
    expect(provider.visiblePosts.length, 3);

    // Поиск по заголовку среди загруженных постов.
    provider.setSearchQuery('post 12');
    expect(provider.visiblePosts.map((p) => p.id), [12]);
  });

  test('6. Защита от дублирующейся загрузки страницы', () async {
    final adapter = FakeAdapter((options) async {
      final page = options.queryParameters['_page'] as int;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return (200, fakePosts(from: (page - 1) * 10 + 1));
    });
    final provider = PostsProvider(await buildRepository(adapter));
    await provider.loadInitial();
    adapter.requests.clear();

    // Пользователь быстро скроллит — loadMore вызывается три раза подряд.
    await Future.wait([
      provider.loadMore(),
      provider.loadMore(),
      provider.loadMore(),
    ]);

    expect(adapter.requests.length, 1);
    expect(adapter.requests.single.queryParameters['_page'], 2);
    expect(provider.visiblePosts.length, 20);
    final ids = provider.visiblePosts.map((p) => p.id).toSet();
    expect(ids.length, 20); // без дубликатов
  });
}

Future<void> pumpUntilIdle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));
