import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

class AuthInterceptor extends Interceptor {
  String? _currentLang;

  void updateLanguage(String lang) {
    _currentLang = lang;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AuthHelper.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // 默认语言设置
    options.headers['lang'] = _currentLang ?? 'CN';
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 记录 API 错误到终端
    debugPrint('=== API ERROR [${err.requestOptions.method}] ${err.requestOptions.path} ===');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Error Message: ${err.message}');
    debugPrint('Response Data: ${err.response?.data}');
    debugPrint('======================================================');

    // 处理 401 错误 (Token 过期)
    if (err.response?.statusCode == 401) {
      await AuthHelper.clearToken();
    }
    return handler.next(err);
  }
}
