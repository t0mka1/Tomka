import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Если репозиторий будет называться иначе, поменяй ссылку здесь.
final Uri gitUrl = Uri.parse('https://github.com/t0mka1/Tomka/tree/main/ROS%202');
final Uri smolguUrl = Uri.parse('https://smolgu.ru');

const String initialText = 'Это моё приложение на Flutter!';
const String catText = 'Это котик';
const double catBottomOffset = 42;
const double catAspectRatio = 3 / 2;

void main() {
  runApp(const LayoutApp());
}

class LayoutApp extends StatelessWidget {
  const LayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Компоновка',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

Future<void> _openInBrowser(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Не удалось открыть $url');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.openUrl = _openInBrowser});

  /// Открывает ссылку. В тестах подменяется, чтобы не запускать браузер.
  final Future<void> Function(Uri url) openUrl;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCatText = false;

  void _toggleText() {
    setState(() => _showCatText = !_showCatText);
  }

  Future<void> _open(Uri url) async {
    try {
      await widget.openUrl(url);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось открыть $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottom: false — иначе системный отступ прибавится к 42 пикселям.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(_showCatText ? catText : initialText),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => _open(gitUrl),
                child: const Text('перейти на гит'),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () => _open(smolguUrl),
                  child: const Text('перейти на сайт СмолГУ!'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, catBottomOffset),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  // AspectRatio подгоняет рамку под картинку, поэтому нижний
                  // край фото всегда совпадает с отступом в 42 пикселя.
                  child: AspectRatio(
                    aspectRatio: catAspectRatio,
                    child: GestureDetector(
                      key: const Key('cat'),
                      onTap: _toggleText,
                      child: Image.asset(
                        'assets/kitten.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
