import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'data/local/post_cache.dart';
import 'data/remote/post_api.dart';
import 'data/repositories/post_repository.dart';
import 'presentation/screens/posts_screen.dart';
import 'presentation/state/posts_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Один Dio на всё приложение -> Retrofit API -> репозиторий.
  final dio = DioClient().dio;
  final repository = PostRepository(PostApi(dio), PostCache(prefs));

  runApp(
    MultiProvider(
      providers: [
        Provider<PostRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => PostsProvider(repository)
            ..loadUsers()
            ..loadInitial(),
        ),
      ],
      child: const PostExplorerApp(),
    ),
  );
}

class PostExplorerApp extends StatelessWidget {
  const PostExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PostsScreen(),
    );
  }
}
