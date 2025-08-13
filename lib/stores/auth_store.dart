// lib/stores/auth_store.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/core_providers.dart';

final authStoreProvider = StateNotifierProvider<AuthStore, AuthState>((ref) => AuthStore(ref));

// ================== Data Models ==================
class AppUser {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool emailVerified;
  final bool phoneVerified;

  AppUser({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      emailVerified: (json['is_email_verified'] ?? json['email_verified'] ?? false) as bool,
      phoneVerified: (json['is_phone_verified'] ?? json['phone_verified'] ?? false) as bool,
    );
  }

  bool get isVerified => emailVerified && phoneVerified;
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsVerification,
  error
}

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? error;
  final StackTrace? stackTrace;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error,
    this.stackTrace,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? token,
    String? error,
    StackTrace? stackTrace,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

// ================== Auth Store ==================
class AuthStore extends StateNotifier<AuthState> {
  final Ref _ref;
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  late final HiSendConfig _config;

  static const _tokenKey = 'hisend_token';

  AuthStore(this._ref) : super(const AuthState()) {
    _dio = _ref.read(dioProvider);
    _secureStorage = _ref.read(secureStorageProvider);
    _config = _ref.read(hisendConfigProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        await _fetchAndUpdateUser(token);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e, st) {
      state = AuthState(
        status: AuthStatus.error,
        error: 'Failed to restore session',
        stackTrace: st,
      );
    }
  }

  // ================== Public Methods ==================
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String passwordConfirmation,
  }) async {
    await _performAuthOperation(
      operation: () async {
        final response = await _dio.post(
          _buildEndpoint('sign-up'),
          data: {
            'email': email,
            'password': password,
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
            'password_confirmation': passwordConfirmation,
          },
        );

        final token = _extractToken(response.data);
        if (token == null) {
          throw Exception('No authentication token received');
        }

        await _saveTokenAndFetchUser(token);
      },
      successStatus: AuthStatus.authenticated,
    );
  }


  Future<void> initializeFromToken(String token) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Verify the token is still valid by fetching user data
      final user = await _fetchUser(token);

      // If successful, update state
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
    } catch (e) {
      // Token is invalid, clear it and set to unauthenticated
      await _secureStorage.delete(key: _tokenKey);
      state = const AuthState(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> _persistToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<AppUser> _fetchUser(String token) async {
    final response = await _dio.get(
      _buildEndpoint('user'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return AppUser.fromJson(response.data['data'] ?? response.data);
  }

// Modify your login method:
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _dio.post(
        _buildEndpoint('login'),
        data: {'email': email, 'password': password},
      );

      final token = _extractToken(response.data);
      if (token == null) throw Exception('No token received');

      await _persistToken(token);
      await _fetchAndUpdateUser(token);

      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      await clearToken();
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final url = _buildEndpoint('logout');
    final token = state.token ?? await _secureStorage.read(key: _tokenKey);

    try {
      if (token != null) {
        await _dio.post(
          url,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Ignore server logout errors
    } finally {
      await _secureStorage.delete(key: _tokenKey);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _performAuthOperation(
      operation: () async {
        await _dio.put(
          _buildEndpoint('verify-email'),
          data: {'email': email, 'code': code},
        );
        await getCurrentUser(); // Refresh user data
      },
    );
  }

  Future<void> verifyPhone({
    required String phone,
    required String code,
  }) async {
    await _performAuthOperation(
      operation: () async {
        await _dio.put(
          _buildEndpoint('verify-phone'),
          data: {'phone': phone, 'code': code},
        );
        await getCurrentUser(); // Refresh user data
      },
    );
  }

  Future<void> getCurrentUser() async {
    await _performAuthOperation(
      operation: () async {
        final token = state.token ?? await _secureStorage.read(key: _tokenKey);
        if (token == null) {
          throw Exception('No authentication token available');
        }
        await _fetchAndUpdateUser(token);
      },
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _performAuthOperation(
      operation: () => _dio.post(
        _buildEndpoint('reset-password-request'),
        data: {'email': email},
      ),
      updateState: false,
    );
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    await _performAuthOperation(
      operation: () => _dio.post(
        _buildEndpoint('reset-password'),
        data: {'code': code, 'password': newPassword},
      ),
      updateState: false,
    );
  }

  // ================== Private Helpers ==================
  Future<void> _performAuthOperation({
    required Future<void> Function() operation,
    AuthStatus successStatus = AuthStatus.authenticated,
    bool updateState = true,
  }) async {
    if (updateState) {
      state = state.copyWith(status: AuthStatus.loading, error: null);
    }

    try {
      await operation();
      if (updateState) {
        state = state.copyWith(status: successStatus, error: null);
      }
    } on DioException catch (e, st) {
      if (updateState) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: _parseDioError(e),
          stackTrace: st,
        );
      }
      rethrow;
    } catch (e, st) {
      if (updateState) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          stackTrace: st,
        );
      }
      rethrow;
    }
  }

  Future<void> _saveTokenAndFetchUser(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _fetchAndUpdateUser(token);
  }

  Future<void> _fetchAndUpdateUser(String token) async {
    final user = await _fetchUser(token);
    state = state.copyWith(
      status: user.isVerified
          ? AuthStatus.authenticated
          : AuthStatus.needsVerification,
      user: user,
      token: token,
      error: null,
    );
  }



  String _buildEndpoint(String path) =>
      'projects/${_config.projectId}/auth/$path';

  // ================== Response Parsing ==================
  String? _extractToken(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;

    // Check top-level fields
    if (responseData.containsKey('token')) return responseData['token'];
    if (responseData.containsKey('access_token')) return responseData['access_token'];

    // Check nested in 'data' field
    final data = responseData['data'];
    if (data is Map<String, dynamic>) {
      if (data.containsKey('token')) return data['token'];
      if (data.containsKey('access_token')) return data['access_token'];
      if (data.containsKey('session') && data['session'] is Map) {
        return data['session']['token'];
      }
    }

    return null;
  }

  Map<String, dynamic> _normalizeResponseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return {};
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      try {
        final data = e.response!.data;
        if (data is Map && (data['message'] != null || data['error'] != null)) {
          return (data['message'] ?? data['error']).toString();
        }
        return e.response!.statusMessage ?? e.message ?? 'Network error occurred';
      } catch (_) {
        return e.message ?? 'Network error occurred';
      }
    }
    return e.message ?? 'Network error occurred';
  }
}