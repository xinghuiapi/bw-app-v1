import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ui_project/api/api_exception.dart';
import 'package:flutter_ui_project/api/interceptors/auth_interceptor.dart';
import 'package:flutter_ui_project/api/interceptors/error_interceptor.dart';
import 'package:flutter_ui_project/api/token_storage.dart';
import 'package:flutter_ui_project/config/api_endpoints.dart';
import 'package:flutter_ui_project/localization/app_language.dart';
import 'package:flutter_ui_project/models/auth/auth_models.dart';
import 'package:flutter_ui_project/models/home/home_models.dart';
import 'package:flutter_ui_project/router/route_paths.dart';

void main() {
  test('engineering foundation exposes protected routes', () {
    expect(protectedRoutePaths, contains(RoutePaths.profile));
    expect(protectedRoutePaths, contains(RoutePaths.myWallet));
    expect(protectedRoutePaths, isNot(contains(RoutePaths.login)));
  });

  test('api exception keeps typed error information', () {
    const exception = ApiException(
      type: ApiExceptionType.business,
      message: 'Invalid request',
      businessCode: 40001,
    );

    expect(exception.type, ApiExceptionType.business);
    expect(exception.businessCode, 40001);
    expect(exception.isUnauthorized, isFalse);
  });

  test('code 0 is treated as business failure', () async {
    final dio = Dio()
      ..interceptors.add(ErrorInterceptor())
      ..httpClientAdapter = _StaticAdapter(
        ResponseBody.fromString(
          '{"code":0,"msg":"账号密码错误"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

    await expectLater(
      dio.get('/user/login'),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          'error',
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiExceptionType.business,
          ),
        ),
      ),
    );
  });

  test('public auth api business errors do not trigger auth expiry', () async {
    var authExpiredCalled = false;
    final dio = Dio()
      ..interceptors.add(
        AuthInterceptor(
          tokenStorage: _FakeTokenStorage(),
          onAuthExpired: () async => authExpiredCalled = true,
        ),
      )
      ..interceptors.add(ErrorInterceptor())
      ..httpClientAdapter = _StaticAdapter(
        ResponseBody.fromString(
          '{"code":0,"msg":"请先登录后再获取验证码"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

    await expectLater(
      dio.post(ApiEndpoints.phoneCode),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          'error',
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiExceptionType.business,
          ),
        ),
      ),
    );
    expect(authExpiredCalled, isFalse);
  });

  test('auth interceptor adds default lang query', () async {
    final interceptor = AuthInterceptor(tokenStorage: _FakeTokenStorage());
    final options = RequestOptions(path: '/user/login');

    await interceptor.onRequest(
      options,
      _RequestHandler((nextOptions) {
        expect(nextOptions.headers['lang'], ApiRequestDefaults.lang);
        expect(nextOptions.queryParameters['lang'], ApiRequestDefaults.lang);
      }),
    );
  });

  test('language normalizer maps locale aliases to m1 codes', () {
    expect(AppLanguage.normalize('zh-CN'), 'CN');
    expect(AppLanguage.normalize('zh-HK'), 'TW');
    expect(AppLanguage.normalize('en-US'), 'EN');
    expect(AppLanguage.normalize('ja-JP'), 'JP');
    expect(AppLanguage.normalize('ko-KR'), 'KR');
    expect(AppLanguage.normalize('th-TH'), 'TH');
    expect(AppLanguage.normalize('vi-VN'), 'VN');
    expect(AppLanguage.normalize(null), 'CN');
  });

  test('auth interceptor uses dynamic language', () async {
    final interceptor = AuthInterceptor(
      tokenStorage: _FakeTokenStorage(),
      currentLanguage: () => 'EN',
    );
    final options = RequestOptions(path: '/user/login');

    await interceptor.onRequest(
      options,
      _RequestHandler((nextOptions) {
        expect(nextOptions.headers['lang'], 'EN');
        expect(nextOptions.queryParameters['lang'], 'EN');
      }),
    );
  });

  test('auth interceptor normalizes dynamic language headers', () async {
    final interceptor = AuthInterceptor(
      tokenStorage: _FakeTokenStorage(),
      currentLanguage: () => 'zh-TW',
    );
    final options = RequestOptions(path: '/user/login');

    await interceptor.onRequest(
      options,
      _RequestHandler((nextOptions) {
        expect(nextOptions.headers['lang'], 'TW');
        expect(nextOptions.queryParameters['lang'], 'TW');
      }),
    );
  });

  test('system config parses documented nested payload', () {
    final payload = <String, dynamic>{
      'data': <String, dynamic>{
        'config_site': <String, dynamic>{
          'title': '星汇演示11',
          'logo': 'https://apis.xh-demo.com/uploads/images/logo/logo.png',
        },
        'config_lang': <Map<String, dynamic>>[
          <String, dynamic>{'code': 'CN', 'title': '中文简体', 'status_s': 1},
        ],
        'config_curr': <Map<String, dynamic>>[
          <String, dynamic>{'code': 'CNY', 'title': '人民币', 'symbol': '￥'},
        ],
      },
    };

    final config = HomeConfig.fromJson(
      Map<String, dynamic>.from(payload['data']! as Map),
    );

    expect(config.siteConfig?.title, '星汇演示11');
    expect(config.languages.single.code, 'CN');
    expect(config.languages.single.title, '中文简体');
    expect(config.currencies.single.symbol, '￥');
  });

  test('system config endpoint skips lang query injection', () async {
    final interceptor = AuthInterceptor(tokenStorage: _FakeTokenStorage());
    final options = RequestOptions(path: ApiEndpoints.systemConfig);

    await interceptor.onRequest(
      options,
      _RequestHandler((nextOptions) {
        expect(nextOptions.headers['lang'], ApiRequestDefaults.lang);
        expect(nextOptions.queryParameters.containsKey('lang'), isFalse);
      }),
    );
  });

  test('login request serializes dynamic login types', () {
    final usernameLogin = const LoginRequest(
      type: 1,
      username: 'demo',
      password: 'secret',
      captchaCode: 'abcd',
      captchaKey: 'captcha-key',
    ).toJson();
    final phoneLogin = const LoginRequest(
      type: 3,
      username: '13100000000',
      phone: '13100000000',
      areaCode: '+86',
      phoneCode: '123456',
    ).toJson();
    final emailLogin = const LoginRequest(
      type: 2,
      username: 'demo@example.com',
      email: 'demo@example.com',
      emailCode: '654321',
    ).toJson();

    expect(usernameLogin['type'], 1);
    expect(usernameLogin['password'], 'secret');
    expect(usernameLogin['captcha_key'], 'captcha-key');
    expect(phoneLogin['type'], 3);
    expect(phoneLogin['area_code'], '+86');
    expect(phoneLogin['phone_code'], '123456');
    expect(emailLogin['type'], 2);
    expect(emailLogin['email_code'], '654321');
  });

  test('home config controls dynamic login availability', () {
    final config = HomeConfig.fromJson(<String, dynamic>{
      'config_send': <String, dynamic>{'login_status': 1},
      'config_mail': <String, dynamic>{'login_status': 1},
      'config_pic': <String, dynamic>{'login_status': 1},
    });

    expect(config.smsConfig?.loginStatus, 1);
    expect(config.mailConfig?.loginStatus, 1);
    expect(config.captchaConfig?.loginStatus, 1);
  });
}

class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.responseBody);

  final ResponseBody responseBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return responseBody;
  }

  @override
  void close({bool force = false}) {}
}

class _FakeTokenStorage implements TokenStorageContract {
  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<String?> readTokenType() async => null;

  @override
  Future<String?> readExpiresIn() async => null;

  @override
  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) async {}

  @override
  Future<void> clear() async {}
}

class _RequestHandler extends RequestInterceptorHandler {
  _RequestHandler(this.onNext);

  final void Function(RequestOptions options) onNext;

  @override
  void next(RequestOptions requestOptions) {
    onNext(requestOptions);
  }
}
