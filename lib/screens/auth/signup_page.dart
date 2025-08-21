import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../stores/auth_store.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignupPage({super.key});
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authStoreProvider.notifier).signUp(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
      passwordConfirmation: _confirmPassword.text,
    );

    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      final error = ref.read(authStoreProvider).error ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStoreProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AuthTextField(
                  controller: _firstName,
                  label: 'First Name',
                  icon: Icons.person,
                  validator: (v) => v != null && v.isNotEmpty ? null : 'First name is required'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _lastName,
                  label: 'Last Name',
                  icon: Icons.person,
                  validator: (v) => v != null && v.isNotEmpty ? null : 'Last name is required'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Invalid email'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _phone,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v != null && v.length >= 10 ? null : 'Valid phone number required'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars'
              ),
              const SizedBox(height: 12),
              AuthTextField(
                  controller: _confirmPassword,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v != null && v == _password.text ? null : 'Passwords do not match'
              ),
              const SizedBox(height: 20),
              GradientButton(
                  text: 'Sign Up',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading
              ),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: const Text("Already have an account? Login")
              )
            ],
          ),
        ),
      ),
    );
  }
}