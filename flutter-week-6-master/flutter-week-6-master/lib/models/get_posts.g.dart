// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_posts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Posts _$PostsFromJson(Map<String, dynamic> json) => Posts(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  body: json['body'] as String, 
  userId: (json['userId'] as num).toInt(),

);

Map<String, dynamic> _$PostsToJson(Posts instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
};
