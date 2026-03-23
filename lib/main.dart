import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_flutter_app/router/app_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/language_provider.dart';
import 'package:my_flutter_app/providers/theme_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/gen/strings.g.dart';

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
    try {
      await Future.wait([
        ref.read(languageProvider.notifier).init(),
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
          FlutterNativeSplash.remove();
          
          // 同时也移除 HTML 中自定义的 loading 元素
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

    return MaterialApp.router(
      scaffoldMessengerKey: ToastUtils.messengerKey,
      title: 'Cloud Gaming',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      // 多语言配置
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.instance.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
