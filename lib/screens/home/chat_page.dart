import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../services/ai_service.dart';

class ChatPage extends ConsumerStatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;
  final AIService _aiService = AIService();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      final reply = await _aiService.generateResponse(text);
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message(text: 'Error: $e', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Chat Help', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(color: AppColors.accent),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic),
                  color: AppColors.primary,
                  onPressed: () {}, // voice capture integration later
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your query...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}
