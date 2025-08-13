import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/constants/colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStoreProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const AuthHeader(
                  icon: Icons.account_circle,
                  title: 'Login to continue',
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Enter a valid email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: 'LOGIN',
                        onPressed: authState.isLoading ? null : _submit,
                        isLoading: authState.isLoading,
                        gradientColors: [AppColors.primary, AppColors.accent],
                        height: 50,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AuthFooter(
                  promptText: "Don't have an account?",
                  actionText: 'Sign Up',
                  onAction: () => Navigator.pushReplacementNamed(
                    context,
                    SignupPage.routeName,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}