import 'package:dio/dio.dart';

import '../../config/api_endpoints.dart';
import '../api_exception.dart';
import '../token_storage.dart';

typedef AuthExpiredCallback = Future<void> Function();

class ApiRequestDefaults {
  static const lang = 'CN';
  static const tokenType = 'bearer';
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorageContract tokenStorage,
    AuthExpiredCallback? onAuthExpired,
  })  : _tokenStorage = tokenStorage,
        _onAuthExpired = onAuthExpired;

  final TokenStorageContract _tokenStorage;
  final AuthExpiredCallback? _onAuthExpired;
  bool _isHandlingAuthExpired = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('lang', () => ApiRequestDefaults.lang);

    if (_shouldAppendLangQuery(options.path) &&
        !options.queryParameters.containsKey('lang')) {
      options.queryParameters['lang'] = ApiRequestDefaults.lang;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      final tokenType = await _tokenStorage.readTokenType();
      options.headers['Authorization'] =
          '${tokenType ?? ApiRequestDefaults.tokenType} $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_isAuthExpiredResponse(response) &&
        !_shouldIgnoreAuth(response.requestOptions.path)) {
      await _handleAuthExpired();
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: ApiException(
            type: ApiExceptionType.unauthorized,
            message: _messageFromResponse(response) ?? 'Login expired',
            statusCode: response.statusCode,
          ),
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null &&
        _isAuthExpiredResponse(response) &&
        !_shouldIgnoreAuth(err.requestOptions.path)) {
      await _handleAuthExpired();
    }
    handler.next(err);
  }

  bool _shouldIgnoreAuth(String path) {
    return authIgnoredPaths.any((ignored) => path.endsWith(ignored));
  }

  bool _shouldAppendLangQuery(String path) {
    return !langQueryIgnoredPaths.any((ignored) => path.endsWith(ignored));
  }

  bool _isAuthExpiredResponse(Response<dynamic> response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      return true;
    }
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code == 401 || code == 403 || code == '401' || code == '403') {
        return true;
      }
      final message = _messageFromResponse(response)?.toLowerCase() ?? '';
      return message.contains('token') ||
          message.contains('unauthorized') ||
          message.contains('forbidden') ||
          message.contains('登录') ||
          message.contains('认证') ||
          message.contains('鉴权') ||
          message.contains('过期');
    }
    return false;
  }

  String? _messageFromResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['msg'] ?? data['message'])?.toString();
    }
    return null;
  }

  Future<void> _handleAuthExpired() async {
    if (_isHandlingAuthExpired) {
      return;
    }
    _isHandlingAuthExpired = true;
    await _tokenStorage.clear();
    await _onAuthExpired?.call();
    Future<void>.delayed(const Duration(seconds: 1), () {
      _isHandlingAuthExpired = false;
    });
  }
}
