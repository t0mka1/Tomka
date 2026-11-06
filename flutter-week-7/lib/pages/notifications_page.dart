import 'package:flutter/material.dart';
import '../core/session.dart';
import '../models/app_notification.dart';
import '../services/database_service.dart';

/// История уведомлений из Realtime Database (обновляется в реальном времени).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Очистить',
            onPressed: () => DatabaseService.clearNotifications(Session.uid),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: DatabaseService.watchNotifications(Session.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Уведомлений пока нет'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: Text(n.title),
                  subtitle: Text('${n.body}\n${_formatDate(n.createdAt)}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
