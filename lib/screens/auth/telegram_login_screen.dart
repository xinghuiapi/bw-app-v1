import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/auth/auth_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/user/user_provider.dart';

class TelegramLoginScreen extends StatefulWidget {
  const TelegramLoginScreen({super.key});

  @override
  State<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen> {
  bool _isFirstLogin = false;
  bool _didStart = false;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didStart) return;
      _didStart = true;
      _handleLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36.w,
                height: 36.w,
                child: const CircularProgressIndicator(
                  color: Color(0xFFFF4D4F),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _tgText(
                  _isFirstLogin ? 'firstLoading' : 'secureLoading',
                  _isFirstLogin ? '首次登录处理中...' : '安全登录中...',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final uri = GoRouterState.of(context).uri;
    final userId = uri.queryParameters['user_id']?.trim() ?? '';
    final username = uri.queryParameters['username']?.trim() ?? '';
    final redirect = _redirectTarget(uri.queryParameters['redirect']);

    if (userId.isEmpty || username.isEmpty) {
      _showMessage(_tgText('missingParams', 'Telegram 登录参数缺失'));
      await _delayedGo(redirect, milliseconds: 1500);
      return;
    }

    try {
      final token = await context.read<AuthProvider>().telegramLogin(
            TelegramLoginRequest(userId: userId, username: username),
          );
      if (!mounted) return;
      final oneLogin = token?.oneLogin == true || token?.isOneLogin == true;
      if (oneLogin) {
        setState(() => _isFirstLogin = true);
        await _setDefaultPassword(redirect);
        return;
      }
      _showMessage(_tgText('success', 'Telegram 登录成功'));
      unawaited(_loadProfile());
      _goAfterLogin(redirect);
    } catch (_) {
      if (!mounted) return;
      final message = context.read<AuthProvider>().error;
      _showMessage(message?.trim().isNotEmpty == true
          ? message!.trim()
          : _tgText('retryLater', '登录失败，请稍后重试'));
      await _delayedGo(redirect, milliseconds: 1500);
    }
  }

  Future<void> _setDefaultPassword(String redirect) async {
    try {
      await context.read<AuthProvider>().setTelegramPassword(
            const SetTelegramPasswordRequest(
              newPassword: '123456',
              confirmPassword: '123456',
            ),
          );
      if (!mounted) return;
      _showMessage(_tgText('setDefaultPassSuccess', '默认密码设置成功'));
      unawaited(_loadProfile());
      _goAfterLogin(redirect);
    } catch (_) {
      if (!mounted) return;
      final message = context.read<AuthProvider>().error;
      _showMessage(message?.trim().isNotEmpty == true
          ? message!.trim()
          : _tgText('setPassFailed', '密码设置失败'));
      _goAfterLogin(redirect);
    }
  }

  Future<void> _loadProfile() async {
    await context
        .read<UserProvider>()
        .loadProfile(refresh: true)
        .catchError((_) {});
  }

  String _redirectTarget(String? raw) {
    final value = raw?.trim() ?? '';
    if (!value.startsWith('/')) return '/';

    final parsed = Uri.tryParse(value);
    if (parsed == null) return '/';

    if (parsed.path == '/telegram-login') {
      return _redirectTarget(parsed.queryParameters['redirect']);
    }

    final cleanQuery = Map<String, String>.from(parsed.queryParameters)
      ..remove('user_id')
      ..remove('username')
      ..remove('redirect');

    return Uri(
      path: parsed.path.isEmpty ? '/' : parsed.path,
      queryParameters: cleanQuery.isEmpty ? null : cleanQuery,
      fragment: parsed.fragment.isEmpty ? null : parsed.fragment,
    ).toString();
  }

  Future<void> _delayedGo(String redirect, {required int milliseconds}) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
    if (!mounted) return;
    _goAfterLogin(redirect);
  }

  void _goAfterLogin(String redirect) {
    if (!mounted || _didNavigate) return;
    final target = redirect.isEmpty ? '/' : redirect;
    if (kDebugMode) {
      debugPrint('[telegram-login] redirect to $target');
    }
    _didNavigate = true;
    final router = GoRouter.of(context);
    router.replace(target);
    Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final current = GoRouterState.of(context).uri.path;
      if (current == '/telegram-login') router.replace(target);
    });
  }

  void _showMessage(String message) {
    if (!mounted || message.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.trim())),
    );
  }

  String _tgText(String key, String fallback) {
    final localeKey = 'auth.telegramLogin.$key';
    final value = localeKey.tr();
    return value == localeKey ? fallback : value;
  }
}
