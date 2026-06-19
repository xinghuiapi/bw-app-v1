import 'dart:async';

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
import 'localization/language_storage.dart';
import 'localization/startup_cache_sanitizer.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'widgets/common/app_loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const languageStorage = LanguageStorage();
  await languageStorage.clearLegacyEasyLocalizationLocale();
  await const StartupCacheSanitizer().clearLanguageSensitiveCaches();
  await EasyLocalization.ensureInitialized();
  final initialLanguageCode = AppLanguage.normalize(
    await languageStorage.read(),
  );
  final initialLocale = AppLanguage.toLocale(initialLanguageCode);

  runApp(
    EasyLocalization(
      supportedLocales: AppLanguage.supportedLocales,
      path: 'assets/i18n',
      assetLoader: const FallbackAssetLoader(),
      fallbackLocale: const Locale('zh', 'CN'),
      startLocale: initialLocale,
      saveLocale: false,
      child: AppProviders(
        initialLanguageCode: initialLanguageCode,
        child: const MyApp(),
      ),
    ),
  );
}

class AppProviders extends StatefulWidget {
  const AppProviders({
    super.key,
    required this.child,
    required this.initialLanguageCode,
  });

  final Widget child;
  final String initialLanguageCode;

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
    _languageProvider = LanguageProvider(
      initialCode: widget.initialLanguageCode,
    );
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
    _activityProvider.bindLanguageGetter(() => _languageProvider.currentCode);
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
        return;
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
        Provider<DioClient>.value(value: _dioClient),
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
      child: AccountAutoRefreshScope(child: widget.child),
    );
  }
}

class AccountAutoRefreshScope extends StatefulWidget {
  const AccountAutoRefreshScope({super.key, required this.child});

  final Widget child;

  @override
  State<AccountAutoRefreshScope> createState() =>
      _AccountAutoRefreshScopeState();
}

class _AccountAutoRefreshScopeState extends State<AccountAutoRefreshScope>
    with WidgetsBindingObserver {
  static const _refreshInterval = Duration(seconds: 15);
  static const _refreshTimeout = Duration(seconds: 12);

  Timer? _timer;
  bool _isRefreshing = false;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncTimer();
    });
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _syncTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncTimer();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncTimer();
    });
  }

  void _syncTimer() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      _stopTimer();
      return;
    }
    if (_isStarted) return;
    _isStarted = true;
    if (kDebugMode) {
      debugPrint('[account-auto-refresh] started every 15s');
    }
    _runRefreshCycle();
  }

  void _stopTimer() {
    final timer = _timer;
    timer?.cancel();
    _timer = null;
    final wasStarted = _isStarted;
    _isStarted = false;
    if ((timer != null || wasStarted) && kDebugMode) {
      debugPrint('[account-auto-refresh] stopped');
    }
  }

  Future<void> _runRefreshCycle() async {
    _timer?.cancel();
    _timer = null;
    await _refreshNow();
    if (!mounted || !_isStarted) return;
    if (!context.read<AuthProvider>().isAuthenticated) {
      _stopTimer();
      return;
    }
    _timer = Timer(_refreshInterval, _runRefreshCycle);
    if (kDebugMode) {
      debugPrint('[account-auto-refresh] next tick in 15s');
    }
  }

  Future<void> _refreshNow() async {
    if (_isRefreshing) {
      if (kDebugMode) {
        debugPrint(
            '[account-auto-refresh] skipped: previous tick still running');
      }
      return;
    }
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      _stopTimer();
      return;
    }
    final userProvider = context.read<UserProvider>();
    final walletProvider = context.read<WalletProvider>();
    _isRefreshing = true;
    if (kDebugMode) {
      debugPrint('[account-auto-refresh] tick');
    }
    try {
      await Future.wait<void>([
        userProvider.loadProfile(refresh: true).catchError((_) {}),
        walletProvider.loadRealtimeBalance(refresh: true).catchError((_) {}),
        walletProvider.loadVenueBalances(refresh: true).catchError((_) {}),
        userProvider.loadDayRevenue(refresh: true).catchError((_) {}),
      ]).timeout(_refreshTimeout);
      if (kDebugMode) {
        debugPrint('[account-auto-refresh] done');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('[account-auto-refresh] timeout after 12s');
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (isAuthenticated) {
        _syncTimer();
      } else {
        _stopTimer();
      }
    });
    return widget.child;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _startupRetryDelay = Duration(seconds: 2);

  GoRouter? _router;
  bool _isBootstrapping = false;
  bool _isStartupReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrapStartupConfig();
    });
  }

  Future<void> _bootstrapStartupConfig() async {
    if (_isBootstrapping) return;
    _isBootstrapping = true;

    try {
      await _syncStoredLocale();
      if (!mounted) return;

      final systemProvider = context.read<SystemProvider>();
      _resetLanguageSensitiveProviders();

      while (mounted && !systemProvider.hasRemoteConfig) {
        await systemProvider.loadConfig(refresh: true);
        if (!mounted || systemProvider.hasRemoteConfig) break;
        await Future<void>.delayed(_startupRetryDelay);
      }

      if (!mounted) return;
      setState(() => _isStartupReady = systemProvider.hasRemoteConfig);

      if (!kDebugMode) return;

      final title = systemProvider.config.siteConfig?.title ?? 'unknown';
      final languages = systemProvider.config.languages.length;
      final banners = systemProvider.config.banners.length;
      debugPrint(
        '[startup-probe] system config loaded: '
        'title=$title, languages=$languages, banners=$banners',
      );
    } finally {
      _isBootstrapping = false;
    }
  }

  Future<void> _syncStoredLocale() async {
    final languageProvider = context.read<LanguageProvider>();
    if (!languageProvider.initialized) {
      await languageProvider.init();
    }
    if (!mounted) return;
    await context.setLocale(AppLanguage.toLocale(languageProvider.currentCode));
  }

  void _resetLanguageSensitiveProviders() {
    context.read<DioClient>().clearMemoryCache();
    context.read<SystemProvider>().resetForLanguageChange();
    context.read<GameProvider>().resetForLanguageChange();
    context.read<GameManagementProvider>().resetForLanguageChange();
    context.read<WalletProvider>().resetForLanguageChange();
    context.read<RecordProvider>().resetForLanguageChange();
    context.read<ActivityProvider>().resetForLanguageChange();
    context.read<FeedbackProvider>().resetForLanguageChange();
    context.read<MessageProvider>().resetForLanguageChange();
    context.read<UserProvider>().resetForLanguageChange();
  }

  @override
  Widget build(BuildContext context) {
    final systemProvider = context.watch<SystemProvider>();
    final isStartupReady = _isStartupReady && systemProvider.hasRemoteConfig;
    if (isStartupReady) {
      _router ??= createAppRouter(
        context.read<AuthProvider>(),
        systemProvider: context.read<SystemProvider>(),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone X/11/12/13 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        if (!isStartupReady) {
          return MaterialApp(
            title: '开云体育',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const _StartupLoadingScreen(),
          );
        }

        return MaterialApp.router(
          title: '开云体育',
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

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: AppLoading(message: 'common.loading'.tr()),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  // Theme management logic here
}
