import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
        switch (statusCode) {
          case 400:
            message = '错误请求';
            break;
          case 401:
            message = '未授权，请重新登录';
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
}
