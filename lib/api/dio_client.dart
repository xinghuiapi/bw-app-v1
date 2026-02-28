import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../utils/constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  // 根据环境设置不同的 BaseURL (对标 src/api/index.js 中的 getUnifiedApiBaseURL)
  static String get _baseUrl {
    if (kDebugMode) {
      // 开发环境使用真实的 API 地址
      return AppConstants.apiBaseUrl;
    }
    // 生产环境：从配置或环境变量中获取
    return "https://api.example.com";
  }

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15), // 连接超时 15s
      receiveTimeout: const Duration(seconds: 15), // 接收超时 15s
      sendTimeout: const Duration(seconds: 15),    // 发送超时 15s
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 1. 添加认证拦截器 (Token注入, 401处理)
    dio.interceptors.add(AuthInterceptor());

    // 2. 添加全局错误处理拦截器 (映射 DioException 为友好提示)
    dio.interceptors.add(ErrorInterceptor());

    // 3. 添加智能重试拦截器 (针对移动端网络不稳定)
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: (message) => debugPrint('[RetryInterceptor] $message'),
      retries: 3, // 最多重试 3 次
      retryDelays: const [
        Duration(seconds: 1), // 第一次重试延迟 1s
        Duration(seconds: 2), // 第二次重试延迟 2s
        Duration(seconds: 3), // 第三次重试延迟 3s
      ],
      retryableExtraStatuses: {408, 502, 503, 504}, // 增加可重试的状态码
    ));

    // 4. 日志拦截器 (仅在调试模式)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
    }
  }

  /// 动态更新 BaseURL (对应 src/api/index.js 中的 refreshBaseURL)
  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }
}

// 全局 Dio 实例
final api = DioClient().dio;

/// 快速创建 Dio Options 的助手方法
Options dioOptions({Map<String, dynamic>? headers}) {
  return Options(headers: headers);
}
