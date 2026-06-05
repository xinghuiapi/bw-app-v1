import 'package:flutter_ui_project/config/app_env.dart';

void main() {
  print(
    [
      '--dart-define=APP_ENV=production',
      '--dart-define=API_BASE_URL=${AppEnv.baseUrl}',
      '--dart-define=ASSET_BASE_URL=${AppEnv.assetBaseUrl}',
    ].join(' '),
  );
}
