import 'package:flutter/material.dart';

import 'counter_page.dart';
import 'form_page.dart';
import 'gesture_page.dart';
import 'tabs_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Открыть новый экран
  void open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Показать диалог
  void showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Привет!'),
        content: const Text('Это пример диалога'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Примеры Flutter')),

      // Шторка (меню слева)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Меню')),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Кнопки'),
              onTap: () {
                Navigator.pop(context); // закрыть шторку
                open(context, const CounterPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Поле ввода'),
              onTap: () {
                Navigator.pop(context);
                open(context, const FormPage());
              },
            ),
          ],
        ),
      ),

      // Кнопки на главном экране
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => open(context, const CounterPage()),
              child: const Text('Кнопки и счётчик'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => open(context, const FormPage()),
              child: const Text('Поле ввода'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => open(context, const GesturePage()),
              child: const Text('Жесты'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => open(context, const TabsPage()),
              child: const Text('Вкладки'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => showMyDialog(context),
              child: const Text('Показать диалог'),
            ),
          ],
        ),
      ),
    );
  }
}