import 'package:flutter_test/flutter_test.dart';
import 'package:post_explorer/data/models/post.dart';
import 'package:post_explorer/data/models/user.dart';

void main() {
  test('1. Успешное преобразование JSON в Post', () {
    final post = Post.fromJson({
      'id': 1,
      'userId': 2,
      'title': 'Hello',
      'body': 'World',
    });

    expect(post.id, 1);
    expect(post.userId, 2);
    expect(post.title, 'Hello');
    expect(post.body, 'World');
  });

  test('2. Преобразование Post обратно в JSON', () {
    const post = Post(userId: 3, title: 'Title', body: 'Body');

    final json = post.toJson();

    expect(json, {'userId': 3, 'title': 'Title', 'body': 'Body'});
    expect(json.containsKey('id'), isFalse); // null-поля не отправляем
    expect(json.containsKey('isLocal'), isFalse);
  });

  test('Отсутствующие поля не роняют приложение', () {
    final post = Post.fromJson({'id': 5});

    expect(post.title, '');
    expect(post.body, '');
    expect(post.userId, 0);
  });

  test('User с вложенными Address и Company', () {
    final user = User.fromJson({
      'id': 1,
      'name': 'Leanne',
      'username': 'Bret',
      'email': 'a@b.c',
      'address': {'city': 'Gwenborough'},
      'company': {'name': 'Romaguera'},
    });

    expect(user.address?.city, 'Gwenborough');
    expect(user.company?.name, 'Romaguera');
    expect(user.toJson()['address'], isA<Map<String, dynamic>>());
  });
}
