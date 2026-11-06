import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';

/// Простой кэш постов в SharedPreferences.
/// Для каждого фильтра (все посты / конкретный автор) — свой ключ.
class PostCache {
  PostCache(this._prefs);

  final SharedPreferences _prefs;

  String _key(int? userId) => 'posts_cache_${userId ?? 'all'}';

  Future<void> savePosts(List<Post> posts, {int? userId}) async {
    final data = jsonEncode(posts.map((p) => p.toJson()).toList());
    await _prefs.setString(_key(userId), data);
  }

  /// Возвращает null, если кэша нет или он повреждён.
  List<Post>? readPosts({int? userId}) {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
