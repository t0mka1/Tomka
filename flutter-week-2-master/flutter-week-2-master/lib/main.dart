import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFirstImage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SRSP 2')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Container( //  кошак
              width: 300,
              height: 200,
              color: Colors.grey,
              margin: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/image1.jpeg',
                fit: BoxFit.cover,
              ),
            ),

            
            SizedBox( // собака
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _showFirstImage ? 'assets/image1.jpeg' : 'assets/image2.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.4)),
                  const Center(
                    child: Text(
                      'Welcome to Flutter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            
            SizedBox( // кнопка снакбар
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a SnackBar!')),
                  );
                },
                child: const Text('Show SnackBar'),
              ),
            ),
            const SizedBox(height: 12),


            SizedBox( // кнопка текст
              width: 200,
              height: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.green,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondScreen()),
                  );
                },
                child: const Text('Go to Second Screen'),
              ),
            ),
            const SizedBox(height: 12),

             
            SizedBox( // кнопка тогл
              width: 200,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 16),
                  side: const BorderSide(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    _showFirstImage = !_showFirstImage;
                  });
                },
                child: const Text('Toggle Image'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
      ),
    );
  }
}