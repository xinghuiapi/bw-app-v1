import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'api/dio_client.dart';
import 'api/token_storage.dart';
import 'localization/app_language.dart';
import 'localization/fallback_asset_loader.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: AppLanguage.supportedLocales,
      path: 'assets/i18n',
      assetLoader: const FallbackAssetLoader(),
      fallbackLocale: const Locale('zh', 'CN'),
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
  late final LanguageProvider _languageProvider;
  late final UserProvider _userProvider;
  late final SystemProvider _systemProvider;
  late final GameProvider _gameProvider;
  late final FloatingGameProvider _floatingGameProvider;
  late final GameManagementProvider _gameManagementProvider;
  late final ActivityProvider _activityProvider;
  late final FeedbackProvider _feedbackProvider;
  late final MessageProvider _messageProvider;
  late final RecordProvider _recordProvider;
  late final WalletProvider _walletProvider;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _languageProvider = LanguageProvider();
    _authProvider = AuthProvider(tokenStorage: _tokenStorage);
    _systemProvider = SystemProvider();
    _userProvider = UserProvider();
    _gameProvider = GameProvider();
    _floatingGameProvider = FloatingGameProvider();
    _gameManagementProvider = GameManagementProvider();
    _activityProvider = ActivityProvider();
    _feedbackProvider = FeedbackProvider();
    _messageProvider = MessageProvider();
    _recordProvider = RecordProvider();
    _walletProvider = WalletProvider();
    _dioClient = DioClient(
      tokenStorage: _tokenStorage,
      currentLanguage: () => _languageProvider.currentCode,
      onAuthExpired: () async {
        await _authProvider.forceLogout();
        _userProvider.clearProfile();
      },
    );
    _authProvider.bindClient(_dioClient);
    _systemProvider.bindClient(_dioClient);
    _systemProvider.bindLanguageGetter(() => _languageProvider.currentCode);
    _userProvider.bindClient(_dioClient);
    _gameProvider.bindClient(_dioClient);
    _gameManagementProvider.bindClient(_dioClient);
    _activityProvider.bindClient(_dioClient);
    _feedbackProvider.bindClient(_dioClient);
    _messageProvider.bindClient(_dioClient);
    _recordProvider.bindClient(_dioClient);
    _walletProvider.bindClient(_dioClient);
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
    _floatingGameProvider.dispose();
    _gameManagementProvider.dispose();
    _feedbackProvider.dispose();
    _recordProvider.dispose();
    _walletProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _languageProvider),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _systemProvider),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider.value(value: _userProvider),
        ChangeNotifierProvider.value(value: _gameProvider),
        ChangeNotifierProvider.value(value: _floatingGameProvider),
        ChangeNotifierProvider.value(value: _gameManagementProvider),
        ChangeNotifierProvider.value(value: _feedbackProvider),
        ChangeNotifierProvider.value(value: _walletProvider),
        ChangeNotifierProvider.value(value: _activityProvider),
        ChangeNotifierProvider.value(value: _messageProvider),
        ChangeNotifierProvider.value(value: _recordProvider),
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
      if (!mounted) return;
      _syncStoredLocale();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemProvider = context.read<SystemProvider>();
      final languageProvider = context.read<LanguageProvider>();
      systemProvider.loadConfig().then((_) {
        if (!mounted) return;

        languageProvider
            .applyBackendDefault(systemProvider.config.languages)
            .then((changed) async {
          if (!mounted) return;
          await context.setLocale(
            AppLanguage.toLocale(languageProvider.currentCode),
          );
          if (changed) systemProvider.loadConfig(refresh: true);
        }).catchError((_) {});

        if (!kDebugMode) return;

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

  Future<void> _syncStoredLocale() async {
    final languageProvider = context.read<LanguageProvider>();
    if (!languageProvider.initialized) {
      await languageProvider.init();
    }
    if (!mounted) return;
    await context.setLocale(AppLanguage.toLocale(languageProvider.currentCode));
  }

  @override
  Widget build(BuildContext context) {
    _router ??= createAppRouter(
      context.read<AuthProvider>(),
      systemProvider: context.read<SystemProvider>(),
    );

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
