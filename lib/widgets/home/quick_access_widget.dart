import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../common/skeleton_widget.dart';

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
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
      ),
      child: authState.isLoggedIn 
          ? (userState.isLoading && user == null
              ? const _QuickAccessSkeleton()
              : _buildLoggedIn(context, ref, user, userState))
          : _buildLoggedOut(context),
    );
  }

  Widget _buildLoggedOut(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '下午好!',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _buildButton('注册', AppTheme.surface, AppTheme.textPrimary, () {
                  context.push('/register');
                }),
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
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.language, color: AppTheme.textTertiary, size: 16),
              SizedBox(width: 8),
              Text('官方域名', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
              SizedBox(width: 8),
              Text('xh-bet.com', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedIn(BuildContext context, WidgetRef ref, dynamic user, UserState userState) {
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
                    Text(user?.username ?? '...', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Text('主钱包', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => ref.read(userProvider.notifier).refreshBalance(),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: userState.isBalanceLoading
                            ? const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textTertiary)
                            : const Icon(Icons.refresh, color: AppTheme.textTertiary, size: 16),
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
                _buildActionButton(context, '充值', Icons.add_circle_outline, AppTheme.info, () => context.push('/wallet/recharge')),
                const SizedBox(width: 12),
                _buildActionButton(context, '提现', Icons.account_balance_wallet_outlined, AppTheme.success, () => context.push('/wallet/withdraw')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
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
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
