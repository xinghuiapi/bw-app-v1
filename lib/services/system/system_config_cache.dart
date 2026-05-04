import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/home/home_models.dart';

class SystemConfigCache {
  static const _cacheKey = 'system_config_cache';

  const SystemConfigCache();

  Future<HomeConfig?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cacheKey);
    if (value == null || value.isEmpty) return null;

    final decoded = jsonDecode(value);
    if (decoded is! Map) return null;
    return HomeConfig.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> write(HomeConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(config.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
