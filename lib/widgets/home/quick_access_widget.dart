import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/providers/home/home_provider.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';

class QuickAccess extends ConsumerWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userState = ref.watch(userProvider);
    final user = userState.user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getDividerColor(context),
          width: 0.5,
        ),
      ),
      child: authState.isLoggedIn
          ? (userState.isLoading && user == null
                ? const _QuickAccessSkeleton()
                : _buildLoggedIn(context, ref, user, userState))
          : _buildLoggedOut(context, ref),
    );
  }

  Widget _buildLoggedOut(BuildContext context, WidgetRef ref) {
    final homeDataState = ref.watch(homeDataProvider);
    final domain = homeDataState.value?.siteConfig?.domain ?? 'xh-bet.com';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '下午好',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildButton(
                  '注册',
                  AppTheme.getInputFillColor(context),
                  AppTheme.getTextPrimary(context),
                  () {
                    context.push('/register');
                  },
                ),
                const SizedBox(width: 8),
                _buildButton('登录', AppTheme.primary, Colors.white, () {
                  context.push('/login');
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.getDividerColor(context).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: AppTheme.getTertiaryTextColor(context),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '官方域名',
                style: TextStyle(
                  color: AppTheme.getTertiaryTextColor(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                domain.isNotEmpty ? domain : 'xh-bet.com',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedIn(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    UserState userState,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.username ?? '...',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primary.withAlpha(76),
                        ),
                      ),
                      child: const Text(
                        '主钱包',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          ref.read(userProvider.notifier).refreshBalance(),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: userState.isBalanceLoading
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.getTertiaryTextColor(context),
                              )
                            : Icon(
                                Icons.refresh,
                                color: AppTheme.getTertiaryTextColor(context),
                                size: 16,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '¥ ${user?.balance?.toString() ?? "0.00"}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildActionButton(
                  context,
                  '充值',
                  Icons.add_circle_outline,
                  AppTheme.info,
                  () => context.push('/wallet-recharge'),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  context,
                  '提现',
                  Icons.account_balance_wallet_outlined,
                  AppTheme.success,
                  () => context.push('/wallet-withdraw'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.getTextPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _QuickAccessSkeleton extends StatelessWidget {
  const _QuickAccessSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(width: 60, height: 16),
                    SizedBox(width: 8),
                    Skeleton(width: 40, height: 14),
                  ],
                ),
                SizedBox(height: 8),
                Skeleton(width: 100, height: 24),
              ],
            ),
            Row(
              children: [
                Skeleton(width: 40, height: 40, borderRadius: 20),
                SizedBox(width: 12),
                Skeleton(width: 40, height: 40, borderRadius: 20),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
