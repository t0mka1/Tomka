import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Добавляет технические заголовки ко всем запросам и логирует ошибки.
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['X-Client'] = 'PostExplorer/1.0';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Технические подробности — только в лог, не в UI.
    debugPrint('[API ERROR] ${err.requestOptions.method} '
        '${err.requestOptions.uri} -> ${err.type} '
        'status=${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
