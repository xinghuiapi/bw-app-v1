import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 请求缓存项
class CacheItem {
  final Response response;
  final int timestamp;
  final Duration ttl;

  CacheItem({
    required this.response,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch - timestamp >
        ttl.inMilliseconds;
  }
}

/// LRU (Least Recently Used) 缓存管理器
///
/// 特性：
/// 1. 内存缓存，基于 LinkedHashMap 实现 LRU
/// 2. 请求去重，避免并发重复请求
/// 3. 自动清理过期缓存
class RequestCacheManager {
  static final RequestCacheManager _instance = RequestCacheManager._internal();

  factory RequestCacheManager() => _instance;

  RequestCacheManager._internal() {
    // 启动自动清理任务
    _startCleanupTimer();
  }

  // 缓存配置
  static const int _maxSize = 50;
  static const Duration _defaultTtl = Duration(minutes: 5);
  static const Duration _cleanupInterval = Duration(minutes: 1);

  // 缓存存储 (LRU: 使用 LinkedHashMap 保持插入顺序)
  final LinkedHashMap<String, CacheItem> _cache = LinkedHashMap();

  // 正在进行的请求 (用于去重)
  final Map<String, Completer<Response>> _pendingRequests = {};

  Timer? _cleanupTimer;

  /// 生成请求唯一Key
  String generateKey(RequestOptions options) {
    // 包含 method, path, queryParameters, data
    // 注意：data 需要能够正确序列化，如果是 FormData 可能需要特殊处理
    final keyParts = [
      options.method,
      options.baseUrl,
      options.path,
      options.queryParameters.toString(),
      options.data?.toString() ?? '',
    ];
    return keyParts.join('|');
  }

  /// 获取缓存
  Response? get(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (item.isExpired) {
      _cache.remove(key);
      return null;
    }

    // LRU: 访问后移动到末尾 (表示最近使用)
    _cache.remove(key);
    _cache[key] = item;

    return item.response;
  }

  /// 设置缓存
  void set(String key, Response response, {Duration ttl = _defaultTtl}) {
    // 如果缓存已满，移除最早的元素 (第一个)
    if (_cache.length >= _maxSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
      if (kDebugMode) {
        print('[RequestCache] LRU Eviction: $firstKey');
      }
    }

    // 存储新缓存
    _cache[key] = CacheItem(
      response: response,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: ttl,
    );
  }

  /// 检查是否有正在进行的请求
  Completer<Response>? getPending(String key) {
    return _pendingRequests[key];
  }

  /// 记录正在进行的请求
  void addPending(String key, Completer<Response> completer) {
    _pendingRequests[key] = completer;
  }

  /// 移除正在进行的请求
  void removePending(String key) {
    _pendingRequests.remove(key);
  }

  /// 清除指定缓存
  void remove(String key) {
    _cache.remove(key);
    _pendingRequests.remove(key);
  }

  /// 清除所有缓存
  void clear() {
    _cache.clear();
    _pendingRequests.clear();
  }

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _cleanupExpired();
    });
  }

  /// 清理过期缓存
  void _cleanupExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToRemove = <String>[];

    _cache.forEach((key, item) {
      if (now - item.timestamp > item.ttl.inMilliseconds) {
        keysToRemove.add(key);
      }
    });

    for (var key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty && kDebugMode) {
      print('[RequestCache] Cleaned ${keysToRemove.length} expired items');
    }
  }

  /// 销毁
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _pendingRequests.clear();
  }
}
