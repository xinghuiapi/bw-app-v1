import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../config/app_env.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'request_cache_manager.dart';
import 'token_storage.dart';

class DioClient {
  DioClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    RequestCacheManager? cacheManager,
    AuthExpiredCallback? onAuthExpired,
  })  : _dio = dio ?? Dio(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _cacheManager = cacheManager ?? RequestCacheManager() {
    _configure(onAuthExpired: onAuthExpired);
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final RequestCacheManager _cacheManager;

  Dio get raw => _dio;
  TokenStorage get tokenStorage => _tokenStorage;
  RequestCacheManager get cacheManager => _cacheManager;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? decoder,
    bool cache = false,
    Duration? cacheTtl,
  }) {
    return request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      decoder: decoder,
      cache: cache,
      cacheTtl: cacheTtl,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? decoder,
  }) {
    return request<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      decoder: decoder,
    );
  }

  Future<T> request<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? decoder,
    bool cache = false,
    Duration? cacheTtl,
  }) async {
    try {
      final mergedOptions = (options ?? Options()).copyWith(
        method: method,
        extra: <String, dynamic>{
          ...?options?.extra,
          if (cache) 'cache': true,
          if (cacheTtl != null) 'cacheTtl': cacheTtl,
        },
      );
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
      );
      final payload = _extractPayload(response.data);
      if (decoder != null) {
        return decoder(payload);
      }
      return payload as T;
    } on DioException catch (error) {
      final apiException = error.error;
      if (apiException is ApiException) {
        throw apiException;
      }
      throw ApiException(
        type: ApiExceptionType.unknown,
        message: error.message ?? 'Unknown network error',
        statusCode: error.response?.statusCode,
        cause: error,
      );
    } on TypeError catch (error) {
      throw ApiException(
        type: ApiExceptionType.parse,
        message: 'Response parse failed',
        cause: error,
      );
    }
  }

  void _configure({AuthExpiredCallback? onAuthExpired}) {
    _dio.options = BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: AppEnv.connectTimeout,
      receiveTimeout: AppEnv.receiveTimeout,
      sendTimeout: AppEnv.sendTimeout,
      headers: const <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        onAuthExpired: onAuthExpired,
      ),
      CacheInterceptor(cacheManager: _cacheManager),
      RetryInterceptor(
        dio: _dio,
        retries: 1,
        retryDelays: const <Duration>[Duration(milliseconds: 500)],
      ),
      ErrorInterceptor(),
      if (AppEnv.enableNetworkLog && kDebugMode)
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
        ),
    ]);
  }

  Object? _extractPayload(Object? data) {
    if (data is Map && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }
}
