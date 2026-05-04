import 'package:dio/dio.dart';

class CachedResponse {
  final Response<dynamic> response;
  final DateTime expiresAt;

  const CachedResponse({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class RequestCacheManager {
  final Map<String, CachedResponse> _cache = <String, CachedResponse>{};

  Response<dynamic>? get(String key) {
    final cached = _cache[key];
    if (cached == null) {
      return null;
    }
    if (cached.isExpired) {
      _cache.remove(key);
      return null;
    }
    return cached.response;
  }

  void set(String key, Response<dynamic> response, Duration ttl) {
    _cache[key] = CachedResponse(
      response: response,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void clear() => _cache.clear();
}

String requestCacheKey(RequestOptions options) {
  final query = Map<String, dynamic>.from(options.queryParameters);
  final queryEntries = query.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return '${options.method}:${options.uri.path}?$queryEntries';
}
