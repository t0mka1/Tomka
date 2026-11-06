# Задания по Flutter

| Папка | Задание |
| --- | --- |
| `layout_app` | Компоновка: лейбл, две кнопки-ссылки, котик в 42 пикселях от низа |
| `event_auth_app` | Форма регистрации на хакатон и авторизация через Firebase |

## Компоновка

```
cd layout_app
flutter run -d chrome
```

Ссылка на репозиторий задана в начале `lib/main.dart`.

## Форма регистрации и авторизация

### Настройка Firebase

1. В [консоли Firebase](https://console.firebase.google.com) создай проект.
2. Открой Authentication → Sign-in method и включи Email/Password.
3. В Project settings → Your apps добавь веб-приложение. Для Android добавь ещё
   одно с пакетом `ru.smolgu.tasks.event_auth_app`.
4. Скопируй `apiKey`, `appId`, `messagingSenderId`, `projectId` и `authDomain`
   в `event_auth_app/lib/firebase_options.dart`.

### Запуск

```
cd event_auth_app
flutter run -d chrome
```

### Запуск без проекта Firebase, на локальном эмуляторе

Нужны Node.js и Java. В `event_auth_app` создай `firebase.json`:

```json
{"emulators": {"auth": {"port": 9099}, "ui": {"enabled": false}}}
```

Затем запусти в двух терминалах:

```
npx firebase-tools emulators:start --only auth --project demo-smolgu
flutter run -d chrome --dart-define=USE_AUTH_EMULATOR=true
```

## Как устроено приложение

- Экран авторизации: вход по почте и паролю, ссылка на регистрацию.
- Форма: 11 вопросов и 8 разных виджетов. Кнопка «Отправить» создаёт аккаунт
  в Firebase и показывает введённые данные в окошке, пароль в нём скрыт.
- После регистрации или входа открывается главный экран с кнопкой выхода.

## Тесты

```
cd layout_app && flutter test
cd event_auth_app && flutter test
```

## Лицензия картинки

Фото котика: [Kittyply edit1](https://commons.wikimedia.org/wiki/File:Kittyply_edit1.jpg),
автор David Corby, правка Arad, лицензия
[CC BY 2.5](https://creativecommons.org/licenses/by/2.5/).
