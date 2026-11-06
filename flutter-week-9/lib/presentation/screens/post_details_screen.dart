import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/comment.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../data/repositories/post_repository.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late Future<Post> _postFuture;
  late Future<User> _authorFuture;
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final repo = context.read<PostRepository>();
    final post = widget.post;
    // Локально созданного поста на сервере нет — показываем то, что есть.
    _postFuture = post.isLocal || post.id == null
        ? Future.value(post)
        : repo.getPost(post.id!);
    _commentsFuture = post.isLocal || post.id == null
        ? Future.value(<Comment>[])
        : repo.getComments(post.id!);
    _authorFuture = repo.getUser(post.userId);
  }

  void _retry() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Пост #${widget.post.id ?? ''}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AsyncSection<Post>(
            future: _postFuture,
            onRetry: _retry,
            builder: (post) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(post.body),
                if (widget.post.isLocal)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Пост создан локально: JSONPlaceholder не сохраняет '
                      'новые посты на сервере.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 32),
          _AsyncSection<User>(
            future: _authorFuture,
            onRetry: _retry,
            builder: (user) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(user.name),
              subtitle: Text('${user.email}\n'
                  '${user.address?.city ?? ''} · ${user.company?.name ?? ''}'),
            ),
          ),
          const Divider(height: 32),
          Text('Комментарии', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _AsyncSection<List<Comment>>(
            future: _commentsFuture,
            onRetry: _retry,
            builder: (comments) => comments.isEmpty
                ? const Text('Комментариев нет')
                : Column(
                    children: comments
                        .map((c) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(c.name),
                              subtitle: Text('${c.email}\n${c.body}'),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Показывает loading / error / данные для одного Future.
class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.future,
    required this.builder,
    required this.onRetry,
  });

  final Future<T> future;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final message = AppException.from(snapshot.error!).message;
          return Row(
            children: [
              Expanded(child: Text(message)),
              TextButton(onPressed: onRetry, child: const Text('Повторить')),
            ],
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
