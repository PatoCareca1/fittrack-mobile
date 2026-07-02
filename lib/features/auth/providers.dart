import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.loading = false, this.error});

  final AuthStatus status;
  final bool loading;
  final String? error;

  AuthState copyWith({AuthStatus? status, bool? loading, String? error}) => AuthState(
        status: status ?? this.status,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState();
  }

  TokenStorage get _tokens => ref.read(tokenStorageProvider);
  Dio get _dio => ref.read(apiClientProvider).dio;

  Future<void> _restore() async {
    final access = await _tokens.access;
    state = state.copyWith(
      status: access == null ? AuthStatus.signedOut : AuthStatus.signedIn,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _dio.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      await _tokens.save(
        access: res.data['access'] as String,
        refresh: res.data['refresh'] as String,
      );
      state = state.copyWith(status: AuthStatus.signedIn, loading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.response?.statusCode == 401 || e.response?.statusCode == 400
            ? 'E-mail ou senha inválidos'
            : 'Não foi possível conectar. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String accountType,
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true);
    try {
      await _dio.post('/auth/register/', data: {
        'account_type': accountType,
        'name': name,
        'email': email,
        'password': password,
      });
      return login(email, password);
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.response?.statusCode == 400
            ? 'Verifique os dados informados'
            : 'Não foi possível conectar. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _tokens.clear();
    state = state.copyWith(status: AuthStatus.signedOut);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
