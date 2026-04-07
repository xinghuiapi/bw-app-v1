import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  String? _currentLang;

  AuthInterceptor(this.dio);

  void updateLanguage(String lang) {
    _currentLang = lang;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthHelper.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 仅在未设置 lang 头时设置默认值
    if (!options.headers.containsKey('lang')) {
      options.headers['lang'] = _currentLang ?? 'CN';
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 排除登出接口
    if (response.requestOptions.path.contains('/user/logout')) {
      return handler.next(response);
    }

    // 如果业务 code 表示 Token 过期，也清除本地 Token
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (_isTokenExpired(code, data)) {
        debugPrint('AuthInterceptor: 业务代码检测到 Token 过期 (code: $code)，清除本地 Token');
        await AuthHelper.clearToken();
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 排除登出接口
    if (err.requestOptions.path.contains('/user/logout')) {
      return handler.next(err);
    }

    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;

    // 处理 Token 过期或无效
    if (_isTokenExpired(statusCode, responseData)) {
      debugPrint('AuthInterceptor: 检测到 Token 过期或无效 (状态码: $statusCode)，准备清除登录状态...');
      await AuthHelper.clearToken();
    }
    handler.next(err);
  }

  /// 统一检测 Token 是否过期的逻辑 (同步 ErrorInterceptor)
  bool _isTokenExpired(dynamic statusCode, dynamic responseData) {
    if (statusCode == 401 || statusCode == 403) return true;

    if (responseData is Map<String, dynamic>) {
      final String msg = (responseData['msg'] ?? '').toString().toLowerCase();
      final String message =
          (responseData['message'] ?? '').toString().toLowerCase();

      final isExpiredMsg =
          (msg.contains('token') || message.contains('token')) &&
          (msg.contains('expire') ||
              msg.contains('invalid') ||
              msg.contains('auth') ||
              message.contains('expire') ||
              message.contains('invalid') ||
              message.contains('auth'));

      if (isExpiredMsg) return true;
    }
    return false;
  }
}
