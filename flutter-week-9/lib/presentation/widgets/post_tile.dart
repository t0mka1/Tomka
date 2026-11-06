import 'package:flutter/material.dart';

import '../../data/models/post.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    required this.author,
    required this.onTap,
  });

  final Post post;
  final String author;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text('${post.id ?? '-'}')),
        title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(author),
        trailing: post.isLocal
            ? const Chip(
                label: Text('создан локально'),
                visualDensity: VisualDensity.compact,
              )
            : null,
      ),
    );
  }
}
