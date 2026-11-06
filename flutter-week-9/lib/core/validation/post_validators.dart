/// Правила проверки формы создания поста.
/// Возвращают текст ошибки или null, если значение корректно.
class PostValidators {
  const PostValidators._();

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите заголовок';
    if (text.length < 5) return 'Минимум 5 символов';
    if (text.length > 100) return 'Максимум 100 символов';
    return null;
  }

  static String? body(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите текст';
    if (text.length < 10) return 'Минимум 10 символов';
    if (text.length > 1000) return 'Максимум 1000 символов';
    return null;
  }

  static String? author(int? userId) =>
      userId == null ? 'Выберите автора' : null;
}
