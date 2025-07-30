import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import 'role_selection_page.dart';
import 'language_selection_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to RightNow',
      'description': 'Your companion to know and act on your legal rights quickly.',
      'icon': Icons.shield,
    },
    {
      'title': 'Offline Voice & USSD',
      'description': 'Get guidance via voice in local languages or simulate USSD menus offline.',
      'icon': Icons.phone_android,
    },
  ];

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, RoleSelectionPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page['icon'], size: 150, color: AppColors.primary),
                        const SizedBox(height: 40),
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == i ? AppColors.primary : AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: _currentIndex == _pages.length - 1 ? 'Continue' : 'Next',
                    onPressed: _onNext,
                    gradientColors: [AppColors.primary, AppColors.accent],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
