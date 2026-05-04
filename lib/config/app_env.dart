enum AppEnvironment { development, staging, production }

class AppEnv {
  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static AppEnvironment get current => switch (_environment) {
        'production' || 'prod' => AppEnvironment.production,
        'staging' || 'test' => AppEnvironment.staging,
        _ => AppEnvironment.development,
      };

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apis.xh-demo.com/api',
  );

  static const String assetBaseUrl = String.fromEnvironment(
    'ASSET_BASE_URL',
    defaultValue: 'https://apis.xh-demo.com',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static bool get isProduction => current == AppEnvironment.production;
  static bool get enableNetworkLog => !isProduction;
}
