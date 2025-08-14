import 'package:dio/dio.dart';
import '../providers/core_providers.dart';

class AuthRepository {
  final Dio dio;
  final HiSendConfig cfg;
  AuthRepository({required this.dio, required this.cfg});

  String _base(String path) => 'projects/${cfg.projectId}/auth/$path';

  Future<String?> login({required String email, required String password}) async {
    final resp = await dio.post(_base('login'), data: {'email': email, 'password': password}, queryParameters: {'api_key': cfg.apiKey});
    final data = resp.data;
    if (data is Map && (data['token'] != null || data['access_token'] != null)) {
      return data['token'] ?? data['access_token'];
    }
    if (data is Map && data['data'] is Map) {
      return data['data']['token'] ?? data['data']['access_token'];
    }
    return null;
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? passwordConfirmation,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
    };
    final resp = await dio.post(_base('sign-up'), data: body, queryParameters: {'api_key': cfg.apiKey});
    final data = resp.data;
    if (data is Map && data['token'] != null) return data['token'];
    if (data is Map && data['data'] is Map) return data['data']['token'];
    return null;
  }

  Future<void> logout(String token) async {
    await dio.post(_base('logout'), options: Options(headers: {'Authorization': 'Bearer $token'}), queryParameters: {'api_key': cfg.apiKey});
  }

  Future<Map<String, dynamic>> getUserRaw(String token) async {
    final resp = await dio.get(_base('user'), options: Options(headers: {'Authorization': 'Bearer $token'}), queryParameters: {'api_key': cfg.apiKey});
    final data = resp.data;
    if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data']);
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
