import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/gen/strings.g.dart';
import 'package:my_flutter_app/providers/home/home_provider.dart';

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
    // 强制使用中文，屏蔽多语言切换功能
    // 注意：不要在 build 中直接执行 side effects (如 _updateSystem)
    // 以免触发 "Tried to modify a provider while the widget tree was building" 错误
    return AppLocale.zh;
  }

  /// 初始化语言设置
  Future<void> init() async {
    // 强制重置为中文
    const locale = AppLocale.zh;
    _updateSystem(locale);
    // 使用 Future.microtask 避免 "Tried to modify a provider while the widget tree was building"
    Future.microtask(() {
      state = locale;
    });
  }

  /// 切换语言
  Future<void> setLanguage(AppLocale locale) async {
    // 功能已屏蔽，不再执行切换逻辑
    return;
  }

  /// 更新系统设置（Slang 状态和 API 拦截器）
  void _updateSystem(AppLocale locale) {
    // 1. 更新 Slang 全局状态
    LocaleSettings.setLocale(locale);

    // 2. 更新 API 拦截器中的语言头
    DioClient().authInterceptor.updateLanguage(locale.apiCode);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, AppLocale>(
      LanguageNotifier.new,
    );
