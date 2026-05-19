import 'package:shared_preferences/shared_preferences.dart';

class RefCodeStorage {
  RefCodeStorage._();

  static const _storageKey = 'm1_refcode_cache';
  static const _expiresKey = 'm1_refcode_cache_exp';
  static const _ttl = Duration(days: 90);
  static const _queryKeys = <String>[
    'refcode',
    'ref_code',
    'invite',
    'invite_code',
    'invicode',
  ];

  static Future<bool> persistFromUri(Uri uri) {
    final code = _codeFromUri(uri);
    return write(code);
  }

  static Future<bool> persistFromQuery(Map<String, String> query) {
    final code = _codeFromQuery(query);
    return write(code);
  }

  static Future<bool> write(String? code) async {
    final value = code?.trim() ?? '';
    if (value.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value);
    await prefs.setInt(
      _expiresKey,
      DateTime.now().add(_ttl).millisecondsSinceEpoch,
    );
    return true;
  }

  static Future<String> read() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_storageKey)?.trim() ?? '';
    if (value.isEmpty) return '';

    final expiresAt = prefs.getInt(_expiresKey) ?? 0;
    if (expiresAt <= DateTime.now().millisecondsSinceEpoch) {
      await clear();
      return '';
    }
    return value;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_expiresKey);
  }

  static String _codeFromUri(Uri uri) {
    final direct = _codeFromQuery(uri.queryParameters);
    if (direct.isNotEmpty) return direct;

    final fragment = uri.fragment.trim();
    if (fragment.isEmpty) return '';
    final parsed =
        Uri.tryParse(fragment.startsWith('/') ? fragment : '/$fragment');
    if (parsed == null) return '';
    return _codeFromQuery(parsed.queryParameters);
  }

  static String _codeFromQuery(Map<String, String> query) {
    for (final key in _queryKeys) {
      final value = query[key]?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
