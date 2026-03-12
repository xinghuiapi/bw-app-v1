import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';

class UserDrawer extends ConsumerWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userState = ref.watch(userProvider);
    final user = userState.user;

    return Drawer(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // 头部用户信息
            if (authState.isLoggedIn)
              (userState.isLoading && user == null
                  ? const _DrawerHeaderSkeleton()
                  : _buildUserInfo(context, user))
            else
              _buildLoginButton(context),

            const Divider(color: Colors.white10),

            // 功能列表
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(context, Icons.person_outline, '个人资料', '/personal-center-profile'),
                  _buildMenuItem(context, Icons.account_balance_wallet_outlined, '钱包充值', '/wallet-recharge'),
                  _buildMenuItem(context, Icons.account_balance_wallet_outlined, '钱包提现', '/wallet-withdraw'),
                  _buildMenuItem(context, Icons.history, '投注记录', '/bet-records'),
                  _buildMenuItem(context, Icons.card_giftcard, '活动中心', '/activities'),
                  _buildMenuItem(context, Icons.headset_mic_outlined, '联系客服', '/customer-service'),
                ],
              ),
            ),

            // 退出登录按钮
            if (authState.isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. 关闭侧边栏
                      Navigator.pop(context);
                      // 2. 跳转到首页
                      context.go('/home');
                      // 3. 执行退出逻辑
                      await ref.read(authProvider.notifier).logout();
                      ToastUtils.showSuccess('已安全退出');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('退出登录'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withAlpha(25),
            radius: 24,
            child: const Icon(Icons.person, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? '未登录',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '余额: ¥ ${user?.balance?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('立即登录'),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isSelected = location == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: isSelected ? AppTheme.primary : AppTheme.textTertiary, size: 18),
          onTap: () {
            Navigator.pop(context);
            context.push(route);
          },
        ),
      ),
    );
  }
}

class _DrawerHeaderSkeleton extends StatelessWidget {
  const _DrawerHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: [
          Skeleton(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 100, height: 18),
                SizedBox(height: 8),
                Skeleton(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
