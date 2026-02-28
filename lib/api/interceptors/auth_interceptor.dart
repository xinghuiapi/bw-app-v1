import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../utils/auth_helper.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AuthHelper.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // ⚠️ 增加：默认语言头 (对标原项目)
    options.headers['lang'] = 'CN';
    
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
