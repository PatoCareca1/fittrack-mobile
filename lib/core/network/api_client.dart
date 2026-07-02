import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../storage/token_storage.dart';

/// Cliente HTTP com injeção de JWT e refresh automático em 401
/// (README seção 5.3 — Dio com JWT refresh automático).
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
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final retried = await dio.fetch(error.requestOptions);
              return handler.resolve(retried);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokens;
  late final Dio dio;

  Future<bool> _tryRefresh() async {
    final refresh = await _tokens.refresh;
    if (refresh == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
          .post('/auth/refresh/', data: {'refresh': refresh});
      final access = res.data['access'] as String?;
      if (access == null) return false;
      await _tokens.saveAccess(access);
      return true;
    } on DioException {
      await _tokens.clear();
      return false;
    }
  }
}
