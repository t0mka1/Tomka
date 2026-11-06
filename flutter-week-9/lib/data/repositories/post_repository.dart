import '../../core/error/app_exception.dart';
import '../local/post_cache.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../remote/post_api.dart';

/// Единая точка доступа к данным. UI не знает ни про Dio, ни про кэш.
class PostRepository {
  PostRepository(this._api, this._cache);

  final PostApi _api;
  final PostCache _cache;

  static const int pageSize = 10;

  /// Любая ошибка превращается в AppException.
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<Post>> fetchPosts({required int page, int? userId}) =>
      _guard(() => _api.getPosts(page, pageSize, userId: userId));

  List<Post>? getCachedPosts({int? userId}) =>
      _cache.readPosts(userId: userId);

  Future<void> cachePosts(List<Post> posts, {int? userId}) =>
      _cache.savePosts(posts, userId: userId);

  Future<Post> getPost(int id) => _guard(() => _api.getPost(id));

  Future<List<Comment>> getComments(int postId) =>
      _guard(() => _api.getComments(postId));

  Future<List<User>> getUsers() => _guard(() => _api.getUsers());

  Future<User> getUser(int id) => _guard(() => _api.getUser(id));

  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) =>
      _guard(() => _api.createPost(
            Post(userId: userId, title: title, body: body),
          ));
}
