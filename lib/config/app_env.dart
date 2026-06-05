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
    // defaultValue: 'https://api.0591.ceo/api',//太阳城
    // defaultValue: 'https://229382.xh-bw.com/api', //云鼎国际
    // defaultValue: 'https://464898.xh-bw.com/api', //新U娱乐
    // defaultValue: 'https://js4197.xh-bw.com/api', //澳门金沙
    // defaultValue: 'https://007007.xh-bw.com/api', //玖玖娱乐
   //defaultValue: 'https://akk112255.xh-bw.com/api', //超星体育
   defaultValue: 'https://api.myanmarn.xyz/api', //MYANMAR

  );

  static const String assetBaseUrl = String.fromEnvironment(
    'ASSET_BASE_URL',
    // defaultValue: 'https://api.0591.ceo',//太阳城
    // defaultValue: 'https://229382.xh-bw.com',//云鼎国际
    // defaultValue: 'https://464898.xh-bw.com',//新U娱乐
    // defaultValue: 'https://js4197.xh-bw.com',//澳门金沙
    // defaultValue: 'https://007007.xh-bw.com',//玖玖娱乐
    //defaultValue: 'https://akk112255.xh-bw.com',//超星体育
      defaultValue: 'https://api.myanmarn.xyz',//MYANMAR
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static bool get isProduction => current == AppEnvironment.production;
  static bool get enableNetworkLog => !isProduction;
}
