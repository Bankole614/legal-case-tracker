import 'package:case_tracker/screens/onboarding/role_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../stores/auth_store.dart';
import '../home/home_page.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authStoreProvider.notifier).login(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      final error = ref.read(authStoreProvider).error ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStoreProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Invalid email'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars'
              ),
              const SizedBox(height: 20),
              GradientButton(
                  text: 'Login',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading
              ),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleSelectionPage())),
                  child: const Text("Don't have account? Sign up")
              )
            ],
          ),
        ),
      ),
    );
  }
}