import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GPTService {
  late Interpreter _interpreter;
  bool _isReady = false;
  late Map<String, int> _vocab;
  late Map<int, String> _invVocab;
  final int _maxLen = 64;

  bool get isReady => _isReady;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print('✅ Model loaded');
      _isReady = true;
    } catch (e) {
      print('❌ Failed to load model: $e');
      _isReady = false;
      return;
    }

    try {
      final tokenizerJson = await rootBundle.loadString('assets/tokenizer.json');
      final tokenizer = json.decode(tokenizerJson);

      _vocab = {};
      _invVocab = {};
      tokenizer['model']['vocab'].forEach((token, id) {
        _vocab[token] = id;
        _invVocab[id] = token;
      });
      print('✅ Tokenizer loaded. Vocab size: ${_vocab.length}');
    } catch (e) {
      print('⚠️ Tokenizer failed. Using basic char tokenizer: $e');
      _vocab = {};
      _invVocab = {};
    }
  }

  List<int> tokenize(String prompt) {
    if (_vocab.isEmpty) {
      return prompt.codeUnits.take(_maxLen).toList();
    }

    final words = prompt.split(' ');
    List<int> tokenIds = [];
    for (final word in words) {
      tokenIds.add(_vocab[word] ?? _vocab['<unk>'] ?? 0);
      if (tokenIds.length >= _maxLen) break;
    }
    return tokenIds;
  }

  String detokenize(List<int> tokenIds) {
    if (_invVocab.isEmpty) {
      return String.fromCharCodes(tokenIds.where((e) => e != 0));
    }
    return tokenIds.map((id) => _invVocab[id] ?? '').join(' ').trim();
  }

  Future<String> generate(String prompt) async {
    if (!_isReady) return 'Model not loaded.';

    final inputIds = tokenize(prompt);
    final input = List.generate(1, (_) => List.filled(_maxLen, 0));
    for (int i = 0; i < inputIds.length; i++) {
      input[0][i] = inputIds[i];
    }

    final output = List.generate(1, (_) => List.filled(_maxLen, 0)).cast<List<int>>();

    try {
      _interpreter.run(input, output);
    } catch (e, stack) {
      print('❌ Inference error: $e\n$stack');
      return 'Error generating response: $e';
    }

    return detokenize(output[0]);
  }
}
