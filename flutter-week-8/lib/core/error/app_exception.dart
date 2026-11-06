import 'package:dio/dio.dart';

/// Тип ошибки — по нему UI решает, что показать пользователю.
enum AppErrorType { noConnection, timeout, client, server, parse, unknown }

/// Единая ошибка приложения. UI получает только понятное [message],
/// технические детали пишутся в лог (см. ApiInterceptor).
class AppException implements Exception {
  const AppException(this.type, this.message, {this.statusCode});

  final AppErrorType type;
  final String message;
  final int? statusCode;

  /// Централизованное преобразование ошибок Dio в ошибки приложения.
  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
            AppErrorType.timeout, 'Сервер долго не отвечает. Попробуйте позже.');
      case DioExceptionType.connectionError:
        return const AppException(
            AppErrorType.noConnection, 'Нет подключения к интернету.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code >= 500) {
          return AppException(
              AppErrorType.server, 'Сервер временно недоступен ($code).',
              statusCode: code);
        }
        if (code == 404) {
          return AppException(AppErrorType.client, 'Данные не найдены (404).',
              statusCode: code);
        }
        return AppException(AppErrorType.client, 'Ошибка запроса ($code).',
            statusCode: code);
      case DioExceptionType.cancel:
        return const AppException(AppErrorType.unknown, 'Запрос отменён.');
      default:
        final inner = e.error;
        if (inner is FormatException || inner is TypeError) {
          return const AppException(
              AppErrorType.parse, 'Сервер вернул некорректные данные.');
        }
        final text = '${e.error} ${e.message}';
        if (text.contains('SocketException') ||
            text.contains('Failed host lookup')) {
          return const AppException(
              AppErrorType.noConnection, 'Нет подключения к интернету.');
        }
        return const AppException(
            AppErrorType.unknown, 'Что-то пошло не так. Попробуйте ещё раз.');
    }
  }

  /// Любую ошибку (Dio, парсинг JSON, прочее) превращает в AppException.
  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return AppException.fromDio(error);
    if (error is FormatException || error is TypeError) {
      return const AppException(
          AppErrorType.parse, 'Сервер вернул некорректные данные.');
    }
    return const AppException(
        AppErrorType.unknown, 'Что-то пошло не так. Попробуйте ещё раз.');
  }

  @override
  String toString() => 'AppException($type, $statusCode): $message';
}
