import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class LanguageStorage {
  const LanguageStorage();

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppLanguage.storageKey);
  }

  Future<void> write(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppLanguage.storageKey, AppLanguage.normalize(code));
  }
}
