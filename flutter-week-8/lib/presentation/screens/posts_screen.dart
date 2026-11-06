import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/posts_provider.dart';
import '../widgets/post_tile.dart';
import '../widgets/state_views.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        context.read<PostsProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Post Explorer')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilters(provider),
          if (provider.status == PostsStatus.cached) _buildCachedBanner(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildFilters(PostsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Поиск по заголовку',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: provider.setSearchQuery,
          ),
          const SizedBox(height: 4),
          Text(
            'Поиск идёт среди загруженных постов (${provider.loadedCount})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: provider.selectedUserId,
                  hint: const Text('Все авторы'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Все авторы')),
                    ...provider.users.map((u) =>
                        DropdownMenuItem(value: u.id, child: Text(u.name))),
                  ],
                  onChanged: provider.users.isEmpty ? null : provider.selectUser,
                ),
              ),
              IconButton(
                tooltip: 'Сортировка по ID',
                icon: Icon(provider.sortDescending
                    ? Icons.arrow_downward
                    : Icons.arrow_upward),
                onPressed: provider.toggleSort,
              ),
              TextButton(
                onPressed: provider.hasActiveFilters
                    ? () {
                        _searchController.clear();
                        provider.resetFilters();
                      }
                    : null,
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCachedBanner(PostsProvider provider) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.all(8),
      child: Text(
        provider.errorMessage == null
            ? 'Показаны сохранённые данные. Обновление...'
            : 'Показаны сохранённые данные. ${provider.errorMessage}',
      ),
    );
  }

  Widget _buildBody(PostsProvider provider) {
    switch (provider.status) {
      case PostsStatus.loading:
        return const LoadingView();
      case PostsStatus.error:
        return ErrorView(
          message: provider.errorMessage ?? 'Ошибка',
          onRetry: provider.loadInitial,
        );
      case PostsStatus.success:
      case PostsStatus.cached:
        final posts = provider.visiblePosts;
        return RefreshIndicator(
          onRefresh: provider.loadInitial,
          child: posts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    EmptyView(
                      message: provider.searchQuery.isNotEmpty
                          ? 'Поиск не дал результатов'
                          : 'Постов нет',
                    ),
                  ],
                )
              : ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == posts.length) return _buildFooter(provider);
                    final post = posts[index];
                    return PostTile(
                      post: post,
                      author: provider.authorName(post.userId),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailsScreen(post: post),
                        ),
                      ),
                    );
                  },
                ),
        );
    }
  }

  Widget _buildFooter(PostsProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(provider.loadMoreError!),
            TextButton(
              onPressed: provider.loadMore,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    if (!provider.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Больше постов нет')),
      );
    }
    return const SizedBox(height: 80);
  }
}
