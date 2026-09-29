import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Моё приложение',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      scrollBehavior: const NoStretchScrollBehavior(),
      home: const HomeScreen(),
    );
  }
}

// Material3 растягивает содержимое при овербдрэге (StretchingOverscrollIndicator
// для Android) — именно это выглядело как "растягивание" карточек при скролле.
// Отключаем эффект растяжения, оставляя обычный скролл без индикатора.
class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

//AppBar + TabBar + Drawer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> items = List.generate(10, (i) => 'Товар №${i + 1}');

  void _addItemDialog() {
    String newItem = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новый элемент'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newItem = value,
            decoration: const InputDecoration(hintText: 'Название товара'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (newItem.trim().isNotEmpty) {
                  setState(() => items.add(newItem));
                }
                Navigator.pop(context);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Моё приложение'),
          actions: [
            IconButton(
              icon: const Icon(Icons.campaign),
              tooltip: 'Показать приветствие',
              onPressed: () => Fluttertoast.showToast(msg: 'Hello, Flutter!'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Список', icon: Icon(Icons.list)),
              Tab(text: 'Сетка', icon: Icon(Icons.grid_view)),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.indigo),
                child: Text(
                  'Моё приложение',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Главная'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Профиль'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Настройки'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.style),
                title: const Text('Карточки'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CardsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Выход'),
                onTap: () {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: 'Выход из аккаунта');
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(items[index]),
                  subtitle: const Text('Описание товара'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: 'Вы выбрали элемент №${index + 1}: ${items[index]}',
                    );
                  },
                );
              },
            ),
            const GridTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItemDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}


class GridTab extends StatefulWidget {
  const GridTab({super.key});

  @override
  State<GridTab> createState() => _GridTabState();
}

class _GridTabState extends State<GridTab> {
  final List<Color> colors = List.generate(6, (_) => Colors.blue);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              colors[index] =
                  colors[index] == Colors.blue ? Colors.green : Colors.blue;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Экран "Карточки": минимум 4 Card с картинкой, описанием и кнопкой
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Смартфон',
        'desc': 'Современный смартфон с большим экраном',
        'image': 'assets/images/smartphone.png',
      },
      {
        'title': 'Ноутбук',
        'desc': 'Лёгкий ноутбук для учёбы и работы',
        'image': 'assets/images/laptop.jpg',
      },
      {
        'title': 'Наушники',
        'desc': 'Беспроводные наушники с шумоподавлением',
        'image': 'assets/images/headphones.png',
      },
      {
        'title': 'Часы',
        'desc': 'Умные часы с датчиком пульса',
        'image': 'assets/images/watch.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Карточки')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: products.map((product) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.indigo.shade50,
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      product['image']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(product['desc']!),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  title: product['title']!,
                                  desc: product['desc']!,
                                ),
                              ),
                            );
                          },
                          child: const Text('Подробнее'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Экран подробной информации о товаре
class DetailScreen extends StatelessWidget {
  final String title;
  final String desc;

  const DetailScreen({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(desc, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// Экран "Профиль"
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text('Дидар Аманжолов', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text('zainillindidar@gmail.com'),
          ],
        ),
      ),
    );
  }
}

// Экран "Настройки"
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Уведомления'),
              value: notifications,
              onChanged: (value) {
                setState(() => notifications = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: 'Настройки сохранены');
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
