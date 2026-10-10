import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кнопки')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => count++),
                  child: const Text('+1'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => setState(() => count--),
                  child: const Text('-1'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => setState(() => count = 0),
                  child: const Text('Сброс'),
                ),
                IconButton(
                  onPressed: () => setState(() => count += 10),
                  icon: const Icon(Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}