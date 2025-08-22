// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/colors.dart';
import '../../providers/role_provider.dart'; // <- the role provider you created earlier
import 'case_list_page.dart';
import 'chat_page.dart';
import 'documents_page.dart';
import 'profile_page.dart';

/// If you already have a proper lawyer dashboard widget, replace this import
/// with it. This small placeholder prevents compile errors until you add your
/// real dashboard.
class _LawyerDashboardPlaceholder extends StatelessWidget {
  const _LawyerDashboardPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Dashboard')),
      body: const Center(child: Text('Lawyer dashboard (placeholder)')),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // watch role; default to client if null
    final role = ref.watch(roleProvider) ?? AppRole.client;

    // Build role-specific tabs and bottom navigation items
    final bool isLawyer = role == AppRole.lawyer;

    final tabs = <Widget>[
      if (isLawyer) const _LawyerDashboardPlaceholder(),
      // For CaseListPage you can add a constructor param to filter (e.g. showAssignedOnly)
      // Example if you implement it: CaseListPage(showAssignedOnly: !isLawyer)
      const CaseListPage(),
      const ChatPage(),
      const DocumentsPage(),
      const ProfilePage(),
    ];

    final items = <BottomNavigationBarItem>[
      if (isLawyer) const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Cases'),
      const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      const BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file), label: 'Docs'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    // If the role switched and the index is out of range, clamp it on the next frame.
    if (_currentIndex >= tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = tabs.length - 1);
      });
    }

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          items: items,
        ),
      ),
      // Example role-aware FAB: lawyers create cases from dashboard; clients can create intake
      floatingActionButton: isLawyer
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/create-case'),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
