import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../bloc/post_bloc.dart';
import '../models/get_posts.dart';

class PostRepository {
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<void> getPosts(GetPostEvent event, Emitter<PostState> emit) async {
    emit(LoadingPostState());
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode != 200) throw Exception('Bad response');

      final List<dynamic> jsonList = jsonDecode(response.body);
      final posts = jsonList.map((json) => Posts.fromJson(json)).toList();

      emit(FetchedPostsState(posts));
    } catch (e) {
      emit(FailurePostState());
    }
  }
}