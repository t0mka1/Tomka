import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../data/repositories/post_repository.dart';

/// Состояние экрана списка постов.
enum PostsStatus { loading, success, error, cached }

class PostsProvider extends ChangeNotifier {
  PostsProvider(this._repository);

  final PostRepository _repository;

  // --- Основная загрузка списка ---
  PostsStatus status = PostsStatus.loading;
  String? errorMessage;
  List<Post> _posts = [];
  int _page = 0;
  bool hasMore = true;

  // --- Подгрузка следующей страницы (отдельное состояние!) ---
  bool isLoadingMore = false;
  String? loadMoreError;

  // --- Фильтры ---
  int? selectedUserId;
  String searchQuery = '';
  bool sortDescending = false;

  // --- Авторы для фильтра и формы ---
  List<User> users = [];

  // --- Посты, созданные в приложении ---
  final List<Post> _localPosts = [];

  /// Номер текущего «поколения» запросов. При смене фильтра увеличивается,
  /// и ответы на старые запросы игнорируются — результаты не смешиваются.
  int _generation = 0;

  /// Посты для отображения: локальные + загруженные, с поиском и сортировкой.
  /// Поиск и сортировка работают только по уже загруженным постам.
  List<Post> get visiblePosts {
    final local = _localPosts.where(
        (p) => selectedUserId == null || p.userId == selectedUserId);
    final query = searchQuery.trim().toLowerCase();
    final result = [...local, ..._posts]
        .where((p) => query.isEmpty || p.title.toLowerCase().contains(query))
        .toList();
    result.sort((a, b) {
      final cmp = (a.id ?? 0).compareTo(b.id ?? 0);
      return sortDescending ? -cmp : cmp;
    });
    return result;
  }

  int get loadedCount => _posts.length;

  bool get hasActiveFilters =>
      selectedUserId != null || searchQuery.isNotEmpty || sortDescending;

  /// Первая загрузка / смена фильтра / pull-to-refresh.
  Future<void> loadInitial() async {
    final generation = ++_generation;
    _page = 0;
    hasMore = true;
    isLoadingMore = false;
    loadMoreError = null;
    errorMessage = null;

    // 1. Сначала показываем кэш, если он есть.
    final cached = _repository.getCachedPosts(userId: selectedUserId);
    if (cached != null && cached.isNotEmpty) {
      _posts = cached;
      _page = (cached.length / PostRepository.pageSize).ceil();
      status = PostsStatus.cached;
    } else {
      _posts = [];
      status = PostsStatus.loading;
    }
    notifyListeners();

    // 2. Параллельно запрашиваем свежие данные.
    try {
      final fresh = await _repository.fetchPosts(
          page: 1, userId: selectedUserId);
      if (generation != _generation) return; // фильтр уже сменился
      _posts = fresh;
      _page = 1;
      hasMore = fresh.length == PostRepository.pageSize;
      status = PostsStatus.success;
      await _repository.cachePosts(_posts, userId: selectedUserId);
    } on AppException catch (e) {
      if (generation != _generation) return;
      errorMessage = e.message;
      // Не удаляем последний успешный результат при ошибке.
      status = _posts.isNotEmpty ? PostsStatus.cached : PostsStatus.error;
    }
    notifyListeners();
  }

  /// Подгрузка следующей страницы при прокрутке.
  Future<void> loadMore() async {
    // Защита от повторной загрузки одной и той же страницы.
    if (isLoadingMore || !hasMore || status == PostsStatus.loading) return;
    final generation = _generation;
    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final next = await _repository.fetchPosts(
          page: _page + 1, userId: selectedUserId);
      if (generation != _generation) return;
      // Отбрасываем дубликаты по id.
      final ids = _posts.map((p) => p.id).toSet();
      _posts = [..._posts, ...next.where((p) => !ids.contains(p.id))];
      _page++;
      hasMore = next.length == PostRepository.pageSize;
      if (status == PostsStatus.cached) status = PostsStatus.success;
      await _repository.cachePosts(_posts, userId: selectedUserId);
    } on AppException catch (e) {
      if (generation != _generation) return;
      loadMoreError = e.message;
    } finally {
      if (generation == _generation) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadUsers() async {
    try {
      users = await _repository.getUsers();
      notifyListeners();
    } on AppException {
      // Без списка авторов приложение работает, просто фильтр недоступен.
    }
  }

  String authorName(int userId) {
    for (final u in users) {
      if (u.id == userId) return u.name;
    }
    return 'Автор #$userId';
  }

  void selectUser(int? userId) {
    if (userId == selectedUserId) return;
    selectedUserId = userId;
    loadInitial(); // сброс страниц при смене фильтра
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void toggleSort() {
    sortDescending = !sortDescending;
    notifyListeners();
  }

  void resetFilters() {
    final userChanged = selectedUserId != null;
    selectedUserId = null;
    searchQuery = '';
    sortDescending = false;
    if (userChanged) {
      loadInitial();
    } else {
      notifyListeners();
    }
  }

  /// Отправляет пост на сервер и добавляет ответ в локальный список.
  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final created = await _repository.createPost(
        userId: userId, title: title, body: body);
    _localPosts.insert(0, created.copyWith(isLocal: true));
    notifyListeners();
    return created;
  }
}
