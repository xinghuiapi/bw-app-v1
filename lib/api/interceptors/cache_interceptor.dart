import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../request_cache_manager.dart';

/// 缓存拦截器
/// 实现 API 请求缓存 (LRU) 和 请求去重
class CacheInterceptor extends Interceptor {
  final RequestCacheManager _cacheManager = RequestCacheManager();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 仅缓存 GET 请求，且未明确禁用缓存
    if (options.method.toUpperCase() != 'GET' || options.extra['noCache'] == true) {
      return handler.next(options);
    }

    final key = _cacheManager.generateKey(options);
    final forceRefresh = options.extra['forceRefresh'] == true;

    // 1. 检查正在进行的请求 (去重)
    // 即使是 forceRefresh，如果有正在进行的请求，也应该等待它，而不是发起新的并发请求
    final pendingCompleter = _cacheManager.getPending(key);
    if (pendingCompleter != null) {
      if (kDebugMode) {
        print('[CacheInterceptor] Waiting for pending request: ${options.path}');
      }
      try {
        final response = await pendingCompleter.future;
        return handler.resolve(Response(
          requestOptions: options,
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          headers: response.headers,
          extra: response.extra,
        ));
      } catch (e) {
        // 如果等待的请求失败了，继续发起新请求
        _cacheManager.removePending(key);
      }
    }

    // 2. 检查缓存
    if (!forceRefresh) {
      final cachedResponse = _cacheManager.get(key);
      if (cachedResponse != null) {
        if (kDebugMode) {
          print('[CacheInterceptor] Cache hit: ${options.path}');
        }
        return handler.resolve(Response(
          requestOptions: options,
          data: cachedResponse.data,
          statusCode: cachedResponse.statusCode,
          statusMessage: cachedResponse.statusMessage,
          headers: cachedResponse.headers,
          extra: cachedResponse.extra..addAll({'fromCache': true}),
        ));
      }
    }

    // 3. 标记为正在进行
    // 创建一个 Completer 标记当前请求正在进行
    final completer = Completer<Response>();
    _cacheManager.addPending(key, completer);

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    
    // 仅缓存 GET 请求
    if (options.method.toUpperCase() == 'GET' && options.extra['noCache'] != true) {
      final key = _cacheManager.generateKey(options);
      
      // 获取 TTL 配置，默认 5 分钟
      final ttl = options.extra['cacheTtl'] as Duration? ?? const Duration(minutes: 5);
      
      _cacheManager.set(key, response, ttl: ttl);
      
      // 完成 pending Completer
      final pendingCompleter = _cacheManager.getPending(key);
      if (pendingCompleter != null && !pendingCompleter.isCompleted) {
        pendingCompleter.complete(response);
      }
      
      // 移除 pending 标记 (注意：这里其实应该在 complete 后保留一小段时间防止并发，但 LRU set 已经写入缓存了)
      // 所以后续请求会命中缓存，不需要 pending 标记了
      _cacheManager.removePending(key);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final key = _cacheManager.generateKey(options);
    
    // 失败时，让等待的请求也失败
    final pendingCompleter = _cacheManager.getPending(key);
    if (pendingCompleter != null && !pendingCompleter.isCompleted) {
      pendingCompleter.completeError(err);
    }
    
    _cacheManager.removePending(key);
    
    handler.next(err);
  }
}
