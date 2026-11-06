# Лабораторная работа 7 — Firebase Realtime Database + Push Notifications

## Что умеет приложение
- **Регистрация** (Профиль → Регистрация): имя, email, телефон → `users/{uid}` в Realtime Database,
  затем push-уведомление «Регистрация прошла успешно».
- **Покупки**: в каталоге «В корзину», вкладка «Корзина» (+/−, итог), кнопка «Купить».
  Незарегистрированного пользователя сначала отправляет на регистрацию.
  Заказ сохраняется в `orders/{uid}`, приходит push «Заказ оформлен».
- **Мои заказы** (Профиль или иконка в корзине) — история заказов из базы в реальном времени.
- **Уведомления** (колокольчик на главной или Профиль) — история всех уведомлений из
  `notifications/{uid}`: локальные (регистрация, заказ) и FCM push — и при открытом, и при
  свёрнутом/закрытом приложении. Непрочитанные выделены, есть счётчик, «прочитать все»,
  удаление свайпом, очистка.
- Тема, избранное и корзина сохраняются на устройстве между запусками.

## Структура базы
```
users/{uid}:               name, email, phone, fcmToken, registeredAt
orders/{uid}/{orderId}:    items[{name, price, quantity}], total, status, createdAt
notifications/{uid}/{id}:  title, body, type (registration|order|push), read, createdAt
```
`uid` создаётся при первом запуске приложения и хранится на устройстве.

## Код
| Файл | Назначение |
|---|---|
| `lib/main.dart` | инициализация Firebase, FCM, сессии |
| `lib/core/session.dart` | uid устройства и текущий пользователь |
| `lib/core/app_state.dart` | тема, избранное, корзина |
| `lib/services/database_service.dart` | вся работа с Realtime Database |
| `lib/services/notification_service.dart` | FCM + показ и сохранение уведомлений |
| `lib/pages/registration_page.dart` | экран регистрации |
| `lib/pages/cart_page.dart`, `orders_page.dart`, `notifications_page.dart` | корзина, заказы, уведомления |

## Шаги в Firebase Console
1. Создать проект на https://console.firebase.google.com.
2. **Build → Realtime Database → Create database → Start in test mode.**
   Сделать это ДО скачивания `google-services.json`, иначе в файле не будет адреса базы.
3. Project settings → Add app → Android, package name **`com.example.fluttersrs4`**.
   Скачать `google-services.json` → положить в `android/app/google-services.json`.
4. Cloud Messaging включён по умолчанию (Project settings → Cloud Messaging → API V1 enabled).
5. (iOS) Добавить iOS-приложение, `GoogleService-Info.plist` → `ios/Runner/` через Xcode,
   включить capability Push Notifications и загрузить APNs-ключ в настройках Cloud Messaging.

## Запуск
```
flutter pub get
flutter run
```

## Проверка push из консоли
1. FCM-токен печатается в лог: `FCM token: ...` (и сохраняется в `users/{uid}/fcmToken`).
2. Firebase Console → **Messaging → New campaign → Notifications** → заголовок и текст →
   **Send test message** → вставить токен → **Test**.
3. Уведомление придёт на телефон и появится в истории уведомлений приложения.

## Правила базы
Test mode открывает базу на 30 дней. Для сдачи достаточно; потом можно поставить:
```json
{
  "rules": {
    "users":         { "$uid": { ".read": true, ".write": true } },
    "orders":        { "$uid": { ".read": true, ".write": true } },
    "notifications": { "$uid": { ".read": true, ".write": true } }
  }
}
```
