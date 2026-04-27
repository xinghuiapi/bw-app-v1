import 'package:flutter/material.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/router/app_router.dart';
import 'package:my_flutter_app/api/interceptors/error_interceptor.dart';

class ErrorStateWidget extends ConsumerWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onLogout;
  final bool isTokenExpired;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onLogout,
    this.isTokenExpired = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 检测是否为认证错误
    final RegExp authFailPattern = RegExp(
      r'token|登录|认证|鉴权|unauthorized|forbidden|未授权|过期',
      caseSensitive: false,
    );
    final bool isAuthError = authFailPattern.hasMatch(message);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '出现了一些问题',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            if (onRetry != null || isAuthError) ...[
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (onRetry != null)
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '点击重试',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (isAuthError)
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: onLogout ??
                            () {
                              if (ErrorInterceptor.onUnauthorized != null) {
                                ErrorInterceptor.onUnauthorized!();
                              } else {
                                ref.read(routerProvider).go('/login');
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '重新登录',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.message = '暂无数据',
    this.subMessage,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textTertiary, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({super.key, this.message = '正在加载...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class GlobalLoadingDialog extends StatelessWidget {
  final String message;

  const GlobalLoadingDialog({super.key, this.message = '正在加载...'});

  static void show(BuildContext context, {String message = '正在加载...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GlobalLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withAlpha(242),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.getDividerColor(context)),
            // Removed BoxShadow for web optimization
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
