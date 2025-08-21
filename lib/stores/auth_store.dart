import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/core_providers.dart';
import '../repositories/auth_repository.dart';
import '../models/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? token,
    String? error
  }) {
    return AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        token: token ?? this.token,
        error: error ?? this.error
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
    state = state.copyWith(status: AuthStatus.loading);
    final token = await secureStorage.read(key: 'hisend_token');

    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    await initializeFromToken(token);
  }

  Future<void> initializeFromToken(String token) async {
    state = state.copyWith(status: AuthStatus.loading, token: token);

    try {
      final userData = await repo.getUserRaw(token);
      final user = AppUser.fromJson(userData);

      await secureStorage.write(key: 'hisend_token', value: token);

      state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
          error: null
      );
    } on DioException catch (e) {
      await secureStorage.delete(key: 'hisend_token');
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: e.response?.data?['message'] ?? e.message ?? 'Authentication failed'
      );
    } catch (e) {
      await secureStorage.delete(key: 'hisend_token');
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: e.toString()
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final token = await repo.login(email: email, password: password);

      if (token == null) {
        state = state.copyWith(
            status: AuthStatus.error,
            error: 'No token returned from server'
        );
        return false;
      }

      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed';
      state = state.copyWith(
          status: AuthStatus.error,
          error: errorMessage
      );
      return false;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          error: e.toString()
      );
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
    state = state.copyWith(status: AuthStatus.loading, error: null);

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
        state = state.copyWith(
            status: AuthStatus.error,
            error: 'No token returned from server'
        );
        return false;
      }

      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Signup failed';
      state = state.copyWith(
          status: AuthStatus.error,
          error: errorMessage
      );
      return false;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          error: e.toString()
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final token = state.token ?? await secureStorage.read(key: 'hisend_token');
      if (token != null) {
        try {
          await repo.logout(token);
        } catch (e) {
          // Logout API call might fail, but we still want to clear local data
          print('Logout API call failed: $e');
        }
      }
    } finally {
      await secureStorage.delete(key: 'hisend_token');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

// Provider for AuthStore
final authStoreProvider = StateNotifierProvider<AuthStore, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthStore(repo: repo, secureStorage: secureStorage);
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final cfg = ref.read(hisendConfigProvider);
  return AuthRepository(dio: dio, cfg: cfg);
});