import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeHandler = Future<(int, Object?)> Function(RequestOptions options);

/// Mock-адаптер Dio: вместо реальной сети отвечает заранее заданными данными
/// и запоминает все запросы.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FakeHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = await handler(options);
    final text = body is String ? body : jsonEncode(body);
    return ResponseBody.fromString(
      text,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

List<Map<String, dynamic>> fakePosts({int from = 1, int count = 10, int userId = 1}) =>
    List.generate(
      count,
      (i) => {
        'id': from + i,
        'userId': userId,
        'title': 'Post ${from + i}',
        'body': 'Body ${from + i}',
      },
    );
