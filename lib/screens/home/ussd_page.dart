// lib/screens/ussd/ussd_dialer_screen.dart
import 'package:flutter/material.dart';
import '../../shared/constants/colors.dart';

class USSDDialerScreen extends StatefulWidget {
  const USSDDialerScreen({super.key});

  @override
  _USSDDialerScreenState createState() => _USSDDialerScreenState();
}

class _USSDDialerScreenState extends State<USSDDialerScreen> {
  String _input = '';
  String _output = '';

  final Map<String, Map<String, dynamic>> _ussdMenu = {
    '*': {
      'text': 'Legal Services\n1. Case Status\n2. Find Lawyer\n3. Emergency',
      'options': {'1': '*1#', '2': '*2#', '3': '*3#'}
    },
    '*1#': {
      'text': 'Enter Case ID:',
      'action': (input) => 'Case \$input:\nStatus: Pending\nNext Hearing: 15-Jul-2024',
    },
    '*2#': {
      'text': 'Find Lawyer:\n1. By Specialty\n2. By Location',
      'options': {'1': '*2*1#', '2': '*2*2#'}
    },
    '*3#': {
      'text': 'Emergency:\n1. Police\n2. Lawyer Hotline',
      'options': {'1': '*3*1#', '2': '*3*2#'}
    },
    '*3*1#': {'text': 'Calling Police...\n\n(Simulated)'},
    '*4#': {
      'text': 'Court Services\n1. Filing\n2. Schedule',
      'options': {'1': '*4*1#', '2': '*4*2#'}
    },
    '*4*1#': {'text': 'File documents at:\nMain Court, Room 101'},
  };

  void _onKeyPressed(String key) {
    setState(() {
      _input += key;
      _processInput();
    });
  }

  void _processInput() {
    if (_input.endsWith('#')) {
      final fullCode = _input;
      if (_ussdMenu.containsKey(fullCode)) {
        final menu = _ussdMenu[fullCode]!;
        _output = menu.containsKey('action')
            ? menu['action'](_input.replaceAll(RegExp(r'[^0-9]'), ''))
            : menu['text'];
      } else {
        _output = 'Invalid USSD code\n\n0. Back';
      }
    } else {
      _output = 'Dialing: $_input';
    }
  }

  void _clearInput() {
    setState(() {
      _input = '';
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('USSD Simulator', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _output.isEmpty ? 'Dial * for menu' : _output,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.primary.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _input.isEmpty ? 'Enter USSD code' : _input,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          _buildDialPad(),
        ],
      ),
    );
  }

  Widget _buildDialPad() {
    final keys = ['1','2','3','4','5','6','7','8','9','*','0','#'];
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _onKeyPressed(key),
            child: Text(key, style: const TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }
}
