import 'package:dio/dio.dart';

import '../request_cache_manager.dart';

class CacheInterceptor extends Interceptor {
  CacheInterceptor({
    required RequestCacheManager cacheManager,
    this.defaultTtl = const Duration(minutes: 3),
  }) : _cacheManager = cacheManager;

  final RequestCacheManager _cacheManager;
  final Duration defaultTtl;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET' ||
        options.extra['cache'] != true) {
      handler.next(options);
      return;
    }

    final cached = _cacheManager.get(requestCacheKey(options));
    if (cached != null) {
      handler.resolve(cached);
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    if (options.method.toUpperCase() == 'GET' &&
        options.extra['cache'] == true) {
      final ttl = options.extra['cacheTtl'];
      _cacheManager.set(
        requestCacheKey(options),
        response,
        ttl is Duration ? ttl : defaultTtl,
      );
    }
    handler.next(response);
  }
}
