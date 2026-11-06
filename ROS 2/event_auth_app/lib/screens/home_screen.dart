import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.email, required this.signOut});

  final String email;
  final Future<void> Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Главный экран приложения'),
            const SizedBox(height: 8),
            Text(email),
            const SizedBox(height: 24),
            TextButton(onPressed: signOut, child: const Text('Выйти')),
          ],
        ),
      ),
    );
  }
}
