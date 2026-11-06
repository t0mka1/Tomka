import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/app_exception.dart';
import '../../core/validation/post_validators.dart';
import '../state/posts_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int? _userId;

  /// Отдельное состояние отправки формы (не общий isLoading).
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // блокируем повторное нажатие
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<PostsProvider>();
    try {
      final created = await provider.createPost(
        userId: _userId!,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Пост создан'),
          content: SingleChildScrollView(
            child: Text(
              'Ответ сервера:\n'
              '${const JsonEncoder.withIndent('  ').convert(created.toJson())}\n\n'
              'Пост добавлен в список с пометкой «создан локально»: '
              'JSONPlaceholder не сохраняет его на сервере.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<PostsProvider>().users;

    return Scaffold(
      appBar: AppBar(title: const Text('Новый пост')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              validator: PostValidators.title,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Текст',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: PostValidators.body,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _userId,
              decoration: const InputDecoration(
                labelText: 'Автор',
                border: OutlineInputBorder(),
              ),
              items: users.isNotEmpty
                  ? users
                      .map((u) =>
                          DropdownMenuItem(value: u.id, child: Text(u.name)))
                      .toList()
                  : List.generate(
                      10,
                      (i) => DropdownMenuItem(
                          value: i + 1, child: Text('Автор #${i + 1}'))),
              onChanged: (v) => setState(() => _userId = v),
              validator: PostValidators.author,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
