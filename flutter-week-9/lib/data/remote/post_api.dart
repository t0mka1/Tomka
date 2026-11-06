import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';

part 'post_api.g.dart';

/// Описание REST API JSONPlaceholder. Реализацию генерирует Retrofit.
@RestApi()
abstract class PostApi {
  factory PostApi(Dio dio, {String? baseUrl}) = _PostApi;

  /// 1. Список постов с пагинацией.
  /// 3. Посты конкретного пользователя (если передан userId).
  @GET('/posts')
  Future<List<Post>> getPosts(
    @Query('_page') int page,
    @Query('_limit') int limit, {
    @Query('userId') int? userId,
  });

  /// 2. Подробная информация о посте.
  @GET('/posts/{id}')
  Future<Post> getPost(@Path('id') int id);

  /// 4. Комментарии к посту.
  @GET('/posts/{id}/comments')
  Future<List<Comment>> getComments(@Path('id') int id);

  /// 5. Создание поста.
  @POST('/posts')
  Future<Post> createPost(@Body() Post post);

  /// Список авторов.
  @GET('/users')
  Future<List<User>> getUsers();

  /// Информация об авторе.
  @GET('/users/{id}')
  Future<User> getUser(@Path('id') int id);
}
