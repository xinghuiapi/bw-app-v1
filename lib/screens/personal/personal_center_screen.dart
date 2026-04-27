import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';
import 'package:my_flutter_app/providers/system/theme_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/models/user/user.dart';
import 'package:my_flutter_app/widgets/layout/footer_widget.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/utils/constants.dart';

class PersonalCenterScreen extends ConsumerWidget {
  const PersonalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userState = ref.watch(userProvider);
    final user = userState.user;

    if (!authState.isLoggedIn) {
      return const SizedBox.shrink();
    }

    if (userState.isLoading && user == null) {
      return Scaffold(
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userState.error != null && user == null) {
      return Scaffold(
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        body: ErrorStateWidget(
          message: '加载失败: ${userState.error}',
          onRetry: () => ref.read(userProvider.notifier).fetchUserInfo(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      body: SafeArea(
        top: false, // 让背景延伸到状态栏
        child: RefreshIndicator(
          onRefresh: () => ref.read(userProvider.notifier).fetchUserInfo(),
          child: CustomScrollView(
            slivers: [
              // 用户基本信息头部
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    20,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.primary.withAlpha(25),
                        child: ClipOval(child: _buildAvatar(user)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.nickname ?? user?.username ?? '加载中...',
                                  style: TextStyle(
                                    color: AppTheme.getPrimaryTextColor(
                                      context,
                                    ),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.warning,
                                        AppTheme.warning.withAlpha(178),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    // Removed BoxShadow for web optimization
                                  ),
                                  child: Text(
                                    user?.displayVipLevel ?? 'VIP0',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getInputFillColor(context),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'UID: ${user?.id ?? "---"}',
                                    style: TextStyle(
                                      color: AppTheme.getSecondaryTextColor(
                                        context,
                                      ),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                if (user?.id != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: user!.id.toString(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('UID已复制'),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          width: 100,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy_outlined,
                                      color: AppTheme.getTertiaryTextColor(
                                        context,
                                      ),
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            context.push('/personal-center-profile'),
                        icon: Icon(
                          Icons.settings_outlined,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // VIP 等级卡片
              SliverToBoxAdapter(child: _buildVIPCard(context, user)),

              // 钱包卡片
              SliverToBoxAdapter(
                child: _buildWalletCard(context, ref, user, userState),
              ),

              // 功能列表
              SliverToBoxAdapter(child: _buildFunctionList(context, ref)),

              // 退出登录
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '退出登录',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildAvatar(User? user) {
    final avatarUrl = user?.img ?? user?.avatarUrl;
    final displayName = user?.nickname ?? user?.username ?? '';

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return Container(
        color: AppTheme.primary.withAlpha(25),
        alignment: Alignment.center,
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 处理相对路径
    String finalUrl = avatarUrl;
    if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('blob:')) {
      finalUrl = "${AppConstants.resourceBaseUrl}$avatarUrl";
    }

    return WebSafeImage(
      imageUrl: finalUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorWidget: Container(
        color: AppTheme.primary.withAlpha(25),
        alignment: Alignment.center,
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVIPCard(BuildContext context, User? user) {
    final levelData = user?.levelData;
    final currentLevel = user?.displayVipLevel ?? 'VIP0';
    final nextLevel = levelData?.nextVipLevel ?? 'VIP1';

    // 计算进度
    double progress = 0;
    String rechargeProgressText = '0/0';
    String validBetProgressText = '0/0';

    if (levelData != null) {
      // 这里的逻辑尽量对齐 Vue 项目的 upgradeProgressData
      final currentCharge =
          double.tryParse(
            (levelData.recharge ??
                    user?.totalRecharge ??
                    user?.totalDeposit ??
                    user?.rechargeAmount ??
                    0)
                .toString(),
          ) ??
          0;

      final requiredCharge =
          double.tryParse((levelData.nextRecharge ?? 0).toString()) ?? 0;

      final currentFlow =
          double.tryParse(
            (levelData.validBetAmount ??
                    user?.totalFlow ??
                    user?.flowingAmount ??
                    user?.totalBet ??
                    0)
                .toString(),
          ) ??
          0;

      final requiredFlow =
          double.tryParse((levelData.nextValidBetAmount ?? 0).toString()) ?? 0;

      final isMaxLevel =
          requiredCharge <= 0 &&
          requiredFlow <= 0 &&
          levelData.nextVipLevel == null;

      if (isMaxLevel) {
        progress = 1.0;
        rechargeProgressText = '已达最高等级';
        validBetProgressText = '已达最高等级';
      } else {
        final rechargeProgress = requiredCharge > 0
            ? (currentCharge / requiredCharge).clamp(0.0, 1.0)
            : 1.0;
        final betProgress = requiredFlow > 0
            ? (currentFlow / requiredFlow).clamp(0.0, 1.0)
            : 1.0;
        progress = (rechargeProgress + betProgress) / 2;

        rechargeProgressText =
            '${currentCharge.toStringAsFixed(0)}/${requiredCharge.toStringAsFixed(0)}';
        validBetProgressText =
            '${currentFlow.toStringAsFixed(0)}/${requiredFlow.toStringAsFixed(0)}';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
        // Removed BoxShadow for web optimization
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VIP 升级进度',
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/personal-center-vip'),
                child: const Row(
                  children: [
                    Text(
                      '等级权益',
                      style: TextStyle(color: AppTheme.warning, fontSize: 12),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.warning,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentLevel ?? 'VIP0',
                style: TextStyle(
                  color: AppTheme.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextLevel,
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.getDividerColor(context),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.warning,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '充值进度',
                      style: TextStyle(
                        color: AppTheme.getTertiaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rechargeProgressText,
                      style: TextStyle(
                        color: AppTheme.getPrimaryTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.getDividerColor(context),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '流水进度',
                      style: TextStyle(
                        color: AppTheme.getTertiaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      validBetProgressText,
                      style: TextStyle(
                        color: AppTheme.getPrimaryTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    WidgetRef ref,
    User? user,
    UserState userState,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主账户余额',
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '¥ ${double.tryParse((user?.balance ?? 0).toString())?.toStringAsFixed(2) ?? "0.00"}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            ref.read(userProvider.notifier).refreshBalance(),
                        child: userState.isBalanceLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.getTertiaryTextColor(context),
                                ),
                              )
                            : Icon(
                                Icons.refresh,
                                color: AppTheme.getTertiaryTextColor(context),
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).allTrans(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getInputFillColor(context),
                  foregroundColor: AppTheme.getPrimaryTextColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: userState.isAllTransLoading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      )
                    : const Text('一键回收', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletAction(
                context,
                '充值',
                Icons.add_circle_outline,
                AppTheme.info,
                () => context.push('/wallet-recharge'),
              ),
              _buildWalletAction(
                context,
                '提现',
                Icons.account_balance_wallet_outlined,
                AppTheme.success,
                () => context.push('/wallet-withdraw'),
              ),
              _buildWalletAction(
                context,
                '转账',
                Icons.swap_horiz,
                AppTheme.warning,
                () => context.push('/wallet-transfer'),
              ),
              _buildWalletAction(
                context,
                '卡包',
                Icons.confirmation_number_outlined,
                AppTheme.primary,
                () => context.push('/personal-center-card-packages'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAction(
    BuildContext context,
    String label,
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
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionList(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildListItem(
            context,
            Icons.person_outline,
            '个人资料',
            '查看并完善您的个人信息',
            () => context.push('/personal-center-profile'),
            iconColor: Colors.blue,
          ),
          _buildListItem(
            context,
            Icons.receipt_long_outlined,
            '往来记录',
            '会员返水/充值提现/红利/游戏记录/账单明细',
            () => context.push('/personal-center-transaction-records'),
            iconColor: Colors.orange,
          ),
          _buildListItem(
            context,
            Icons.notifications_none_outlined,
            '消息通知',
            '站内信与系统通知',
            () => context.push('/personal-center-notifications'),
            iconColor: Colors.pink,
          ),
          _buildListItem(
            context,
            Icons.campaign_outlined,
            '代理合作',
            '加入我们，开启创业之路',
            () => context.push('/agent-cooperation'),
            iconColor: Colors.amber,
          ),
          _buildListItem(
            context,
            Icons.share_outlined,
            '分享好友',
            '邀请好友领福利',
            () => context.push('/share-invite'),
            iconColor: Colors.teal,
          ),
          _buildListItem(
            context,
            Icons.headset_mic_outlined,
            '联系客服',
            '24小时在线为您服务',
            () => context.push('/customer-service'),
            iconColor: Colors.indigo,
          ),
          _buildListItem(
            context,
            Icons.feedback_outlined,
            '意见反馈',
            '您的建议是我们进步的动力',
            () => context.push('/feedback'),
            iconColor: Colors.purple,
          ),
          _buildThemeItem(context, ref),
          _buildClearCacheItem(context),
        ],
      ),
    );
  }

  Widget _buildThemeItem(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getInputFillColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppTheme.getPrimaryTextColor(context),
              size: 20,
            ),
          ),
          title: Text(
            isDark ? '深色模式' : '浅色模式',
            style: TextStyle(
              color: AppTheme.getPrimaryTextColor(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            isDark ? '已开启' : '已关闭',
            style: TextStyle(
              color: AppTheme.getTertiaryTextColor(context),
              fontSize: 12,
            ),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (value) =>
                ref.read(themeProvider.notifier).toggleTheme(),
            activeColor: AppTheme.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Divider(height: 1, color: AppTheme.getDividerColor(context)),
        ),
      ],
    );
  }

  Widget _buildClearCacheItem(BuildContext context) {
    return ListTile(
      onTap: () => _showClearCacheDialog(context),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warning.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppTheme.warning,
          size: 20,
        ),
      ),
      title: Text(
        '清理缓存',
        style: TextStyle(
          color: AppTheme.getPrimaryTextColor(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '释放应用占用的空间',
        style: TextStyle(
          color: AppTheme.getTertiaryTextColor(context),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.getTertiaryTextColor(context),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.warning,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '清理缓存',
                  style: TextStyle(
                    color: AppTheme.getPrimaryTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '清理缓存将释放存储空间，不会影响您的账户数据。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // 模拟清理过程
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('缓存清理成功')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warning,
                        ),
                        child: const Text('立即清理'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    VoidCallback onTap, {
    Color? iconColor,
    bool isLast = false,
  }) {
    final primaryColor = AppTheme.getPrimaryTextColor(context);
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? primaryColor).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? primaryColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            desc,
            style: TextStyle(
              color: AppTheme.getTertiaryTextColor(context),
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppTheme.getTertiaryTextColor(context),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(height: 1, color: AppTheme.getDividerColor(context)),
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.warning,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '退出登录',
                  style: TextStyle(
                    color: AppTheme.getPrimaryTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '您确定要退出当前账号吗？',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // 先跳转到首页
                          context.go('/home');
                          // 再执行退出逻辑
                          await ref.read(authProvider.notifier).logout();
                          ToastUtils.showSuccess('已安全退出');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                        ),
                        child: const Text('确定退出'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
