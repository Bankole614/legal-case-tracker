import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../providers/core_providers.dart';
import '../repositories/auth_repository.dart';
import '../storage/token_storage.dart';
import '../models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final cfg = ref.read(hisendConfigProvider);
  return AuthRepository(dio: dio, cfg: cfg);
});

final authStoreProvider = StateNotifierProvider<AuthStore, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final tokens = ref.read(tokenStorageProvider);
  return AuthStore(repo: repo, tokens: tokens);
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, needsVerification, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? error;
  const AuthState({this.status = AuthStatus.initial, this.user, this.token, this.error});
  AuthState copyWith({AuthStatus? status, AppUser? user, String? token, String? error}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user, token: token ?? this.token, error: error ?? this.error);
  }
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthStore extends StateNotifier<AuthState> {
  final AuthRepository repo;
  final TokenStorage tokens;
  AuthStore({required this.repo, required this.tokens}) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await tokens.readToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    await initializeFromToken(token);
  }

  Future<void> initializeFromToken(String token) async {
    state = state.copyWith(status: AuthStatus.loading, token: token);
    try {
      final raw = await repo.getUserRaw(token);
      final user = AppUser.fromJson(raw);
      await tokens.writeToken(token);
      final newStatus = (user.email != null || user.name != null) ? AuthStatus.authenticated : AuthStatus.needsVerification;
      state = state.copyWith(status: newStatus, user: user, token: token, error: null);
    } on DioException catch (e) {
      await tokens.deleteToken();
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      await tokens.deleteToken();
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final token = await repo.login(email: email, password: password);
      if (token == null) {
        state = state.copyWith(status: AuthStatus.error, error: 'No token returned from server');
        return false;
      }
      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password, required String firstName, required String lastName, required String phone}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final token = await repo.signUp(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone);
      if (token == null) {
        state = state.copyWith(status: AuthStatus.needsVerification, error: null);
        return false;
      }
      await initializeFromToken(token);
      return state.isAuthenticated;
    } on DioException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = state.token ?? await tokens.readToken();
      if (token != null) {
        try {
          await repo.logout(token);
        } catch (_) {}
      }
    } finally {
      await tokens.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}
