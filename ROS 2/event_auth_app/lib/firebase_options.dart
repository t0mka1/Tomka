import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Настройки Firebase. Значения берутся из консоли Firebase:
/// Project settings → Your apps. Шаги описаны в README.
///
/// С локальным эмулятором (USE_AUTH_EMULATOR=true) заглушки можно не менять.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.android ? web : android;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPOiAzAOjCU9LqPmCtkzI27q39SsO7IcE',
    appId: '1:796638675673:web:12c233ab5f67ebffd7b4c8',
    messagingSenderId: '796638675673',
    projectId: 'smolgu-hackathon',
    authDomain: 'smolgu-hackathon.firebaseapp.com',
    storageBucket: 'smolgu-hackathon.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-smolgu',
  );
}
