import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../stores/auth_store.dart';
import '../home/home_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignupPage({super.key});
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _email = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref.read(authStoreProvider.notifier).signUp(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phone: _phone.text.trim(),
    );
    setState(() => _loading = false);
    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      final err = ref.read(authStoreProvider).error ?? 'Sign up failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Sign Up')), body: Padding(padding: const EdgeInsets.all(16.0), child: Form(key: _formKey, child: ListView(children: [
      AuthTextField(controller: _first, label: 'First name', icon: Icons.person, validator: (v) => v != null && v.isNotEmpty ? null : 'Required'),
      const SizedBox(height: 8),
      AuthTextField(controller: _last, label: 'Last name', icon: Icons.person_outline),
      const SizedBox(height: 8),
      AuthTextField(controller: _email, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (v) => v != null && v.contains('@') ? null : 'Invalid'),
      const SizedBox(height: 8),
      AuthTextField(controller: _phone, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone),
      const SizedBox(height: 8),
      AuthTextField(controller: _password, label: 'Password', icon: Icons.lock, obscureText: true, validator: (v) => v != null && v.length >= 8 ? null : 'Min 8'),
      const SizedBox(height: 16),
      GradientButton(text: 'Sign up', onPressed: _loading ? null : _submit, isLoading: _loading),
    ]))));
  }
}
