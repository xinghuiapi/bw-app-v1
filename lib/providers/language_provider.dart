import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/gen/strings.g.dart';
import 'package:my_flutter_app/providers/home_provider.dart';

/// 扩展 AppLocale 以支持 API 所需的语言代码
extension AppLocaleApi on AppLocale {
  String get apiCode {
    return switch (this) {
      AppLocale.zh => 'CN',
      AppLocale.en => 'EN',
      AppLocale.pt => 'PT',
    };
  }
}

/// 语言 Provider，管理当前应用的语言设置
class LanguageNotifier extends Notifier<AppLocale> {
  static const String _storageKey = 'app-locale';

  @override
  AppLocale build() {
    // 默认语言为中文
    final defaultLocale = AppLocale.zh;
    // 异步加载初始化会在 main.dart 中调用 init()
    // 这里同步返回默认值，但可以先尝试同步更新系统设置
    _updateSystem(defaultLocale);
    return defaultLocale;
  }

  /// 初始化语言设置
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_storageKey);
    
    AppLocale locale = AppLocale.zh;
    if (savedLanguage != null) {
      // 尝试从保存的字符串恢复 AppLocale
      locale = AppLocale.values.firstWhere(
        (e) => e.languageCode == savedLanguage,
        orElse: () => AppLocale.zh,
      );
    }
    
    state = locale;
    _updateSystem(locale);
  }

  /// 切换语言
  Future<void> setLanguage(AppLocale locale) async {
    if (state == locale) return;
    
    state = locale;
    _updateSystem(locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);

    // 语言切换后，使相关 Provider 失效，触发重新请求带上新语言头
    ref.invalidate(homeDataProvider);
    // 如果有其他需要实时更新的 Provider 也可以在这里添加
  }

  /// 更新系统设置（Slang 状态和 API 拦截器）
  void _updateSystem(AppLocale locale) {
    // 1. 更新 Slang 全局状态
    LocaleSettings.setLocale(locale);
    
    // 2. 更新 API 拦截器中的语言头
    DioClient().authInterceptor.updateLanguage(locale.apiCode);
  }
}

final languageProvider = NotifierProvider.autoDispose<LanguageNotifier, AppLocale>(LanguageNotifier.new);
