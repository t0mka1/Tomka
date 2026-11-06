import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

/// Текущий пользователь устройства.
/// [uid] создаётся один раз при первом запуске и используется как ключ
/// в Realtime Database: users/{uid}, notifications/{uid}.
class Session {
  static const _uidKey = 'uid';
  static const _userKey = 'user';

  static late SharedPreferences _prefs;
  static late String uid;

  static final ValueNotifier<UserProfile?> user =
      ValueNotifier<UserProfile?>(null);

  static bool get isRegistered => user.value != null;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    var id = _prefs.getString(_uidKey);
    if (id == null) {
      // push().key генерирует уникальный ключ локально, без запроса к серверу.
      id = FirebaseDatabase.instance.ref().push().key!;
      await _prefs.setString(_uidKey, id);
    }
    uid = id;

    final rawUser = _prefs.getString(_userKey);
    if (rawUser != null) {
      user.value = UserProfile.fromMap(jsonDecode(rawUser) as Map);
    }
  }

  /// Для фонового обработчика push (отдельный isolate, init() там не вызывался).
  static Future<String?> readUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  /// Сохраняет пользователя в Realtime Database и на устройстве.
  static Future<void> register(UserProfile profile, {String? fcmToken}) async {
    await DatabaseService.saveUser(uid, profile, fcmToken: fcmToken);
    await _prefs.setString(_userKey, jsonEncode(profile.toMap()));
    user.value = profile;
  }

  static Future<void> logout() async {
    await _prefs.remove(_userKey);
    user.value = null;
  }
}
