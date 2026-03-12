import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/telegram_login_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/gen/strings.g.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TelegramLoginScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? username;

  const TelegramLoginScreen({
    super.key,
    this.userId,
    this.username,
  });

  @override
  ConsumerState<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends ConsumerState<TelegramLoginScreen> {
  @override
  void initState() {
    super.initState();
    // 页面初始化后立即触发登录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLogin();
    });
  }

  void _handleLogin() async {
    final userId = widget.userId;
    final username = widget.username;

    if (userId == null || username == null || userId.isEmpty || username.isEmpty) {
      context.go('/home');
      return;
    }

    await ref.read(telegramLoginProvider.notifier).login(userId, username);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(telegramLoginProvider);

    // 监听状态变化以进行导航或显示 Toast
    ref.listen<TelegramLoginState>(telegramLoginProvider, (previous, next) {
      if (next.step == TelegramLoginStep.success) {
        if (next.isFirstLogin) {
          ToastUtils.showSuccess(t.telegramLogin.passwordSetDefault(password: '123456'));
        }
        context.go('/home');
      } else if (next.step == TelegramLoginStep.failed) {
        ToastUtils.showError(next.error ?? t.common.error.unknown);
        context.go('/home');
      }
    });

    String loadingText = '';
    switch (state.step) {
      case TelegramLoginStep.loggingIn:
        loadingText = state.isFirstLogin 
          ? t.telegramLogin.firstLoginProcessing 
          : t.telegramLogin.secureLoginProcessing;
        break;
      case TelegramLoginStep.settingPassword:
        loadingText = t.telegramLogin.firstLoginProcessing;
        break;
      case TelegramLoginStep.fetchingUserInfo:
        loadingText = t.telegramLogin.secureLoginProcessing;
        break;
      default:
        loadingText = t.telegramLogin.secureLoginProcessing;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitRing(
              color: Color(0xFFFF4D4F),
              size: 36.0,
              lineWidth: 3.0,
            ),
            const SizedBox(height: 16),
            Text(
              loadingText,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
