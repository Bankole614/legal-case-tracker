import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      'options': {
        '1': '*1#',
        '2': '*2#',
        '3': '*3#',
      }
    },
    '*1#': {
      'text': 'Enter Case ID:',
      'action': (input) => 'Case $input:\nStatus: Pending\nNext Hearing: 15-Jul-2024',
    },
    '*2#': {
      'text': 'Find Lawyer:\n1. By Specialty\n2. By Location',
      'options': {
        '1': '*2*1#',
        '2': '*2*2#',
      }
    },
    '*3#': {
      'text': 'Emergency:\n1. Police\n2. Lawyer Hotline',
      'options': {
        '1': '*3*1#',
        '2': '*3*2#',
      }
    },
    '*3*1#': {
      'text': 'Calling Police...\n\n(Simulated)',
    },
    '*4#': {
      'text': 'Court Services\n1. Filing\n2. Schedule',
      'options': {
        '1': '*4*1#',
        '2': '*4*2#',
      }
    },
    '*4*1#': {
      'text': 'File documents at:\nMain Court, Room 101',
    },
  };

  void _onKeyPressed(String key) {
    setState(() {
      _input += key;
      _processInput();
    });
  }

  void _processInput() {
    final currentCode = _input.split('*').last.split('#').first;
    final fullCode = '*$currentCode#';

    if (_input.endsWith('#')) {
      if (_ussdMenu.containsKey(fullCode)) {
        final menu = _ussdMenu[fullCode]!;
        _output = menu['text'];

        if (menu.containsKey('action')) {
          _output = menu['action'](_input.split('*').last.split('#')[1]);
        }
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('USSD Dialer'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _output.isEmpty ? 'Dial * for menu' : _output,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Text(
              _input.isEmpty ? 'Enter USSD code' : _input,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDialPad(),
        ],
      ),
    );
  }

  Widget _buildDialPad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: [
        _DialButton('1', onPressed: _onKeyPressed),
        _DialButton('2', onPressed: _onKeyPressed),
        _DialButton('3', onPressed: _onKeyPressed),
        _DialButton('4', onPressed: _onKeyPressed),
        _DialButton('5', onPressed: _onKeyPressed),
        _DialButton('6', onPressed: _onKeyPressed),
        _DialButton('7', onPressed: _onKeyPressed),
        _DialButton('8', onPressed: _onKeyPressed),
        _DialButton('9', onPressed: _onKeyPressed),
        _DialButton('*', onPressed: _onKeyPressed),
        _DialButton('0', onPressed: _onKeyPressed),
        _DialButton('#', onPressed: _onKeyPressed),
      ],
    );
  }
}

class _DialButton extends StatelessWidget {
  final String number;
  final Function(String) onPressed;

  const _DialButton(this.number, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed(number);
      },
      child: Text(
        number,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}