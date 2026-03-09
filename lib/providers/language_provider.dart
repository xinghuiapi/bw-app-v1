import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api/dio_client.dart';

/// 语言 Provider，管理当前应用的语言代码 (如 'CN', 'EN' 等)
class LanguageNotifier extends Notifier<String> {
  static const String _storageKey = 'app-locale';

  @override
  String build() {
    // 默认语言为 'CN'
    // 注意：Notifier.build 应该是同步的，持久化数据的读取通常在初始化时完成或使用单独的 FutureProvider
    // 为了简单起见，我们这里先返回默认值，后续通过初始化逻辑更新
    return 'CN';
  }

  /// 初始化语言设置
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_storageKey);
    if (savedLanguage != null) {
      state = savedLanguage;
      DioClient().authInterceptor.updateLanguage(savedLanguage);
    }
  }

  /// 切换语言
  Future<void> setLanguage(String langCode) async {
    if (state == langCode) return;
    
    state = langCode;
    DioClient().authInterceptor.updateLanguage(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, langCode);
  }
}

final languageProvider = NotifierProvider.autoDispose<LanguageNotifier, String>(LanguageNotifier.new);
