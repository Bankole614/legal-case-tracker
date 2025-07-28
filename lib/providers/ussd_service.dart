import 'package:flutter_riverpod/flutter_riverpod.dart';

final ussdProvider = StateNotifierProvider<USSDNotifier, USSDState>((ref) {
  return USSDNotifier();
});

class USSDState {
  final String currentMenu;
  final String sessionText;
  final List<String> menuStack;

  USSDState({
    this.currentMenu = 'main',
    this.sessionText = '',
    this.menuStack = const [],
  });

  USSDState copyWith({
    String? currentMenu,
    String? sessionText,
    List<String>? menuStack,
  }) {
    return USSDState(
      currentMenu: currentMenu ?? this.currentMenu,
      sessionText: sessionText ?? this.sessionText,
      menuStack: menuStack ?? this.menuStack,
    );
  }
}

class USSDNotifier extends StateNotifier<USSDState> {
  USSDNotifier() : super(USSDState());

  final Map<String, Map<String, dynamic>> _menuTree = {
    'main': {
      'text': 'Legal Services\n1. Case Status\n2. Find Lawyer\n3. Legal Advice\n4. Emergency',
      'options': {
        '1': 'case_status',
        '2': 'lawyer_menu',
        '3': 'legal_advice',
        '4': 'emergency',
      }
    },
    'case_status': {
      'text': 'Enter Case ID:',
      'action': _handleCaseStatus,
    },
    'lawyer_menu': {
      'text': 'Find Lawyer:\n1. By Specialty\n2. By Location\n3. All Lawyers',
      'options': {
        '1': 'lawyer_specialty',
        '2': 'lawyer_location',
        '3': 'all_lawyers',
      }
    },
    'legal_advice': {
      'text': 'Type your legal question:',
      'action': _handleLegalQuestion,
    },
    'emergency': {
      'text': 'Emergency Contacts:\n1. Police\n2. Hospital\n3. Lawyer Hotline',
      'options': {
        '1': 'call_police',
        '2': 'call_hospital',
        '3': 'call_lawyer',
      }
    },
    'call_police': {
      'text': 'Calling Police...\n\n0. Back',
      'action': () => _simulateCall('911'),
    },
  };

  void processInput(String input) {
    if (input.isEmpty) {
      // Initial USSD launch
      state = state.copyWith(
        currentMenu: 'main',
        sessionText: _buildMenuText('main'),
      );
      return;
    }

    if (input == '0' && state.menuStack.isNotEmpty) {
      // Back button
      final previousMenu = state.menuStack.last;
      final newStack = List<String>.from(state.menuStack)..removeLast();

      state = state.copyWith(
        currentMenu: previousMenu,
        sessionText: _buildMenuText(previousMenu),
        menuStack: newStack,
      );
      return;
    }

    final currentMenuData = _menuTree[state.currentMenu]!;
    final options = currentMenuData['options'];

    if (options != null && options.containsKey(input)) {
      // Menu navigation
      final nextMenu = options[input];

      state = state.copyWith(
        currentMenu: nextMenu,
        sessionText: _buildMenuText(nextMenu),
        menuStack: [...state.menuStack, state.currentMenu],
      );
    } else if (currentMenuData.containsKey('action')) {
      // Action handler
      final action = currentMenuData['action'];
      final result = action is Function ? action(input) : action();

      state = state.copyWith(
        sessionText: result,
      );
    } else {
      // Invalid input
      state = state.copyWith(
        sessionText: 'Invalid option\n\n${_buildMenuText(state.currentMenu)}',
      );
    }
  }

  String _buildMenuText(String menuKey) {
    final menu = _menuTree[menuKey]!;
    final buffer = StringBuffer(menu['text']);

    if (menu.containsKey('options')) {
      menu['options'].forEach((key, value) {
        buffer.write('\n$key. ${_menuTree[value]?['text'].split('\n').first}');
      });
    }

    if (state.menuStack.isNotEmpty) {
      buffer.write('\n\n0. Back');
    }

    return buffer.toString();
  }

  static String _handleCaseStatus(String caseId) {
    // Mock case status lookup
    final mockCases = {
      '123': 'Status: Active\nNext Hearing: 15-Jul-2024',
      '456': 'Status: Pending\nLawyer: James Wilson',
    };

    return mockCases[caseId] ?? 'Case not found\n\n0. Back';
  }

  static String _handleLegalQuestion(String question) {
    // Mock legal advice
    final responses = [
      'Consult a lawyer for this matter',
      'This may require legal documentation',
      'You have 30 days to respond',
      'Check local jurisdiction laws',
    ];

    return 'Legal Advice:\n${responses[question.length % responses.length]}\n\n0. Back';
  }

  static String _simulateCall(String number) {
    return 'Would call: $number\n(App demo only)\n\n0. Back';
  }
}