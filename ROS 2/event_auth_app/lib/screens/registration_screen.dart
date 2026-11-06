import 'package:flutter/material.dart';

import '../auth_errors.dart';

const List<String> _languages = ['Dart', 'Python', 'Java', 'Kotlin', 'C++'];

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

/// Форма регистрации на хакатон. Вопросов 11, разных виджетов 8:
/// поле ввода, чекбокс, счётчик, радиокнопки, выпадающий список,
/// ползунок, переключатель и выбор даты.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.register});

  final AuthAction register;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _about = TextEditingController();

  bool _isAdult = false;
  int _cats = 0;
  String? _gender;
  String? _language;
  double _experience = 0;
  bool _needsCertificate = false;
  DateTime? _birthDate;

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Map<String, String> get _answers => {
    'ФИО': _fullName.text.trim(),
    'Почта': _email.text.trim(),
    'Пароль': '•' * _password.text.length,
    'Дата рождения': _formatDate(_birthDate!),
    'Мне исполнилось 14 лет': _isAdult ? 'да' : 'нет',
    'Количество котов': '$_cats',
    'Пол': _gender!,
    'Любимый язык': _language!,
    'Опыт программирования (лет)': '${_experience.round()}',
    'Нужен сертификат': _needsCertificate ? 'да' : 'нет',
    'О себе': _about.text.trim().isEmpty ? '—' : _about.text.trim(),
  };

  String? _missingAnswer() {
    if (_birthDate == null) return 'Укажите дату рождения.';
    if (!_isAdult) return 'Участвовать можно только с 14 лет.';
    if (_gender == null) return 'Укажите пол.';
    return null;
  }

  Future<void> _submit() async {
    final fieldsValid = _formKey.currentState!.validate();
    final missing = _missingAnswer();
    setState(() => _error = missing);
    if (!fieldsValid || missing != null) return;

    setState(() => _busy = true);
    try {
      await widget.register(_email.text.trim(), _password.text);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = authErrorMessage(e);
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вы зарегистрированы'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final MapEntry(:key, :value) in _answers.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('$key: $value'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    final date = _birthDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация на хакатон')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('reg_name'),
              controller: _fullName,
              decoration: const InputDecoration(
                labelText: 'ФИО',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Введите ФИО' : null,
            ),
            gap,
            TextFormField(
              key: const Key('reg_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Почта',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || !value.contains('@')
                  ? 'Введите почту'
                  : null,
            ),
            gap,
            TextFormField(
              key: const Key('reg_password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                helperText: 'Минимум 6 символов',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.length < 6
                  ? 'Минимум 6 символов'
                  : null,
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? 'Дата рождения: не выбрана'
                        : 'Дата рождения: ${_formatDate(date)}',
                  ),
                ),
                OutlinedButton(
                  key: const Key('reg_date'),
                  onPressed: _pickDate,
                  child: const Text('Выбрать'),
                ),
              ],
            ),
            CheckboxListTile(
              key: const Key('reg_adult'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Мне исполнилось 14 лет'),
              value: _isAdult,
              onChanged: (value) => setState(() => _isAdult = value ?? false),
            ),
            Row(
              children: [
                const Expanded(child: Text('Количество котов:')),
                IconButton(
                  tooltip: 'Меньше',
                  icon: const Icon(Icons.remove),
                  onPressed: _cats == 0 ? null : () => setState(() => _cats--),
                ),
                Text('$_cats', key: const Key('reg_cats')),
                IconButton(
                  tooltip: 'Больше',
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _cats++),
                ),
              ],
            ),
            RadioGroup<String>(
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value),
              child: const Row(
                children: [
                  Expanded(child: Text('Пол:')),
                  Radio<String>(key: Key('reg_male'), value: 'М'),
                  Text('М'),
                  Radio<String>(key: Key('reg_female'), value: 'Ж'),
                  Text('Ж'),
                ],
              ),
            ),
            gap,
            DropdownButtonFormField<String>(
              key: const Key('reg_language'),
              initialValue: _language,
              decoration: const InputDecoration(
                labelText: 'Любимый язык программирования',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final language in _languages)
                  DropdownMenuItem(value: language, child: Text(language)),
              ],
              onChanged: (value) => setState(() => _language = value),
              validator: (value) => value == null ? 'Выберите язык' : null,
            ),
            gap,
            Text('Опыт программирования (лет): ${_experience.round()}'),
            Slider(
              key: const Key('reg_experience'),
              value: _experience,
              max: 10,
              divisions: 10,
              label: '${_experience.round()}',
              onChanged: (value) => setState(() => _experience = value),
            ),
            SwitchListTile(
              key: const Key('reg_certificate'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Нужен сертификат участника'),
              value: _needsCertificate,
              onChanged: (value) => setState(() => _needsCertificate = value),
            ),
            gap,
            TextFormField(
              key: const Key('reg_about'),
              controller: _about,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Немного о себе',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              gap,
              Text(
                _error!,
                key: const Key('reg_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            gap,
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
