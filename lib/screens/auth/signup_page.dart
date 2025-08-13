// lib/pages/auth/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/constants/colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStoreProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        passwordConfirmation: _confirmController.text,
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
                  icon: Icons.person_add,
                  title: 'Create Account',
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AuthTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person,
                              validator: (v) => v?.isNotEmpty ?? false
                                  ? null
                                  : 'Please enter first name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AuthTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person,
                              validator: (v) => v?.isNotEmpty ?? false
                                  ? null
                                  : 'Please enter last name',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Enter a valid email',
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.length >= 8 ?? false
                            ? null
                            : 'Enter a valid phone number',
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter password';
                          if (v.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm password';
                          if (_passwordController.text != v) return 'Passwords don\'t match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      GradientButton(
                        text: 'SIGN UP',
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
                  promptText: "Already have an account?",
                  actionText: 'Login',
                  onAction: () => Navigator.pushReplacementNamed(
                    context,
                    LoginPage.routeName,
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