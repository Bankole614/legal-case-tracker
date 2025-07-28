import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ussd_service.dart';

class USSDInterface extends ConsumerStatefulWidget {
  const USSDInterface({super.key});

  @override
  ConsumerState<USSDInterface> createState() => _USSDInterfaceState();
}

class _USSDInterfaceState extends ConsumerState<USSDInterface> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ussdProvider.notifier).processInput('');
      _inputFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ussdState = ref.watch(ussdProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Legal USSD'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                ussdState.sessionText,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('>', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocus,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter option...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (input) {
                ref.read(ussdProvider.notifier).processInput(input);
                _inputController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }
}