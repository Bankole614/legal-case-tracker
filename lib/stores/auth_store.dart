// lib/stores/auth_store.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authStoreProvider =
StateNotifierProvider<AuthStore, AuthState>((ref) => AuthStore(ref));

class AppUser {
  final String id;
  final String? email;
  final String? name;
  final String? phone;
  final bool emailVerified;
  final bool phoneVerified;

  AppUser({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      emailVerified:
      (json['is_email_verified'] ?? json['email_verified'] ?? false) as bool,
      phoneVerified:
      (json['is_phone_verified'] ?? json['phone_verified'] ?? false) as bool,
    );
  }
}

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? error;

  AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

class AuthStore extends StateNotifier<AuthState> {
  final Ref _ref;
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  late final HiSendConfig _cfg;

  AuthStore(this._ref) : super(AuthState()) {
    _dio = _ref.read(dioProvider);
    _secureStorage = _ref.read(secureStorageProvider);
    _cfg = _ref.read(hisendConfigProvider);
    _restoreSession();
  }

  String _authBasePath() => 'projects/${_cfg.projectId}/auth';

  String _endpoint(String path) {
    // path is like 'login' or 'user' or 'sign-up'
    return '${_authBasePath()}/$path?api_key=${_cfg.apiKey}';
  }

  Future<void> _restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _secureStorage.read(key: 'hisend_token');
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _fetchUser(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        error: null,
      );
    } catch (e) {
      await _secureStorage.delete(key: 'hisend_token');
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  /// SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? extraFields,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final url = _endpoint('sign-up');
    try {
      final resp = await _dio.post(url, data: {
        'email': email,
        'password': password,
        if (extraFields != null) ...extraFields,
      });
      final result = resp.data as Map<String, dynamic>;
      final token = _extractToken(result);
      if (token != null) {
        await _saveToken(token);
        final user = await _fetchUser(token);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
          error: null,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _parseError(e));
      rethrow;
    }
  }

  /// LOGIN
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final url = _endpoint('login');
    try {
      final resp = await _dio.post(url, data: {'email': email, 'password': password});
      final result = resp.data as Map<String, dynamic>;
      final token = _extractToken(result);
      if (token == null) {
        state = state.copyWith(
            status: AuthStatus.error, error: 'No token returned. Inspect API response.');
        return;
      }
      await _saveToken(token);
      final user = await _fetchUser(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: _parseError(e));
      rethrow;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final url = _endpoint('logout');
    final token = state.token ?? await _secureStorage.read(key: 'hisend_token');
    try {
      if (token != null) {
        await _dio.post(url, options: Options(headers: {'Authorization': 'Bearer $token'}));
      }
    } catch (_) {
      // ignore server logout errors
    } finally {
      await _secureStorage.delete(key: 'hisend_token');
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// GET CURRENT USER (explicit)
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final token = state.token ?? await _secureStorage.read(key: 'hisend_token');
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _fetchUser(token);
      state = state.copyWith(status: AuthStatus.authenticated, user: user, token: token);
    } catch (e) {
      await _secureStorage.delete(key: 'hisend_token');
      state = state.copyWith(status: AuthStatus.unauthenticated, error: _parseError(e));
    }
  }

  /// REQUEST PASSWORD RESET
  Future<void> requestPasswordReset({required String email}) async {
    final url = _endpoint('reset-password-request');
    try {
      await _dio.post(url, data: {'email': email});
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword({required String code, required String newPassword}) async {
    final url = _endpoint('reset-password');
    try {
      await _dio.post(url, data: {'code': code, 'password': newPassword});
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// VERIFY EMAIL
  Future<void> verifyEmail({required String email, required String code}) async {
    final url = _endpoint('verify-email');
    try {
      await _dio.put(url, data: {'email': email, 'code': code});
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// VERIFY PHONE
  Future<void> verifyPhone({required String phone, required String code}) async {
    final url = _endpoint('verify-phone');
    try {
      await _dio.put(url, data: {'phone': phone, 'code': code});
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// ----------------- Helpers -----------------

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'hisend_token', value: token);
  }

  Future<AppUser> _fetchUser(String token) async {
    final url = _endpoint('user');
    final resp =
    await _dio.get(url, options: Options(headers: {'Authorization': 'Bearer $token'}));
    final raw = resp.data;
    final Map<String, dynamic> userJson = _normalizeDataField(raw);
    return AppUser.fromJson(userJson);
  }

  String? _extractToken(Map<String, dynamic> resp) {
    if (resp.containsKey('token')) return resp['token'] as String?;
    if (resp.containsKey('access_token')) return resp['access_token'] as String?;
    if (resp['data'] is Map) {
      final data = resp['data'] as Map<String, dynamic>;
      if (data.containsKey('token')) return data['token'] as String?;
      if (data.containsKey('access_token')) return data['access_token'] as String?;
      if (data.containsKey('session') && data['session'] is Map) {
        final session = data['session'] as Map<String, dynamic>;
        if (session.containsKey('token')) return session['token'] as String?;
      }
    }
    return null;
  }

  Map<String, dynamic> _normalizeDataField(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(raw['data']);
      }
      return raw;
    }
    return <String, dynamic>{};
  }

  String? _parseError(dynamic e) {
    if (e is DioError) {
      if (e.response != null) {
        try {
          final data = e.response!.data;
          if (data is Map && (data['message'] != null || data['error'] != null)) {
            return (data['message'] ?? data['error']).toString();
          }
          return e.response!.statusMessage ?? e.message;
        } catch (_) {
          return e.message;
        }
      }
      return e.message;
    }
    return e.toString();
  }
}
