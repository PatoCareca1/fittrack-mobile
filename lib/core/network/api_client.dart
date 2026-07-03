import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../storage/token_storage.dart';

/// Cliente HTTP com injeção de JWT e refresh automático em 401
/// (README seção 5.3 — Dio com JWT refresh automático).
///
/// O backend usa ROTATE_REFRESH_TOKENS + blacklist: cada refresh é de uso
/// único e devolve um novo par. Por isso o refresh é single-flight — vários
/// 401 simultâneos compartilham a mesma renovação.
class ApiClient {
  ApiClient(this._tokens) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await _tokens.access;
          if (access != null && !options.path.startsWith('/auth/')) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.startsWith('/auth/')) {
            final failedToken = (error.requestOptions.headers['Authorization']
                    as String?)
                ?.replaceFirst('Bearer ', '');
            final current = await _tokens.access;
            // Se outro handler já renovou enquanto este esperava na fila,
            // só repete a chamada com o token novo.
            final ok =
                (current != null && current != failedToken) || await _tryRefresh();
            if (ok) {
              final access = await _tokens.access;
              error.requestOptions.headers['Authorization'] = 'Bearer $access';
              try {
                final retried = await dio.fetch(error.requestOptions);
                return handler.resolve(retried);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokens;
  late final Dio dio;

  Future<bool>? _refreshing;

  Future<bool> _tryRefresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refresh = await _tokens.refresh;
    if (refresh == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
          .post('/auth/refresh/', data: {'refresh': refresh});
      final access = res.data['access'] as String?;
      if (access == null) return false;
      // Rotação: o backend devolve também um refresh novo — persistir os dois.
      final newRefresh = res.data['refresh'] as String?;
      if (newRefresh != null) {
        await _tokens.save(access: access, refresh: newRefresh);
      } else {
        await _tokens.saveAccess(access);
      }
      return true;
    } on DioException catch (e) {
      // Só desloga se o refresh foi de fato rejeitado — falha de rede não
      // pode apagar a sessão.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        await _tokens.clear();
      }
      return false;
    }
  }
}
