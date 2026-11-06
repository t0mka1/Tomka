import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_interceptor.dart';

const String kBaseUrl = 'https://jsonplaceholder.typicode.com';

/// Единственный экземпляр Dio на всё приложение.
class DioClient {
  DioClient({String baseUrl = kBaseUrl, HttpClientAdapter? adapter})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            contentType: Headers.jsonContentType,
          ),
        ) {
    dio.interceptors.add(ApiInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true));
    }
    // В тестах подставляем mock-адаптер, чтобы не ходить в интернет.
    if (adapter != null) dio.httpClientAdapter = adapter;
  }

  final Dio dio;
}
