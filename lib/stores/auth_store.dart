// lib/stores/auth_store.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/core_providers.dart';
import '../repositories/auth_repository.dart';
import '../models/app_user.dart';

const _kTokenKey = 'hisend_token';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? error;
  final Map<String, List<String>> validationErrors;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error,
    this.validationErrors = const {},
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? token,
    String? error,
    Map<String, List<String>>? validationErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthStore extends StateNotifier<AuthState> {
  final AuthRepository repo;
  final FlutterSecureStorage secureStorage;

  AuthStore({required this.repo, required this.secureStorage}) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      final stored = await secureStorage.read(key: _kTokenKey);
      if (stored == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      await initializeFromToken(stored);
    } catch (e, st) {
      await secureStorage.delete(key: _kTokenKey);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> initializeFromToken(String token) async {
    state = state.copyWith(status: AuthStatus.loading, token: token, error: null, validationErrors: {});
    try {
      final raw = await repo.getUserRaw(token);
      final user = AppUser.fromJson(raw);
      await secureStorage.write(key: _kTokenKey, value: token);
      state = state.copyWith(status: AuthStatus.authenticated, user: user, token: token, error: null, validationErrors: {});
    } on DioException catch (e) {
      await secureStorage.delete(key: _kTokenKey);
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: msg, validationErrors: valErrs);
    } catch (e) {
      await secureStorage.delete(key: _kTokenKey);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      final token = await repo.login(email: email, password: password);
      if (token == null) {
        state = state.copyWith(status: AuthStatus.error, error: 'No token returned from server');
        return false;
      }
      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.error, error: msg, validationErrors: valErrs);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? passwordConfirmation,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      final token = await repo.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        passwordConfirmation: passwordConfirmation,
      );

      if (token == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
        return false;
      }

      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.error, error: msg, validationErrors: valErrs);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final token = state.token ?? await secureStorage.read(key: _kTokenKey);
      if (token != null) {
        try {
          await repo.logout(token);
        } catch (_) {}
      }
    } finally {
      await secureStorage.delete(key: _kTokenKey);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      final token = state.token ?? await secureStorage.read(key: _kTokenKey);
      if (token == null) throw Exception('No token available');

      final raw = await repo.getUserRaw(token);
      final user = AppUser.fromJson(raw);
      state = state.copyWith(status: AuthStatus.authenticated, user: user, token: token, error: null);
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      await secureStorage.delete(key: _kTokenKey);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: msg, validationErrors: valErrs);
    } catch (e) {
      await secureStorage.delete(key: _kTokenKey);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      final token = state.token ?? await secureStorage.read(key: _kTokenKey);
      if (token == null) throw Exception('Not authenticated');

      final raw = await repo.updateUser(token: token, payload: payload);
      final user = AppUser.fromJson(raw);

      state = state.copyWith(status: AuthStatus.authenticated, user: user, error: null);
      return true;
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.error, error: msg, validationErrors: valErrs);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      await repo.requestPasswordReset(email: email);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.error, error: msg, validationErrors: valErrs);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetPassword({required String code, required String newPassword}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, validationErrors: {});
    try {
      await repo.resetPassword(code: code, newPassword: newPassword);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      final valErrs = _extractValidationErrorsFromResponse(e.response?.data);
      state = state.copyWith(status: AuthStatus.error, error: msg, validationErrors: valErrs);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      rethrow;
    }
  }

  // ----------------- Helpers -----------------

  Map<String, List<String>> _extractValidationErrorsFromResponse(dynamic data) {
    try {
      if (data is String && data.contains('<!DOCTYPE html>')) {
        return {'general': ['Please check your input and try again']};
      }

      if (data is Map) {
        Map? m = data['errors'] is Map ? data['errors'] :
        (data['data'] is Map && data['data']['errors'] is Map ? data['data']['errors'] : null);

        if (m != null) {
          final out = <String, List<String>>{};
          m.forEach((k, v) {
            if (v == null) return;
            if (v is String) out[k.toString()] = [v];
            else if (v is List) out[k.toString()] = v.map((e) => e.toString()).toList();
            else if (v is Map) out[k.toString()] = v.values.map((e) => e.toString()).toList();
            else out[k.toString()] = [v.toString()];
          });
          return out;
        }
      }
    } catch (_) {}
    return <String, List<String>>{};
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      try {
        final data = e.response!.data;

        if (data is String && data.contains('<!DOCTYPE html>')) {
          return 'Validation failed. Please check your input.';
        }

        if (data is Map<String, dynamic>) {
          if (data['message'] != null) return data['message'].toString();
          if (data['error'] != null) return data['error'].toString();

          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List) return firstError.first.toString();
              if (firstError is String) return firstError;
            }
          }
        }

        return e.response!.statusMessage ?? e.message ?? 'Network error';
      } catch (_) {
        return e.message ?? 'Network error';
      }
    }
    return e.message ?? 'Network error';
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final cfg = ref.read(hisendConfigProvider);
  return AuthRepository(dio: dio, cfg: cfg);
});

final authStoreProvider = StateNotifierProvider<AuthStore, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final secure = ref.read(secureStorageProvider);
  return AuthStore(repo: repo, secureStorage: secure);
});