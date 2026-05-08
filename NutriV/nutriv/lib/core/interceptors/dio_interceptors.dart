import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class LoggingInterceptor extends Interceptor {
  static final _log = Logger('LoggingInterceptor');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.info('📤 REQUEST: ${options.method} ${options.uri}');
    if (options.data != null) {
      _log.info('   Data: ${options.data}');
    }
    _log.info('   Headers: ${options.headers}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.info(
        '📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.severe('❌ ERROR: ${err.type} ${err.requestOptions.uri}');
    _log.severe('   Message: ${err.message}');
    return handler.next(err);
  }
}

class AuthInterceptor extends Interceptor {
  static final _log = Logger('AuthInterceptor');
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authToken = Supabase.instance.client.auth.currentSession?.accessToken;
    if (authToken != null) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _log.warning('⚠️ AuthInterceptor: Token expirado, tentando refresh...');
      _refreshToken();
    }
    return handler.next(err);
  }

  Future<void> _refreshToken() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
      _log.info('✅ AuthInterceptor: Token refreshado com sucesso');
    } catch (e) {
      _log.severe('❌ AuthInterceptor: Falha ao refresh token: $e');
    }
  }
}
