import 'package:flutter/material.dart';

class GesturePage extends StatefulWidget {
  const GesturePage({super.key});

  @override
  State<GesturePage> createState() => _GesturePageState();
}

class _GesturePageState extends State<GesturePage> {
  bool isRed = false;
  List<String> items = ['Яблоко', 'Банан', 'Груша', 'Апельсин'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Жесты')),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Нажатие на квадрат
          GestureDetector(
            onTap: () => setState(() => isRed = !isRed),
            child: Container(
              width: 120,
              height: 120,
              color: isRed ? Colors.red : Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                'Нажми',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Смахни строку в сторону:'),

          // Список, строки можно смахнуть
          Expanded(
            child: ListView(
              children: [
                for (final item in items)
                  Dismissible(
                    key: Key(item),
                    onDismissed: (direction) {
                      setState(() => items.remove(item));
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(title: Text(item)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}