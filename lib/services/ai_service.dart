import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A service to manage text generation using the Hugging Face Inference API.
class AIService {
  // Replace with your actual HF API token (store securely)
  static const String _hfToken = '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';
  // Replace with the exact model ID from Hugging Face
  static const String _modelId = 'distilgpt2';
  // Correct API URL to include only one occurrence of modelId
  static const String _apiUrl = 'http://api-inference.huggingface.co/models/$_modelId';

  /// Generate a response from the API given user input text.
  /// Wraps the user input in a system prompt for persona.
  Future<String> generateResponse(String userInput) async {
    final prompt = '''
You are RightNow Legal Assistant. Provide clear, step-by-step legal guidance.
User: "$userInput"
Assistant:
''';

    final response = await http.post(
      Uri.parse(_apiUrl), // use the correct single URL
      headers: {
        'Authorization': 'Bearer $_hfToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
        'options': {'use_cache': false},
        'parameters': {'max_new_tokens': 100, 'temperature': 0.2},
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResp = jsonDecode(response.body);
      // The API returns a list of generated sequences
      final String generated = jsonResp[0]['generated_text'] as String;
      return generated.replaceFirst(prompt, '').trim();
    } else {
      debugPrint('HF Inference API error: ${response.statusCode}');
      return 'Sorry, I couldn\'t generate a response right now.';
    }
  }
}
