import 'package:shared_preferences/shared_preferences.dart';

import '../services/game/game_service.dart';
import '../services/system/system_config_cache.dart';

class StartupCacheSanitizer {
  const StartupCacheSanitizer();

  static const _gameCachePrefixes = <String>[
    'm1_cache_interface_class',
    'm1_cache_interface_list',
    'm1_cache_gamelist_hot',
  ];

  Future<void> clearLanguageSensitiveCaches() async {
    GameService.clearLanguageSensitiveMemoryCache();
    await const SystemConfigCache().clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(_isLanguageSensitiveKey).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  bool _isLanguageSensitiveKey(String key) {
    for (final prefix in _gameCachePrefixes) {
      if (key.startsWith(prefix)) return true;
    }
    return false;
  }
}
