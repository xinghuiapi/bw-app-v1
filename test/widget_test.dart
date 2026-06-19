import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ui_project/api/api_exception.dart';
import 'package:flutter_ui_project/api/dio_client.dart';
import 'package:flutter_ui_project/api/interceptors/auth_interceptor.dart';
import 'package:flutter_ui_project/api/interceptors/error_interceptor.dart';
import 'package:flutter_ui_project/api/token_storage.dart';
import 'package:flutter_ui_project/config/api_endpoints.dart';
import 'package:flutter_ui_project/localization/app_language.dart';
import 'package:flutter_ui_project/models/auth/auth_models.dart';
import 'package:flutter_ui_project/models/home/home_models.dart';
import 'package:flutter_ui_project/models/game/game_models.dart';
import 'package:flutter_ui_project/providers/wallet/wallet_provider.dart';
import 'package:flutter_ui_project/screens/home_screen.dart';
import 'package:flutter_ui_project/models/wallet/wallet_models.dart';
import 'package:flutter_ui_project/router/route_paths.dart';
import 'package:flutter_ui_project/security/url_policy.dart';
import 'package:flutter_ui_project/services/wallet/wallet_service.dart';
import 'package:flutter_ui_project/theme/app_images.dart';
import 'package:flutter_ui_project/utils/site_display.dart';
import 'package:flutter_ui_project/utils/version_utils.dart';
import 'package:flutter_ui_project/widgets/common/back_hit_target.dart';
import 'package:flutter_ui_project/widgets/common/wallet_action_hit_target.dart';

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

  test('system config parses config_kefu customer service items', () {
    final config = HomeConfig.fromJson({
      'config_kefu': [
        {
          'title': '太阳城7✖️24小时客服',
          'link': ' https://support.example.com ',
          'icon': 'https://cdn.example.com/icon.png',
        },
        {
          'title': '',
          'link': '   ',
          'icon': '',
        },
      ],
    });

    expect(config.customerServiceItems.length, 1);
    expect(config.customerServiceItems.single.title, '太阳城7×24小时客服');
    expect(
      config.customerServiceItems.single.link,
      'https://support.example.com',
    );
    expect(
      config.customerServiceItems.single.icon,
      'https://cdn.example.com/icon.png',
    );
  });

  test('system config parses data_list inviteRule', () {
    final config = HomeConfig.fromJson({
      'data_list': [
        {'key': 'cardbagdelete', 'value': '0'},
        {'key': 'inviteRule', 'value': '申请规则 1.介绍好友充值达标。'},
        {'key': '', 'value': 'ignored'},
      ],
    });

    expect(config.dataList.length, 2);
    expect(config.systemDataValue('cardbagdelete'), '0');
    expect(config.inviteRule, '申请规则 1.介绍好友充值达标。');
    expect(config.systemDataValue('missing'), '');
  });

  test('site domain display does not show fake fallback before config loads',
      () {
    expect(siteDomainDisplayText(null), '');
    expect(siteDomainDisplayText(''), '');
    expect(siteDomainDisplayText('   '), '');
    expect(siteDomainDisplayText('0591.in'), '0591.in');
  });

  test('home runtime i18n does not expose Flutter demo fallback copy', () {
    final forbidden = RegExp(
      r'Flutter UI|基于 Flutter|極致效能|极致性能|multi-platform|高性能',
      caseSensitive: false,
    );
    final files = Directory('assets/i18n')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'));

    for (final file in files) {
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final home = data['home'] as Map<String, dynamic>;
      expect(
        home['fallbackNotice'],
        '',
        reason:
            '${file.path} home.fallbackNotice should not create empty-data UI',
      );
      for (final key in ['appTitle', 'appDescription', 'fallbackNotice']) {
        expect(
          home[key],
          isNot(matches(forbidden)),
          reason: '${file.path} home.$key should use business copy',
        );
      }
    }
  });

  test('remote display titles are preserved for localization-sensitive data',
      () {
    final depositCategory = DepositCategory.fromJson(
      const {'id': 1, 'title': '支付宝充值', 'code': 'alipay'},
    );
    final depositChannel = DepositChannel.fromJson(
      const {'id': 2, 'title': '微信扫码', 'type': 'wechat'},
    );
    final gameCategory = GameLobbyCategory.fromJson(
      const {'id': 3, 'title': '真人视讯', 'code': 'live'},
    );

    expect(depositCategory.displayTitle, '支付宝充值');
    expect(depositChannel.displayTitle, '微信扫码');
    expect(gameCategory.title, '真人视讯');
  });

  test('recharge detail type mappings match 517 m1 order detail', () {
    final detail = RechargeDetail.fromJson(
      const {
        'params': {
          'account': 'TKGbf8ABwgUj1sgoUecAoMffSGfEyXGT9d',
          'addres': 'TKGbf8ABwgUj1sgoUecAoMffSGfEyXGT9d',
        },
        'money': '100.0000',
        'hl': '6.811',
        'usdt_money': '14.6821',
        'img': '789.png',
        'currency': 'CNY',
        'type': 2,
        'status': 5,
      },
    );

    expect(detail.isAlipayRecharge, isTrue);
    expect(detail.isCryptoRecharge, isFalse);
    expect(RechargeDetail.fromJson(const {'type': 3}).isCryptoRecharge, isTrue);
    expect(RechargeDetail.fromJson(const {'type': 5}).isCryptoRecharge, isTrue);
    expect(RechargeDetail.fromJson(const {'type': 4}).isBankRecharge, isTrue);
  });

  test('receiving account type mappings match 517 m1 card list', () {
    expect(const WalletCard(id: 1, type: 1).isBankCard, isTrue);
    expect(const WalletCard(id: 2, type: 2).isCrypto, isTrue);
    expect(const WalletCard(id: 3, type: 3).isAlipay, isTrue);
  });

  test('payment urls allow third-party gateway hosts like m1', () {
    final uri = UrlPolicy.externalUri(
      'https://opkj2.m79j3ra1k64b.xyz/#/order?id=FO2605271939593311250',
      type: ExternalUrlType.payment,
    );

    expect(uri, isNotNull);
    expect(uri!.host, 'opkj2.m79j3ra1k64b.xyz');
  });

  test('payment urls do not restrict returned gateway schemes', () {
    final uri = UrlPolicy.externalUri(
      'alipay://platformapi/startapp?appId=20000067',
      type: ExternalUrlType.payment,
    );

    expect(uri, isNotNull);
    expect(uri!.scheme, 'alipay');
  });

  test('payment urls do not require gateway hosts', () {
    final uri = UrlPolicy.externalUri(
      'intent:#Intent;scheme=https;package=com.android.chrome;end',
      type: ExternalUrlType.payment,
    );

    expect(uri, isNotNull);
    expect(uri!.scheme, 'intent');
  });

  test('recharge proof success refreshes realtime wallet balance', () async {
    final service = _FakeWalletService(balanceAfterProof: 88.8);
    final provider = WalletProvider(service: service);

    await provider.submitRechargeProof(const RechargeProofRequest(id: 123));

    expect(service.submitRechargeProofCalls, 1);
    expect(service.fetchRealtimeBalanceCalls, 1);
    expect(provider.realtimeBalance?.balance, 88.8);
  });

  test('home category lookup returns null when remote category is absent', () {
    const categories = [
      GameLobbyCategory(id: 1, title: '真人视讯', code: 'live'),
    ];

    expect(homeCategoryOrNull(categories, 'live')?.title, '真人视讯');
    expect(homeCategoryOrNull(categories, 'lottery'), isNull);
  });

  testWidgets('home large category artwork shows the full asset',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: HomeLargeCategoryArtwork(
          image: AppImages.zr,
          height: 148,
          borderRadius: 16,
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.fit, BoxFit.contain);
  });

  testWidgets('back hit target keeps icon visual size but expands tap area',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: BackHitTarget(
            icon: Icons.arrow_back_ios_new,
            iconSize: 20,
            onTap: _noop,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BackHitTarget)), const Size(56, 56));
    expect(tester.widget<Icon>(find.byIcon(Icons.arrow_back_ios_new)).size, 20);
  });

  testWidgets('wallet action hit target fills wallet action row height',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 120,
            height: 48,
            child: WalletActionHitTarget(
              onTap: _noop,
              child: Text('充值'),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(WalletActionHitTarget)),
        const Size(120, 48));
  });

  testWidgets('home service shortcut switches to service tab', (tester) async {
    var currentIndex = 0;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            currentIndex = navigationShell.currentIndex;
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: Text('tab:$currentIndex'),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => TextButton(
                    onPressed: () => navigateToServiceTab(context),
                    child: const Text('service shortcut'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/service',
                  builder: (context, state) => const Text('service page'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('service shortcut'));
    await tester.pumpAndSettle();

    expect(find.text('service page'), findsOneWidget);
    expect(find.text('tab:1'), findsOneWidget);
  });

  test('version utils compare semver strings correctly', () {
    expect(VersionUtils.compare('1.0.1', '1.0.0'), greaterThan(0));
    expect(VersionUtils.compare('1.2.0', '1.10.0'), lessThan(0));
    expect(VersionUtils.compare('v1.2.3', '1.2.3'), 0);
    expect(VersionUtils.isRemoteNewer('1.2.4', '1.2.3'), isTrue);
    expect(VersionUtils.isRemoteNewer('1.2.3', '1.2.3'), isFalse);
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

void _noop() {}

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

class _FakeWalletService extends WalletService {
  _FakeWalletService({required this.balanceAfterProof})
      : super(DioClient(dio: Dio()));

  final double balanceAfterProof;
  int submitRechargeProofCalls = 0;
  int fetchRealtimeBalanceCalls = 0;

  @override
  Future<void> submitRechargeProof(RechargeProofRequest request) async {
    submitRechargeProofCalls++;
  }

  @override
  Future<UserRealtimeBalance> fetchRealtimeBalance() async {
    fetchRealtimeBalanceCalls++;
    return UserRealtimeBalance(balance: balanceAfterProof);
  }
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
