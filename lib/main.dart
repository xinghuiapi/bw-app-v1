import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'api/dio_client.dart';
import 'api/token_storage.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: const Locale('zh', 'CN'),
      child: const AppProviders(child: MyApp()),
    ),
  );
}

class AppProviders extends StatefulWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  State<AppProviders> createState() => _AppProvidersState();
}

class _AppProvidersState extends State<AppProviders> {
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late final GameProvider _gameProvider;
  late final FeedbackProvider _feedbackProvider;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _authProvider = AuthProvider(tokenStorage: _tokenStorage);
    _userProvider = UserProvider();
    _gameProvider = GameProvider();
    _feedbackProvider = FeedbackProvider();
    _dioClient = DioClient(
      tokenStorage: _tokenStorage,
      onAuthExpired: () async {
        await _authProvider.forceLogout();
        _userProvider.clearProfile();
      },
    );
    _authProvider.bindClient(_dioClient);
    _userProvider.bindClient(_dioClient);
    _gameProvider.bindClient(_dioClient);
    _feedbackProvider.bindClient(_dioClient);
    _authProvider.init().then((_) async {
      if (!_authProvider.isAuthenticated) return;
      await _userProvider.loadProfile();
      if (_userProvider.profile == null) {
        await _authProvider.forceLogout();
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _userProvider.dispose();
    _gameProvider.dispose();
    _feedbackProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => SystemProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider.value(value: _userProvider),
        ChangeNotifierProvider.value(value: _gameProvider),
        ChangeNotifierProvider.value(value: _feedbackProvider),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => RecordProvider()),
      ],
      child: widget.child,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemProvider = context.read<SystemProvider>();
      systemProvider.loadConfig().then((_) {
        if (!mounted || !kDebugMode) return;

        final title = systemProvider.config.siteConfig?.title ?? 'unknown';
        final languages = systemProvider.config.languages.length;
        final banners = systemProvider.config.banners.length;
        debugPrint(
          '[startup-probe] system config loaded: '
          'title=$title, languages=$languages, banners=$banners',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _router ??= createAppRouter(context.read<AuthProvider>());

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone X/11/12/13 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Flutter UI Conversion',
          theme: AppTheme.lightTheme,
          routerConfig: _router!,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  // Theme management logic here
}
