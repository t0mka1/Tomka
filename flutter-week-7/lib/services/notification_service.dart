import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/session.dart';
import 'database_service.dart';

/// Push пришёл, когда приложение в фоне или закрыто.
/// Система сама показывает уведомление сверху — здесь только сохраняем его
/// в раздел «Уведомления». Выполняется в отдельном isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  final uid = await Session.readUid();
  if (notification == null || uid == null) return;
  await DatabaseService.saveNotification(
    uid,
    title: notification.title ?? '',
    body: notification.body ?? '',
  );
}

/// Firebase Cloud Messaging + локальные уведомления.
/// Каждое уведомление сохраняется в Realtime Database (notifications/{uid}).
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Важные уведомления',
    description: 'Канал для push-уведомлений приложения',
    importance: Importance.high,
  );

  /// FCM-токен устройства (по нему Firebase отправляет push на это устройство).
  static String? token;

  static Future<void> init() async {
    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Разрешение на показ уведомлений (Android 13+ и iOS).
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      token = await _messaging.getToken();
      debugPrint('FCM token: $token');

      // Приложение открыто: на Android FCM сам уведомление не показывает.
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        show(title: notification.title ?? '', body: notification.body ?? '');
      });
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  /// Показывает уведомление сверху и сохраняет его в раздел «Уведомления».
  static Future<void> show({required String title, required String body}) async {
    // Запись в базу не ждём: Firebase сам отправит её, когда будет сеть.
    DatabaseService.saveNotification(Session.uid, title: title, body: body)
        .catchError((Object e) => debugPrint('saveNotification error: $e'));

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
