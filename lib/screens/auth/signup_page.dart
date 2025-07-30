import 'package:flutter/material.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';

class SignupPage extends StatelessWidget {
  static const routeName = '/signup';
  final _formKey = GlobalKey<FormState>();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? fullName;
    String? email;
    String? passwordValue;
    String? phone;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (v) => fullName = v,
                        validator: (v) => v != null && v.isNotEmpty
                            ? null
                            : 'Please enter your name',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (v) => email = v,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Enter a valid email',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => phone = v,
                        validator: (v) => v != null && v.length >= 8
                            ? null
                            : 'Enter a valid phone number',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                        onChanged: (value) => passwordValue = value,
                        onSaved: (v) => passwordValue = v,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter a password';
                          if (v.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          if (passwordValue != v) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Use GradientButton for signup
                GradientButton(
                  text: 'SIGN UP',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pushReplacementNamed(context, HomePage.routeName);
                    }
                  },
                  gradientColors: [AppColors.primary, AppColors.accent],
                  height: 50,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        LoginPage.routeName,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}