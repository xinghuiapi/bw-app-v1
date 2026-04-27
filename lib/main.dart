import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_flutter_app/router/app_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/system/language_provider.dart';
import 'package:my_flutter_app/providers/system/theme_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/gen/strings.g.dart';

import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/api/interceptors/error_interceptor.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('=== FLUTTER FRAMEWORK ERROR ===');
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack.toString());
    debugPrint('==============================');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Render Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                details.exception.toString(),
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SelectableText(
                details.stack.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== ASYNC ERROR ===');
    debugPrint(error.toString());
    debugPrint(stack.toString());
    debugPrint('===================');
    return true;
  };

  runApp(
    ProviderScope(
      child: TranslationProvider(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 借鉴参考代码：重定向锁，防止并发请求导致的多次跳转和弹窗
    bool isRedirecting = false;

    // 注册全局 401 登出回调
    ErrorInterceptor.onUnauthorized = () {
      if (mounted && !isRedirecting) {
        isRedirecting = true;
        
        try {
          // 检查当前是否已经在登录或注册页，避免死循环
          final currentPath = ref.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
          if (currentPath == '/login' || currentPath == '/register') {
            isRedirecting = false;
            return;
          }
        } catch (e) {
          debugPrint('Error getting current path: $e');
        }

        // 先清理状态
        ref.read(authProvider.notifier).forceLogout().then((_) {
          if (mounted) {
            ToastUtils.showError('登录已过期，请重新登录');
            // 跳转到登录页
            ref.read(routerProvider).go('/login');
          }
        }).catchError((e) {
          // 即使登出接口失败，也强制跳转
          if (mounted) {
            ref.read(routerProvider).go('/login');
          }
        }).whenComplete(() {
          // 800ms 后释放锁，允许下次可能的重定向 (对标参考代码)
          Future.delayed(const Duration(milliseconds: 800), () {
            isRedirecting = false;
          });
        });
      }
    };

    try {
      await Future.wait([
        ref.read(languageProvider.notifier).init(),
        ref.read(authProvider.notifier).init(),
        ref.read(themeProvider.notifier).init(),
      ]).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('App initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // 确保第一帧渲染完成后，再移除启动图
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 现在原生的启动图由 SplashScreen 去移除，这里不再全局移除
          // 移除 HTML 中自定义的 loading 元素
          // ignore: avoid_web_libraries_in_flutter
          // js.context.callMethod('removeLoading'); 
          // 实际上不需要调用 JS，因为 flutter_native_splash 自动移除了 id="splash"
          // 但是我们还有 loading-indicator，我们需要隐藏它。
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text('正在初始化...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: ToastUtils.messengerKey,
      title: 'Cloud Gaming',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      // 多语言配置
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.instance.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
