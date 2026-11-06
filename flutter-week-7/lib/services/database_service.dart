import 'package:firebase_database/firebase_database.dart';
import '../models/app_notification.dart';
import '../models/user_profile.dart';

/// Работа с Firebase Realtime Database.
///
/// Структура базы:
///   users/{uid}               — данные регистрации
///   notifications/{uid}/{id}  — история уведомлений
class DatabaseService {
  static DatabaseReference get _root => FirebaseDatabase.instance.ref();

  static Future<void> saveUser(
    String uid,
    UserProfile profile, {
    String? fcmToken,
  }) {
    return _root.child('users/$uid').set({
      ...profile.toMap(),
      'fcmToken': fcmToken,
      'registeredAt': ServerValue.timestamp,
    });
  }

  static Future<void> saveNotification(
    String uid, {
    required String title,
    required String body,
  }) {
    return _root.child('notifications/$uid').push().set({
      'title': title,
      'body': body,
      'createdAt': ServerValue.timestamp,
    });
  }

  /// История уведомлений в реальном времени, новые сверху.
  static Stream<List<AppNotification>> watchNotifications(String uid) {
    return _root.child('notifications/$uid').onValue.map((event) {
      return event.snapshot.children
          .where((c) => c.value is Map)
          .map((c) => AppNotification.fromMap(c.key!, c.value as Map))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  static Future<void> clearNotifications(String uid) {
    return _root.child('notifications/$uid').remove();
  }
}
