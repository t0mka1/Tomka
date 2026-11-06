import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/session.dart';
import '../services/notification_service.dart';
import 'registration_page.dart';

/// Профиль: данные регистрации и FCM-токен устройства.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Session.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegistrationPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.user.value;
    final token = NotificationService.token ?? 'Токен не получен';

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Имя'),
                  subtitle: Text(user?.name ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? ''),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Телефон'),
                  subtitle: Text(user?.phone ?? ''),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.key),
              title: const Text('FCM-токен'),
              subtitle: SelectableText(token),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Скопировать',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Токен скопирован')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
