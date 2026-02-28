import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 MCP Toolkit
  try {
    MCPToolkitBinding.instance.initialize();
  } catch (e) {
    debugPrint('MCP Toolkit initialization failed: $e');
  }

  // 初始化语言配置
  final container = ProviderContainer();
  await container.read(languageProvider.notifier).init();

  // 1. 捕获 Flutter 框架异常 (如 Widget 构建错误)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('=== FLUTTER FRAMEWORK ERROR ===');
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack.toString());
    debugPrint('==============================');
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
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
