class AppConstants {
  // API 相关配置
  // static const String devBaseUrl = "https://229382.xh-bw.com";
  // static const String devBaseUrl = "https://apis.xh-demo.com";
  static const String devBaseUrl = "https://147258.xh-bw.com";
    // static const String devBaseUrl = "https://uu8com.xh-bw.com";
  static const String devApiPrefix = "/api";
  static const String apiBaseUrl = "$devBaseUrl$devApiPrefix";

  // 图片、资源相关配置
  static const String resourceBaseUrl = devBaseUrl;
  static const String localLogoPath = 'assets/images/logo.png';

  // 样式、UI 相关常量
  static const double horizontalPadding = 20.0;
  static const double borderRadius = 12.0;

  // 缓存、本地存储相关键名
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_info';
  static const String themeKey = 'theme_mode';
}
