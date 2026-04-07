import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  // 定义登出回调
  static VoidCallback? onUnauthorized;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 排除登出接口，避免循环触发
    if (response.requestOptions.path.contains('/user/logout')) {
      return handler.next(response);
    }

    // 即使是 200 响应，也检查业务 code 是否表示 Token 过期
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (_isTokenExpired(code, data)) {
        debugPrint('ErrorInterceptor: 业务代码检测到 Token 过期 (code: $code)');
        if (onUnauthorized != null) {
          onUnauthorized!();
        }
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 排除登出接口
    if (err.requestOptions.path.contains('/user/logout')) {
      return handler.next(err);
    }

    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接服务器超时，请检查网络设置';
        break;
      case DioExceptionType.sendTimeout:
        message = '请求发送超时，请重试';
        break;
      case DioExceptionType.receiveTimeout:
        message = '服务器响应超时，请稍后重试';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;

        // 统一检测 Token 过期逻辑
        if (_isTokenExpired(statusCode, responseData)) {
          message = '登录已过期，请重新登录';
          // 触发全局登出回调
          if (onUnauthorized != null) {
            debugPrint('ErrorInterceptor: 触发全局登出回调 (状态码: $statusCode)');
            onUnauthorized!();
          }
        } else {
          switch (statusCode) {
            case 400:
              message = '错误请求';
              break;
            case 403:
              message = '拒绝访问';
              break;
            case 404:
              message = '请求资源不存在';
              break;
            case 500:
              message = '服务器内部错误';
              break;
            case 502:
              message = '网关错误';
              break;
            case 503:
              message = '服务不可用';
              break;
            case 504:
              message = '网关超时';
              break;
            default:
              message = '网络请求错误 ($statusCode)';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络';
        break;
      default:
        message = '未知错误，请重试';
    }

    // 将友好提示存入 error 对象，方便 UI 层读取
    final customError = err.copyWith(message: message);

    return handler.next(customError);
  }

  /// 统一检测 Token 是否过期的逻辑
  bool _isTokenExpired(dynamic statusCode, dynamic responseData) {
    // 1. 检查 HTTP 状态码或业务状态码 (401: 未授权, 403: 权限拒绝)
    if (statusCode == 401 || statusCode == 403) {
      return true;
    }

    // 2. 语义化模糊检测 (借鉴参考代码：正则表达式支持中英文)
    if (responseData is Map<String, dynamic>) {
      final String msg = (responseData['msg'] ?? '').toString();
      final String message = (responseData['message'] ?? '').toString();
      final fullMsg = '$msg|$message';

      if (fullMsg.isEmpty) return false;

      // 关键词：token, 登录, 认证, 鉴权, unauthorized, forbidden
      final RegExp authFailPattern = RegExp(
        r'token|登录|认证|鉴权|unauthorized|forbidden',
        caseSensitive: false,
      );

      // 只要消息中命中关键词，判定为认证失效
      if (authFailPattern.hasMatch(fullMsg)) {
        return true;
      }
    }

    return false;
  }
}
