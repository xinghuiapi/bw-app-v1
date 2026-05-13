import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_language.dart';
import '../../models/home/home_models.dart';

class SystemConfigCache {
  static const _cacheKey = 'system_config_cache';

  const SystemConfigCache();

  Future<HomeConfig?> read(
      {String languageCode = AppLanguage.fallbackCode}) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyFor(languageCode));
    if (value == null || value.isEmpty) return null;

    final decoded = jsonDecode(value);
    if (decoded is! Map) return null;
    return HomeConfig.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> write(
    HomeConfig config, {
    String languageCode = AppLanguage.fallbackCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(languageCode), jsonEncode(config.toJson()));
  }

  Future<void> clear({String? languageCode}) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode != null) {
      await prefs.remove(_keyFor(languageCode));
      return;
    }
    await prefs.remove(_cacheKey);
    for (final code in AppLanguage.supportedCodes) {
      await prefs.remove(_keyFor(code));
    }
  }

  String _keyFor(String languageCode) {
    final code = AppLanguage.normalize(languageCode);
    return '${_cacheKey}_$code';
  }
}
