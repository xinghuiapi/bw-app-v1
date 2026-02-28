import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 MCP Toolkit (暂时注释以排除干扰)
  // try {
  //   MCPToolkitBinding.instance.initialize();
  // } catch (e) {
  //   debugPrint('MCP Toolkit initialization failed: $e');
  // }

  // 1. 捕获 Flutter 框架异常 (如 Widget 构建错误)
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
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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

  // 2. 捕获异步异常 (如 Future 报错)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== ASYNC ERROR ===');
    debugPrint(error.toString());
    debugPrint(stack.toString());
    debugPrint('===================');
    return true;
  };

  runApp(
    const ProviderScope(
      child: MyApp(),
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
    // 异步初始化逻辑
    try {
      // 可以在这里并行执行多个初始化任务
      // 增加超时保护，防止某个初始化任务永久挂起
      await Future.wait([
        ref.read(languageProvider.notifier).init(),
        // 如果有其他初始化任务，也可以加在这里
      ]).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('App initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // 移除 Web 端的加载动画
        // 注意：这里需要导入 'dart:html' 或使用 universal_html，或者简单地留给 flutter_bootstrap.js 去处理
        // flutter_bootstrap.js 通常会自动移除加载脚本，但如果我们自定义了 HTML loading，最好手动移除或让其自动消失
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果未初始化完成，显示 Flutter 端的 Loading 页面
    // 这样用户会先看到 index.html 的 loading，然后平滑过渡到这个 loading（或者直接进入首页）
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black, // 与 index.html 背景色一致
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
      title: 'Cloud Gaming',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
