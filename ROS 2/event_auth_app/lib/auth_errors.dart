import 'package:firebase_core/firebase_core.dart';

/// Вход или регистрация по почте и паролю.
typedef AuthAction = Future<Object?> Function(String email, String password);

/// Переводит ошибку Firebase в понятное сообщение.
String authErrorMessage(Object error) {
  if (error is! FirebaseException) return 'Что-то пошло не так: $error';
  final code = error.code;
  if (code.startsWith('api-key-not-valid') || code == 'invalid-api-key') {
    return 'Firebase не настроен: заполни firebase_options.dart.';
  }
  return switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Неверная почта или пароль.',
    'invalid-email' => 'Некорректная почта.',
    'email-already-in-use' => 'Эта почта уже зарегистрирована.',
    'weak-password' => 'Слишком простой пароль: нужно минимум 6 символов.',
    'operation-not-allowed' =>
      'Включи вход по почте в консоли Firebase (Authentication).',
    'network-request-failed' => 'Нет соединения с сервером.',
    'too-many-requests' => 'Слишком много попыток, подожди немного.',
    _ => 'Ошибка Firebase: $code',
  };
}
