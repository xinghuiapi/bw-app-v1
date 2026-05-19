import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_exception.dart';
import '../../api/token_storage.dart';
import '../../config/api_endpoints.dart';
import '../../localization/language_storage.dart';
import '../../models/game/game_models.dart';
import '../base_service.dart';

class GameService extends BaseService {
  GameService(super.client);

  static const _classCachePrefix = 'm1_cache_interface_class';
  static const _listCachePrefix = 'm1_cache_interface_list';
  static const _hotCachePrefix = 'm1_cache_gamelist_hot';
  static const _classTtl = Duration(minutes: 10);
  static const _listTtl = Duration(minutes: 5);
  static const _hotTtl = Duration(minutes: 1);

  static final Map<String, _GameCacheEntry<Object?>> _memoryCache =
      <String, _GameCacheEntry<Object?>>{};

  final LanguageStorage _languageStorage = const LanguageStorage();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<GameLobbyCategory>> fetchInterfaceClasses({
    bool refresh = false,
  }) async {
    final cacheKey = await _cacheKey(_classCachePrefix);
    final cached = refresh ? null : await _readCache<List>(cacheKey);
    if (cached != null) {
      unawaited(_refreshInterfaceClasses(cacheKey).catchError((_) {}));
      return _parseInterfaceClasses(cached);
    }

    try {
      final json = await _fetchWithRetry<Object?>(
        () => client.post<Object?>(ApiEndpoints.interfaceClass),
      );
      if (json is List) await _writeCache(cacheKey, json, _classTtl);
      return _parseInterfaceClasses(json);
    } catch (_) {
      final stale = await _readCache<List>(cacheKey, allowExpired: true);
      if (stale != null) return _parseInterfaceClasses(stale);
      rethrow;
    }
  }

  Future<List<GameProviderItem>> fetchInterfaceList({
    required String code,
    bool refresh = false,
  }) async {
    final normalizedCode = code.trim();
    final cacheKey = await _cacheKey(
      _listCachePrefix,
      suffix: normalizedCode.isEmpty ? '__all__' : normalizedCode,
    );
    final cached = refresh ? null : await _readCache<List>(cacheKey);
    if (cached != null) {
      unawaited(
        _refreshInterfaceList(cacheKey, normalizedCode).catchError((_) {}),
      );
      return _parseInterfaceList(cached, normalizedCode);
    }

    try {
      final json = await _fetchWithRetry<Object?>(
        () => client.post<Object?>(
          ApiEndpoints.interfaceList,
          data: normalizedCode.isEmpty
              ? null
              : <String, dynamic>{'code': normalizedCode},
        ),
      );
      if (json is List) await _writeCache(cacheKey, json, _listTtl);
      return _parseInterfaceList(json, normalizedCode);
    } catch (_) {
      final stale = await _readCache<List>(cacheKey, allowExpired: true);
      if (stale != null) return _parseInterfaceList(stale, normalizedCode);
      rethrow;
    }
  }

  Future<List<RecommendedGame>> fetchRecommendedGamesFromInterfaceList({
    bool refresh = false,
  }) async {
    final items = await fetchInterfaceList(code: '', refresh: refresh);
    return items
        .map((item) => RecommendedGame(
              id: item.id,
              code: item.code,
              game: '',
              title: item.title,
              img: item.logo,
              label: item.label,
              type: item.type,
              category: item.category,
              status: item.status,
            ))
        .where((item) => item.title.isNotEmpty && _hasRecoLabel(item.label))
        .take(30)
        .toList();
  }

  Future<List<GameItem>> fetchFavoriteGamesFromRecommend() {
    return client.post<List<GameItem>>(
      ApiEndpoints.interfaceRecommend,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) => GameItem.fromJson(Map<String, dynamic>.from(item)))
            .where((item) =>
                item.id > 0 &&
                item.title?.isNotEmpty == true &&
                item.isFavorite)
            .toList();
      },
    );
  }

  Future<GameListPage> fetchGameList({
    required String code,
    required String game,
    int page = 1,
    int size = 20,
    String searchWord = '',
    String label = '',
    bool refresh = false,
  }) async {
    final payload = <String, dynamic>{
      'page': page,
      'size': size,
      if (code.trim().isNotEmpty) 'code': code.trim(),
      if (game.trim().isNotEmpty) 'game': game.trim(),
      if (label.trim().isNotEmpty) 'label': label.trim(),
      if (searchWord.trim().isNotEmpty) 'search_word': searchWord.trim(),
    };
    final shouldCache = code.trim().isEmpty &&
        game.trim().isEmpty &&
        searchWord.trim().isEmpty &&
        label.trim() == 'hot' &&
        page == 1;
    final cacheKey = shouldCache
        ? await _cacheKey(_hotCachePrefix, suffix: 'size=$size')
        : '';
    final cached = shouldCache && !refresh
        ? await _readCache<Map<String, dynamic>>(cacheKey)
        : null;
    if (cached != null) {
      unawaited(_refreshGameList(cacheKey, payload).catchError((_) {}));
      return GameListPage.fromJson(cached);
    }

    try {
      final json = await _fetchWithRetry<Object?>(
        () => client.post<Object?>(ApiEndpoints.gameList, data: payload),
      );
      if (json is Map) {
        final map = Map<String, dynamic>.from(json);
        if (shouldCache) await _writeCache(cacheKey, map, _hotTtl);
        return GameListPage.fromJson(map);
      }
      return const GameListPage();
    } catch (_) {
      if (shouldCache) {
        final stale = await _readCache<Map<String, dynamic>>(
          cacheKey,
          allowExpired: true,
        );
        if (stale != null) return GameListPage.fromJson(stale);
      }
      rethrow;
    }
  }

  Future<void> setGameFavorite({required int id, required bool favorited}) {
    return client.post<void>(
      ApiEndpoints.gameFavorite,
      data: <String, dynamic>{'id': id, 'status': favorited ? 1 : 0},
      decoder: (_) {},
    );
  }

  Future<GameLaunchResult> launchGame({required int id}) {
    return client.post<GameLaunchResult>(
      ApiEndpoints.gameLogin,
      data: <String, dynamic>{'id': id, 'mobile': 1},
      decoder: (json) {
        if (json is Map) {
          return GameLaunchResult.fromJson(Map<String, dynamic>.from(json));
        }
        return const GameLaunchResult();
      },
    );
  }

  Future<void> _refreshInterfaceClasses(String cacheKey) async {
    final json = await client.post<Object?>(ApiEndpoints.interfaceClass);
    if (json is List) await _writeCache(cacheKey, json, _classTtl);
  }

  Future<void> _refreshInterfaceList(String cacheKey, String code) async {
    final json = await client.post<Object?>(
      ApiEndpoints.interfaceList,
      data: code.isEmpty ? null : <String, dynamic>{'code': code},
    );
    if (json is List) await _writeCache(cacheKey, json, _listTtl);
  }

  Future<void> _refreshGameList(
    String cacheKey,
    Map<String, dynamic> payload,
  ) async {
    final json =
        await client.post<Object?>(ApiEndpoints.gameList, data: payload);
    if (json is Map) {
      await _writeCache(cacheKey, Map<String, dynamic>.from(json), _hotTtl);
    }
  }

  List<GameLobbyCategory> _parseInterfaceClasses(Object? json) {
    if (json is! List) return const [];
    return json
        .whereType<Map>()
        .map((item) =>
            GameLobbyCategory.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.title.isNotEmpty && item.code.isNotEmpty)
        .toList();
  }

  List<GameProviderItem> _parseInterfaceList(Object? json, String code) {
    if (json is! List) return const [];
    final items = json
        .whereType<Map>()
        .map((item) =>
            GameProviderItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.title.isNotEmpty)
        .toList();
    final normalizedCode = code.trim().toLowerCase();
    if (normalizedCode.isEmpty) return items;
    final byType = items
        .where(
            (item) => (item.type ?? '').trim().toLowerCase() == normalizedCode)
        .toList();
    return byType.isEmpty ? items : byType;
  }

  bool _hasRecoLabel(dynamic label) {
    if (label == null) return false;
    if (label is List) {
      return label.map((item) => item.toString().trim()).contains('reco');
    }
    final raw = label.toString().replaceAll('`', '"').trim();
    if (raw.isEmpty) return false;
    final normalized = raw.replaceAll(RegExp(r'''^[\['"]+|[\]'\"]+$'''), '');
    return normalized
        .split(',')
        .map((item) =>
            item.trim().replaceAll(RegExp(r'''^[\['"]+|[\]'\"]+$'''), ''))
        .contains('reco');
  }

  Future<T> _fetchWithRetry<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      if (!_shouldRetry(error)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return request();
    }
  }

  bool _shouldRetry(ApiException error) {
    return error.type == ApiExceptionType.timeout ||
        error.type == ApiExceptionType.network;
  }

  Future<String> _cacheKey(String prefix, {String suffix = ''}) async {
    final rawLang = await _languageStorage.read();
    final lang = (rawLang == null || rawLang.trim().isEmpty)
        ? 'CN'
        : rawLang.trim().toUpperCase();
    final token = await _tokenStorage.readAccessToken();
    final auth = token == null || token.trim().isEmpty ? 'anon' : 'auth';
    return [prefix, lang, auth, if (suffix.isNotEmpty) suffix].join('_');
  }

  Future<T?> _readCache<T>(String key, {bool allowExpired = false}) async {
    final now = DateTime.now();
    final memory = _memoryCache[key];
    if (memory != null && (allowExpired || memory.expiresAt.isAfter(now))) {
      final value = memory.value;
      if (value is T) return value;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(decoded['expireAt']?.toString() ?? '') ?? 0,
      );
      if (!allowExpired && !expiresAt.isAfter(now)) return null;
      final value = decoded['value'];
      _memoryCache[key] = _GameCacheEntry<Object?>(value, expiresAt);
      if (value is T) return value;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _writeCache(String key, Object? value, Duration ttl) async {
    final expiresAt = DateTime.now().add(ttl);
    _memoryCache[key] = _GameCacheEntry<Object?>(value, expiresAt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(<String, Object?>{
        'value': value,
        'expireAt': expiresAt.millisecondsSinceEpoch,
      }),
    );
  }
}

class _GameCacheEntry<T> {
  const _GameCacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;
}
