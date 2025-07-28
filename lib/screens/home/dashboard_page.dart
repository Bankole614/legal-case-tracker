// [1] dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart'; // Assuming this is correct

class DashboardPage extends ConsumerWidget {
  final void Function(int) onNavigateToTab; // Callback to change tab in HomePage

  const DashboardPage({
    super.key,
    required this.onNavigateToTab, // Receive the callback
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: navigate to settings (e.g., change language or role)
            },
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${role == 'lawyer' ? 'Lawyer' : 'Client'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Language: ${language?.toUpperCase() ?? 'N/A'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    icon: Icons.mic,
                    label: 'Voice Help',
                    // Directly use the passed-in callback
                    onTap: () => onNavigateToTab(1), // Assuming Chat/Voice Help is tab index 1
                  ),
                  _FeatureCard(
                    icon: Icons.smartphone,
                    label: 'USSD Help',
                    // Directly use the passed-in callback
                    onTap: () => onNavigateToTab(2), // Assuming USSD Help is tab index 2
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

// _FeatureCard remains the same, its onTap is VoidCallback
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
