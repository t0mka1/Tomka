import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(includeIfNull: false)
class Post {
  const Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isLocal = false,
  });

  /// null у поста, который ещё не отправлен на сервер.
  final int? id;

  @JsonKey(defaultValue: 0)
  final int userId;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String body;

  /// Пост создан в приложении (сервер JSONPlaceholder его не сохраняет).
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isLocal;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({bool? isLocal}) => Post(
        id: id,
        userId: userId,
        title: title,
        body: body,
        isLocal: isLocal ?? this.isLocal,
      );
}
