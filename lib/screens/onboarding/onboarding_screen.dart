import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your actual page files
import '../onboarding/role_selection_page.dart';
import '../onboarding/language_selection_page.dart';
import '../auth/login_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _pageData = [];

  @override
  void initState() {
    super.initState();
    final introData = [
      {
        'title': 'Welcome to RightNow',
        'description': 'Your companion to know and act on your legal rights quickly.',
        'image': Icons.shield,
      },
      {
        'title': 'Voice & USSD Access Offline',
        'description': 'Get guidance via voice in local languages or simulate USSD menus offline.',
        'image': Icons.phone_android,
      }
    ];
    for (var item in introData) {
      _pageData.add(item);
    }
  }

  Widget _buildIntroPage(BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 150, color: Colors.black),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  void _onNext() {
    if (_currentIndex < _pageData.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Navigator.pushReplacementNamed(context, RoleSelectionPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _pageData.length;
    if (totalPages == 0) {
      return const Scaffold(body: Center(child: Text("Loading onboarding...")));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: totalPages, // PageView only for intro slides
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  // Only build intro pages here
                  final dataItem = _pageData[index];
                  return _buildIntroPage(
                    context,
                    dataItem['title'] as String,
                    dataItem['description'] as String,
                    dataItem['image'] as IconData,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalPages, // Dots only for intro slides
                          (dotIndex) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: _currentIndex == dotIndex ? 30 : 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == dotIndex ? Colors.black : Colors.grey[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _onNext,
                      child: Text(
                        _currentIndex == totalPages - 1 ? 'Continue' : 'Next',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
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
