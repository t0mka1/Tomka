import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: RegistrationPage());
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmFocus = FocusNode();

  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('email', emailController.text);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserInfoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Form'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) => phoneFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              focusNode: phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) => emailFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.call),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your phone number';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Digits only';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              focusNode: emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) => passwordFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your email';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'Wrong email format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              focusNode: passwordFocus,
              obscureText: hidePassword,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) => confirmFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.security),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a password';
                }
                if (value.length < 6) {
                  return 'At least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmController,
              focusNode: confirmFocus,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password *',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Form'),
            ),
          ],
        ),
      ),
    );
  }
}