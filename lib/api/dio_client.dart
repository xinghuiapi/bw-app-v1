import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../utils/constants.dart';
import './interceptors/auth_interceptor.dart';
import './interceptors/error_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  late final AuthInterceptor authInterceptor;

  // 根据环境设置不同的 BaseURL
  static String get _baseUrl {
    return AppConstants.apiBaseUrl;
  }

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    authInterceptor = AuthInterceptor();
    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: (message) => debugPrint('[RetryInterceptor] $message'),
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
      retryableExtraStatuses: {408, 502, 503, 504},
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ));
    }
  }

  static Dio get instance => DioClient().dio;

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }
}

// 全局 Dio 实例
final api = DioClient().dio;

/// Dio Options helper
Options dioOptions({Map<String, dynamic>? headers}) {
  return Options(headers: headers);
}
