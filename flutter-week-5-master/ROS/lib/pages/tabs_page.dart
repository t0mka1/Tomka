import 'package:flutter/material.dart';

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Вкладки'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Дом'),
              Tab(icon: Icon(Icons.favorite), text: 'Избранное'),
              Tab(icon: Icon(Icons.person), text: 'Профиль'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Icon(Icons.home, size: 100)),
            Center(child: FlutterLogo(size: 100)),
            Center(child: Text('Это профиль', style: TextStyle(fontSize: 24))),
          ],
        ),
      ),
    );
  }
}