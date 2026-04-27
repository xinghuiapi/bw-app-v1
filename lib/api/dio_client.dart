import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/api/interceptors/auth_interceptor.dart';
import 'package:my_flutter_app/api/interceptors/cache_interceptor.dart';
import 'package:my_flutter_app/api/interceptors/error_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  late final AuthInterceptor authInterceptor;
  late final CacheInterceptor cacheInterceptor;

  // 根据环境设置不同的 BaseURL
  static String get _baseUrl {
    return AppConstants.apiBaseUrl;
  }

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    authInterceptor = AuthInterceptor(dio);
    cacheInterceptor = CacheInterceptor();

    // 拦截器顺序很重要：
    // 1. Auth: 注入 token
    // 2. Cache: 检查缓存 (如果命中直接返回，不走网络)
    // 3. Error: 处理错误
    // 4. Retry: 重试 (如果网络失败)
    // 5. Log: 打印日志

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(cacheInterceptor);
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (message) => debugPrint('[RetryInterceptor] $message'),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryableExtraStatuses: {408, 502, 503, 504},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
        ),
      );
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
Options dioOptions({
  Map<String, dynamic>? headers,
  Map<String, dynamic>? extra,
}) {
  return Options(headers: headers, extra: extra);
}
