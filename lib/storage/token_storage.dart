import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.read(secureStorageProvider);
  return TokenStorage(storage: storage);
});

class TokenStorage {
  final FlutterSecureStorage storage;
  const TokenStorage({required this.storage});

  Future<void> writeToken(String token) async => await storage.write(key: 'hisend_token', value: token);
  Future<String?> readToken() async => await storage.read(key: 'hisend_token');
  Future<void> deleteToken() async => await storage.delete(key: 'hisend_token');
}
