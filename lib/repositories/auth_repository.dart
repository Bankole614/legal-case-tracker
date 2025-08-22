// lib/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../providers/core_providers.dart';

class AuthRepository {
  final Dio dio;
  final HiSendConfig cfg;

  AuthRepository({required this.dio, required this.cfg});

  String _base(String path) => 'projects/${cfg.projectId}/auth/$path';

  /// LOGIN
  Future<String?> login({required String email, required String password}) async {
    final formData = FormData.fromMap({
      'email': email,
      'password': password,
    });

    final resp = await dio.post(
      _base('login'),
      data: formData,
    );

    final raw = resp.data;
    return _extractToken(raw);
  }

  /// SIGN UP
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? passwordConfirmation,
  }) async {
    final formData = FormData.fromMap({
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password_confirmation': passwordConfirmation ?? password,
    });

    final resp = await dio.post(_base('sign-up'), data: formData);
    final raw = resp.data;
    return _extractToken(raw);
  }

  /// LOGOUT
  Future<void> logout(String token) async {
    await dio.post(
      _base('logout'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// GET CURRENT USER (raw)
  Future<Map<String, dynamic>> getUserRaw(String token) async {
    final resp = await dio.get(
      _base('user'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return _normalizeResponse(resp.data);
  }

  /// UPDATE USER (profile)
  Future<Map<String, dynamic>> updateUser({required String token, required Map<String, dynamic> payload}) async {
    final formData = FormData.fromMap(payload);

    final resp = await dio.put(
      _base('user'),
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return _normalizeResponse(resp.data);
  }

  /// REQUEST PASSWORD RESET
  Future<void> requestPasswordReset({required String email}) async {
    await dio.post(
      _base('reset-password-request'),
      data: FormData.fromMap({'email': email}),
    );
  }

  /// RESET PASSWORD
  Future<void> resetPassword({required String code, required String newPassword}) async {
    await dio.post(
      _base('reset-password'),
      data: FormData.fromMap({'code': code, 'password': newPassword}),
    );
  }

  // ----------------- Helpers -----------------

  String? _extractToken(dynamic resp) {
    if (resp == null) return null;
    if (resp is Map<String, dynamic>) {
      if (resp.containsKey('token')) return resp['token'] as String?;
      if (resp.containsKey('access_token')) return resp['access_token'] as String?;
      final data = resp['data'];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('token')) return data['token'];
        if (data.containsKey('access_token')) return data['access_token'];
        if (data.containsKey('session') && data['session'] is Map) {
          return (data['session'] as Map)['token'] as String?;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _normalizeResponse(dynamic respData) {
    if (respData is Map<String, dynamic>) {
      if (respData.containsKey('data') && respData['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(respData['data'] as Map);
      }
      return Map<String, dynamic>.from(respData);
    }
    return <String, dynamic>{};
  }
}