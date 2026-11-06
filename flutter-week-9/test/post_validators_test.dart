import 'package:flutter_test/flutter_test.dart';
import 'package:post_explorer/core/validation/post_validators.dart';

void main() {
  group('Заголовок поста', () {
    test('Корректный заголовок проходит проверку', () {
      expect(PostValidators.title('Мой первый пост'), isNull);
    });

    test('Пустое значение и null -> просьба ввести заголовок', () {
      expect(PostValidators.title(''), 'Введите заголовок');
      expect(PostValidators.title(null), 'Введите заголовок');
    });

    test('Строка из одних пробелов считается пустой', () {
      expect(PostValidators.title('     '), 'Введите заголовок');
    });

    test('Граница минимальной длины: 4 символа нельзя, 5 можно', () {
      expect(PostValidators.title('abcd'), 'Минимум 5 символов');
      expect(PostValidators.title('abcde'), isNull);
    });

    test('Пробелы по краям не засчитываются в длину', () {
      expect(PostValidators.title('  abc  '), 'Минимум 5 символов');
    });

    test('Граница максимальной длины: 100 символов можно, 101 нельзя', () {
      expect(PostValidators.title('a' * 100), isNull);
      expect(PostValidators.title('a' * 101), 'Максимум 100 символов');
    });
  });

  group('Текст поста', () {
    test('Корректный текст проходит проверку', () {
      expect(PostValidators.body('Текст длиннее десяти символов'), isNull);
    });

    test('Пустой текст -> просьба ввести текст', () {
      expect(PostValidators.body('   '), 'Введите текст');
    });

    test('Граница минимальной длины: 9 символов нельзя, 10 можно', () {
      expect(PostValidators.body('a' * 9), 'Минимум 10 символов');
      expect(PostValidators.body('a' * 10), isNull);
    });

    test('Граница максимальной длины: 1000 символов можно, 1001 нельзя', () {
      expect(PostValidators.body('a' * 1000), isNull);
      expect(PostValidators.body('a' * 1001), 'Максимум 1000 символов');
    });
  });

  group('Автор поста', () {
    test('Автор обязателен', () {
      expect(PostValidators.author(null), 'Выберите автора');
      expect(PostValidators.author(1), isNull);
    });
  });
}
