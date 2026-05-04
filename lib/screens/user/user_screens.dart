import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user/user_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_cell.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common/app_network_image.dart';

export 'forms/bind_phone_screen.dart';
export 'forms/bind_email_screen.dart';
export 'forms/change_password_screen.dart';
export 'forms/withdraw_password_screen.dart';
export 'forms/real_name_screen.dart';
export 'forms/add_bank_card_screen.dart';
export 'share_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final username = _textFallback(profile?.nickname ?? profile?.username, '—');
    final vipLevel = profile?.displayVipLevel ?? 'VIP0';
    final accountId = profile == null ? '88—' : profile.id.toString();
    final symbol = _textFallback(profile?.symbol, '¥');
    final balance = _amountText(profile?.balance, fallback: '0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- 1. User Info Section ---
              GestureDetector(
                onTap: () => context.push('/setting'),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildAvatar(profile?.avatarUrl ?? profile?.img),
                          Positioned(
                            right: -4.w,
                            bottom: -4.h,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A8AF4),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.edit,
                                  size: 12.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FF),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    vipLevel,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF4A8AF4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '账号ID：$accountId',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF8B95A3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16.sp,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),

              // --- 2. Wallet Card ---
              GestureDetector(
                onTap: () => context.push('/my-wallet'),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A9AF5), Color(0xFF3A7AF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A8AF4).withValues(alpha: 0.3),
                        blurRadius: 10.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '钱包余额',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14.sp),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 16.sp),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.refresh,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                '刷新',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h, right: 4.w),
                            child: Text(
                              symbol,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            balance,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/deposit'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            width: 1),
                                      ),
                                      child: Icon(Icons.currency_yuan,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          size: 14.sp),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text('充值',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 16.h,
                                color: Colors.white.withValues(alpha: 0.3)),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/withdraw'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            width: 1),
                                      ),
                                      child: Icon(Icons.shopping_bag_outlined,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          size: 14.sp),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text('提现',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. Today's Earnings Card ---
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8AB4F8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text('今日收益',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            SizedBox(width: 8.w),
                            Text('4月24日',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.sp)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.refresh,
                                color: const Color(0xFF4A8AF4), size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('刷新',
                                style: TextStyle(
                                    color: const Color(0xFF4A8AF4),
                                    fontSize: 14.sp)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('0',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('注单笔数',
                                      style: TextStyle(
                                          color: const Color(0xFF4A8AF4),
                                          fontSize: 12.sp)),
                                  Icon(Icons.chevron_right,
                                      color: const Color(0xFF4A8AF4),
                                      size: 12.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 20.h,
                            color: Colors.grey.withValues(alpha: 0.2)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('0.00',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('总盈亏',
                                      style: TextStyle(
                                          color: const Color(0xFF4A8AF4),
                                          fontSize: 12.sp)),
                                  Icon(Icons.chevron_right,
                                      color: const Color(0xFF4A8AF4),
                                      size: 12.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 20.h,
                            color: Colors.grey.withValues(alpha: 0.2)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('0.00',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('未领返水',
                                      style: TextStyle(
                                          color: const Color(0xFF4A8AF4),
                                          fontSize: 12.sp)),
                                  Icon(Icons.chevron_right,
                                      color: const Color(0xFF4A8AF4),
                                      size: 12.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 4. More Services Card ---
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8AB4F8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('更多服务',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 24.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 0.8,
                      children: [
                        _buildServiceItem(Icons.grid_view_rounded, '游戏管理',
                            context, '/game-management'),
                        _buildServiceItem(Icons.account_balance_wallet_outlined,
                            '资金管理', context, '/wallet'),
                        _buildServiceItem(
                            Icons.swap_horiz, '场馆余额', context, '/my-wallet'),
                        _buildServiceItem(Icons.credit_card_outlined, '银行卡',
                            context, '/cards'),
                        _buildServiceItem(
                            Icons.reply_outlined, '分享', context, '/share'),
                        _buildServiceItem(Icons.workspace_premium_outlined,
                            'VIP', context, '/vip'),
                        _buildServiceItem(Icons.chat_bubble_outline, '意见反馈',
                            context, '/feedback'),
                        _buildServiceItem(
                            Icons.lightbulb_outline, '即将上线', context, null),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(
      IconData icon, String title, BuildContext context, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.push(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: const Color(0xFF9AA4B1)),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    final fallback = Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 48.sp, color: Colors.grey),
    );

    if (imageUrl == null || imageUrl.trim().isEmpty) return fallback;

    return AppNetworkImage(
      url: imageUrl,
      width: 72.r,
      height: 72.r,
      borderRadius: BorderRadius.circular(36.r),
      errorWidget: fallback,
      placeholder: fallback,
    );
  }

  String _textFallback(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _amountText(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final amount = num.tryParse(value.toString());
    if (amount == null) return value.toString();
    return amount.toStringAsFixed(2);
  }
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '账户设置'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    title: '实名认证',
                    value: '未认证',
                    isLink: true,
                    onTap: () => context.push('/real-name'),
                  ),
                  CustomCell(
                    title: '绑定手机号',
                    value: '138****8888',
                    isLink: true,
                    onTap: () => context.push('/bind-phone'),
                  ),
                  CustomCell(
                    title: '绑定邮箱',
                    value: '未绑定',
                    isLink: true,
                    border: false,
                    onTap: () => context.push('/bind-email'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    title: '修改登录密码',
                    isLink: true,
                    onTap: () => context.push('/change-password'),
                  ),
                  CustomCell(
                    title: '设置资金密码',
                    value: '已设置',
                    isLink: true,
                    border: false,
                    onTap: () => context.push('/withdraw-password'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            const CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    title: '语言设置',
                    value: '简体中文',
                    isLink: true,
                  ),
                  CustomCell(
                    title: '检查更新',
                    value: 'v1.0.0',
                    isLink: true,
                  ),
                  CustomCell(
                    title: '关于我们',
                    isLink: true,
                    border: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      side: const BorderSide(color: Color(0xFFE5E8EF)),
                    ),
                  ),
                  onPressed: context.watch<AuthProvider>().isSubmitting
                      ? null
                      : () => _logout(context),
                  child: context.watch<AuthProvider>().isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '退出登录',
                          style: TextStyle(
                            color: const Color(0xFFE74C3C),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.read<UserProvider>().clearProfile();
    if (!context.mounted) return;
    context.go('/login');
  }
}

class BankCardListScreen extends StatelessWidget {
  const BankCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '银行卡管理'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _buildBankCard(
                  bankName: '招商银行',
                  cardType: '储蓄卡',
                  cardNumber: '**** **** **** 8888',
                  color: const Color(0xFFE53935),
                  icon: Icons.account_balance,
                ),
                SizedBox(height: 16.h),
                _buildBankCard(
                  bankName: '建设银行',
                  cardType: '储蓄卡',
                  cardNumber: '**** **** **** 6666',
                  color: const Color(0xFF1E88E5),
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                onPressed: () => context.push('/add-card'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  '添加银行卡',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String cardType,
    required String cardNumber,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cardType,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> levels = [
    {
      'level': 1,
      'recharge': 0,
      'turnover': 0,
      'upgrade': 0,
      'weekly': 0,
      'birthday': 0,
      'dailyCount': 3,
      'dailyLimit': '5,000',
      'minWithdraw': 50,
      'minRecharge': 10,
      'maxRecharge': '50,000',
      'rebates': {
        '体育': '0.30%',
        '视讯': '0.40%',
        '电子': '0.50%',
        '棋牌': '0.40%',
        '捕鱼': '0.50%',
        '电竞': '0.30%',
        '彩票': '0.00%'
      }
    },
    {
      'level': 2,
      'recharge': 1000,
      'turnover': 10000,
      'upgrade': 18,
      'weekly': 8,
      'birthday': 18,
      'dailyCount': 5,
      'dailyLimit': '10,000',
      'minWithdraw': 50,
      'minRecharge': 10,
      'maxRecharge': '50,000',
      'rebates': {
        '体育': '0.40%',
        '视讯': '0.50%',
        '电子': '0.60%',
        '棋牌': '0.50%',
        '捕鱼': '0.60%',
        '电竞': '0.40%',
        '彩票': '0.00%'
      }
    },
    {
      'level': 3,
      'recharge': 5000,
      'turnover': 50000,
      'upgrade': 38,
      'weekly': 18,
      'birthday': 38,
      'dailyCount': 5,
      'dailyLimit': '50,000',
      'minWithdraw': 50,
      'minRecharge': 10,
      'maxRecharge': '50,000',
      'rebates': {
        '体育': '0.45%',
        '视讯': '0.55%',
        '电子': '0.65%',
        '棋牌': '0.55%',
        '捕鱼': '0.65%',
        '电竞': '0.45%',
        '彩票': '0.00%'
      }
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadVipLevels().then((_) {
        if (!mounted) return;
        final userProvider = context.read<UserProvider>();
        setState(() {
          _selectedIndex = _indexForLevel(
            userProvider.vipLevels,
            _computedCurrentLevel(userProvider),
          );
        });
      }).catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final vipLevels = userProvider.vipLevels;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const CustomNavBar(title: 'VIP'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildProgressCard(userProvider),
            SizedBox(height: 16.h),
            _buildVipLevelCard(profile, vipLevels),
            SizedBox(height: 16.h),
            _buildRulesCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWithDot(String title, {Widget? rightWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                color: Color(0xFF6B9CFF),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        if (rightWidget != null) rightWidget,
      ],
    );
  }

  Widget _buildProgressCard(UserProvider userProvider) {
    final progress = _vipProgress(userProvider);

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithDot('升级进度',
              rightWidget: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6B9CFF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text('当前 VIP${progress.currentLevel}',
                    style: TextStyle(
                        color: const Color(0xFF6B9CFF), fontSize: 11.sp)),
              )),
          if (progress.nextLevel != null) ...[
            SizedBox(height: 10.h),
            Text(
              '下一等级 VIP${progress.nextLevel}',
              style: TextStyle(color: const Color(0xFF999999), fontSize: 12.sp),
            ),
          ],
          SizedBox(height: 24.h),
          _buildProgressBar(
            '充值进度',
            progress.recharge,
            progress.nextRecharge,
            progress.rechargePercent,
          ),
          SizedBox(height: 20.h),
          _buildProgressBar(
            '流水进度',
            progress.validBet,
            progress.nextValidBet,
            progress.flowPercent,
          ),
          SizedBox(height: 24.h),
          Text(
            progress.isMaxLevel
                ? '当前已达到最高等级，请继续保持活跃以享受专属权益。'
                : '升级还需充值 ${_formatMoney(progress.gapRecharge)}，流水 ${_formatMoney(progress.gapValidBet)}；达到条件后升级生效。',
            style: TextStyle(
                color: const Color(0xFF999999), fontSize: 12.sp, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      String title, num current, num target, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600)),
            Flexible(
              child: Text(
                '${_formatMoney(current)} / ${_formatMoney(target)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: const Color(0xFF999999), fontSize: 13.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8.h,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B9CFF)),
          ),
        ),
      ],
    );
  }

  Widget _buildVipLevelCard(UserProfile? profile, List<VipLevel> vipLevels) {
    final selectedVipLevel = _selectedVipLevel(vipLevels);
    final fallbackLevelData =
        levels[_selectedIndex.clamp(0, levels.length - 1)];
    final currentLevel = _computedCurrentLevel(context.watch<UserProvider>());
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithDot('VIP 等级'),
          _buildTabs(),
          Row(
            children: [
              Text(
                selectedVipLevel?.title ?? 'VIP${fallbackLevelData['level']}',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333)),
              ),
              SizedBox(width: 8.w),
              if (_selectedLevelNumber(selectedVipLevel, fallbackLevelData) ==
                  currentLevel)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6B9CFF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text('当前',
                      style: TextStyle(
                          color: const Color(0xFF6B9CFF), fontSize: 11.sp)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            selectedVipLevel == null
                ? '升级条件：充值 ¥${fallbackLevelData['recharge']} + 流水 ¥${fallbackLevelData['turnover']}'
                : '升级条件：充值 ${_formatDynamicAmount(selectedVipLevel.chargeLevel)} + 流水 ${_formatDynamicAmount(selectedVipLevel.flowingLevel)}',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666)),
          ),
          SizedBox(height: 24.h),
          Text('VIP 福利',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333))),
          SizedBox(height: 16.h),
          _buildListContainer([
            _buildListRow(
                '升级礼金',
                _vipValue(
                    selectedVipLevel?.levelGive, fallbackLevelData['upgrade'])),
            _buildListRow(
                '周红包',
                _vipValue(
                    selectedVipLevel?.weekRed, fallbackLevelData['weekly'])),
            _buildListRow(
                '生日礼金',
                _vipValue(selectedVipLevel?.birthdayGive,
                    fallbackLevelData['birthday'])),
            _buildListRow(
                '每日提款次数',
                selectedVipLevel?.dayCountDrawing == null
                    ? '${fallbackLevelData['dailyCount']} 次'
                    : '${selectedVipLevel!.dayCountDrawing} 次'),
            _buildListRow(
                '每日提款额度',
                _vipValue(selectedVipLevel?.dayAmountDrawing,
                    fallbackLevelData['dailyLimit'])),
            _buildListRow(
                '最低提款金额',
                _vipValue(selectedVipLevel?.minDrawing,
                    fallbackLevelData['minWithdraw'])),
            _buildListRow(
                '最低充值金额',
                _vipValue(selectedVipLevel?.minRecharge,
                    fallbackLevelData['minRecharge'])),
            _buildListRow(
                '最高充值金额',
                _vipValue(selectedVipLevel?.maxRecharge,
                    fallbackLevelData['maxRecharge']),
                showBorder: false),
          ]),
          SizedBox(height: 24.h),
          Text('VIP 返水比例',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333))),
          SizedBox(height: 16.h),
          _buildListContainer(_rebateRows(selectedVipLevel, fallbackLevelData)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final userProvider = context.watch<UserProvider>();
    final vipLevels = userProvider.vipLevels;
    final currentLevel = _computedCurrentLevel(userProvider);
    if (vipLevels.isNotEmpty && _selectedIndex >= vipLevels.length) {
      _selectedIndex = 0;
    }
    final tabItems = vipLevels.isEmpty ? levels : vipLevels;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabItems.map((item) {
            final index = tabItems.indexOf(item);
            final levelNumber = item is VipLevel
                ? item.levelNumber
                : (item as Map<String, dynamic>)['level'] as int;
            final levelTitle =
                item is VipLevel ? item.title : 'VIP$levelNumber';
            final isSelected = _selectedIndex == index;
            final isCurrent = levelNumber == currentLevel;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6B9CFF)
                          : Colors.transparent,
                      width: 3.h,
                    ),
                  ),
                ),
                child: Text(
                  isCurrent ? '$levelTitle 当前' : levelTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected || isCurrent
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected || isCurrent
                        ? const Color(0xFF333333)
                        : const Color(0xFF999999),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 14.sp, color: const Color(0xFF666666))),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333))),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithDot('升级说明'),
          SizedBox(height: 20.h),
          _buildRuleText('1. VIP 等级共 10 级，等级越高享受福利与返水比例越高。'),
          _buildRuleText('2. 升级需同时满足充值进度与流水进度两项条件。'),
          _buildRuleText('3. 充值与流水统计以系统为准，存在延迟时请稍后刷新查看。'),
          _buildRuleText('4. 每日提款次数/额度等福利以当日自然日统计口径为准。'),
          _buildRuleText('5. 具体活动条款如与页面不一致，以平台最终规则为准。'),
        ],
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14.sp, color: const Color(0xFF666666), height: 1.6),
      ),
    );
  }

  _VipProgressData _vipProgress(UserProvider userProvider) {
    final vipLevels = userProvider.vipLevels;
    if (vipLevels.isNotEmpty) {
      final recharge = _toDouble(userProvider.vipOverview?.totalDeposit);
      final validBet = _toDouble(userProvider.vipOverview?.totalBet);
      final currentLevel = _computeCurrentLevel(vipLevels, recharge, validBet);
      final maxLevel = vipLevels.last.levelNumber;
      final nextLevel = currentLevel >= maxLevel ? null : currentLevel + 1;
      final nextVipLevel = nextLevel == null
          ? null
          : vipLevels.firstWhere(
              (item) => item.levelNumber == nextLevel,
              orElse: () => vipLevels.last,
            );
      final nextRecharge = _toDouble(nextVipLevel?.chargeLevel);
      final nextValidBet = _toDouble(nextVipLevel?.flowingLevel);
      final gapRecharge =
          (nextRecharge - recharge).clamp(0, double.infinity).toDouble();
      final gapValidBet =
          (nextValidBet - validBet).clamp(0, double.infinity).toDouble();
      final isMaxLevel = nextLevel == null;

      return _VipProgressData(
        currentLevel: currentLevel,
        nextLevel: nextLevel,
        recharge: recharge,
        nextRecharge: nextRecharge,
        validBet: validBet,
        nextValidBet: nextValidBet,
        gapRecharge: gapRecharge,
        gapValidBet: gapValidBet,
        rechargePercent:
            isMaxLevel ? 1 : _progressPercent(recharge, nextRecharge),
        flowPercent: isMaxLevel ? 1 : _progressPercent(validBet, nextValidBet),
        isMaxLevel: isMaxLevel,
      );
    }

    final profile = userProvider.profile;
    final levelData = profile?.levelData;
    final currentLevel =
        _vipLevelNumber(levelData?.vipLevel ?? profile?.displayVipLevel) ?? 1;
    final nextLevel = _vipLevelNumber(levelData?.nextVipLevel);
    final recharge = _toDouble(
      levelData?.recharge ??
          profile?.totalRecharge ??
          profile?.totalDeposit ??
          profile?.rechargeAmount,
    );
    final nextRecharge = _toDouble(levelData?.nextRecharge);
    final validBet = _toDouble(
      levelData?.validBetAmount ??
          profile?.totalFlow ??
          profile?.flowingAmount ??
          profile?.totalBet ??
          profile?.okWater,
    );
    final nextValidBet = _toDouble(levelData?.nextValidBetAmount);
    final gapRecharge = _toDouble(levelData?.gapRecharge);
    final gapValidBet = _toDouble(levelData?.gapValidBetAmount);
    final isMaxLevel =
        nextRecharge <= 0 && nextValidBet <= 0 && nextLevel == null;

    return _VipProgressData(
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      recharge: recharge,
      nextRecharge: nextRecharge,
      validBet: validBet,
      nextValidBet: nextValidBet,
      gapRecharge: gapRecharge,
      gapValidBet: gapValidBet,
      rechargePercent:
          isMaxLevel ? 1 : _progressPercent(recharge, nextRecharge),
      flowPercent: isMaxLevel ? 1 : _progressPercent(validBet, nextValidBet),
      isMaxLevel: isMaxLevel,
    );
  }

  double _progressPercent(double current, double target) {
    if (target <= 0) return 1;
    return (current / target).clamp(0.0, 1.0);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatAmount(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _formatMoney(num value) {
    return '${_currencySymbol()}${_formatAmount(value)}';
  }

  String _currencySymbol() {
    final profile = context.read<UserProvider>().profile;
    final symbol = profile?.symbol?.trim();
    if (symbol != null && symbol.isNotEmpty) return symbol;
    final currency = profile?.currency?.trim();
    return currency == null || currency.isEmpty ? '¥' : currency;
  }

  int? _vipLevelNumber(String? level) {
    if (level == null) return null;
    return int.tryParse(level.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  int _computedCurrentLevel(UserProvider userProvider) {
    final vipLevels = userProvider.vipLevels;
    if (vipLevels.isEmpty) {
      return _vipLevelNumber(userProvider.profile?.displayVipLevel) ?? 1;
    }
    return _computeCurrentLevel(
      vipLevels,
      _toDouble(userProvider.vipOverview?.totalDeposit),
      _toDouble(userProvider.vipOverview?.totalBet),
    );
  }

  int _computeCurrentLevel(
    List<VipLevel> vipLevels,
    double totalDeposit,
    double totalBet,
  ) {
    var current = vipLevels.isNotEmpty ? vipLevels.first.levelNumber : 1;
    for (final level in vipLevels) {
      if (totalDeposit >= _toDouble(level.chargeLevel) &&
          totalBet >= _toDouble(level.flowingLevel)) {
        current = level.levelNumber;
      }
    }
    return current;
  }

  int _indexForLevel(List<VipLevel> vipLevels, int level) {
    if (vipLevels.isEmpty) return (level - 1).clamp(0, levels.length - 1);
    final index = vipLevels.indexWhere((item) => item.levelNumber == level);
    return index < 0 ? 0 : index;
  }

  VipLevel? _selectedVipLevel(List<VipLevel> vipLevels) {
    if (vipLevels.isEmpty || _selectedIndex >= vipLevels.length) return null;
    return vipLevels[_selectedIndex];
  }

  int _selectedLevelNumber(
    VipLevel? selectedVipLevel,
    Map<String, dynamic> fallbackLevelData,
  ) {
    return selectedVipLevel?.levelNumber ?? fallbackLevelData['level'] as int;
  }

  String _vipValue(dynamic value, dynamic fallback) {
    return _formatDynamicAmount(value ?? fallback);
  }

  String _formatDynamicAmount(dynamic value) {
    if (value == null) return '--';
    final amount = num.tryParse(value.toString());
    if (amount == null) return value.toString();
    return '${_currencySymbol()}${_formatAmount(amount)}';
  }

  List<Widget> _rebateRows(
    VipLevel? selectedVipLevel,
    Map<String, dynamic> fallbackLevelData,
  ) {
    final fallback = fallbackLevelData['rebates'] as Map<String, String>;
    final rows = <MapEntry<String, String>>[
      MapEntry('体育', _rebateValue(selectedVipLevel?.sportBl, fallback['体育'])),
      MapEntry('视讯', _rebateValue(selectedVipLevel?.liveBl, fallback['视讯'])),
      MapEntry('电子', _rebateValue(selectedVipLevel?.gamesBl, fallback['电子'])),
      MapEntry('棋牌', _rebateValue(selectedVipLevel?.pokerBl, fallback['棋牌'])),
      MapEntry('捕鱼', _rebateValue(selectedVipLevel?.fishingBl, fallback['捕鱼'])),
      MapEntry('电竞', _rebateValue(selectedVipLevel?.gamingBl, fallback['电竞'])),
      MapEntry('彩票', _rebateValue(selectedVipLevel?.lotteryBl, fallback['彩票'])),
    ];

    return rows.map((entry) {
      final isLast = entry.key == rows.last.key;
      return _buildListRow(entry.key, entry.value, showBorder: !isLast);
    }).toList();
  }

  String _rebateValue(dynamic value, String? fallback) {
    if (value == null) return fallback ?? '0.00%';
    final text = value.toString();
    return text.endsWith('%') ? text : '$text%';
  }
}

class _VipProgressData {
  const _VipProgressData({
    required this.currentLevel,
    required this.nextLevel,
    required this.recharge,
    required this.nextRecharge,
    required this.validBet,
    required this.nextValidBet,
    required this.gapRecharge,
    required this.gapValidBet,
    required this.rechargePercent,
    required this.flowPercent,
    required this.isMaxLevel,
  });

  final int currentLevel;
  final int? nextLevel;
  final double recharge;
  final double nextRecharge;
  final double validBet;
  final double nextValidBet;
  final double gapRecharge;
  final double gapValidBet;
  final double rechargePercent;
  final double flowPercent;
  final bool isMaxLevel;
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> messages = [
    {
      'title': '充值成功通知',
      'content': '您的账户已成功充值 10,000 元，当前余额为 15,200 元。',
      'time': '10:30',
      'isRead': false,
      'type': 'system',
    },
    {
      'title': 'VIP 等级提升',
      'content': '恭喜！您的 VIP 等级已提升至 VIP3，快去查看专属特权吧！',
      'time': '昨天',
      'isRead': false,
      'type': 'activity',
    },
    {
      'title': '周末狂欢活动开启',
      'content': '周末狂欢送不停，登录即送免费抽奖机会，最高可得 8,888 元！',
      'time': '04-20',
      'isRead': true,
      'type': 'activity',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredMessages(int tabIndex) {
    if (tabIndex == 1) {
      return messages.where((m) => !(m['isRead'] as bool)).toList(); // 未读
    }
    if (tabIndex == 2) {
      return messages.where((m) => (m['isRead'] as bool)).toList(); // 已读
    }
    return messages; // 全部
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '消息中心'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3.h,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
              onTap: (index) {
                setState(() {}); // Trigger rebuild to filter messages
              },
              tabs: const [
                Tab(text: '全部'),
                Tab(text: '未读'),
                Tab(text: '已读'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMessageList(_getFilteredMessages(0)),
                _buildMessageList(_getFilteredMessages(1)),
                _buildMessageList(_getFilteredMessages(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Map<String, dynamic>> filteredMessages) {
    if (filteredMessages.isEmpty) {
      return Center(
        child: Text(
          '暂无相关消息',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredMessages.length,
      itemBuilder: (context, index) {
        final msg = filteredMessages[index];
        final bool isRead = msg['isRead'] as bool;

        return GestureDetector(
          onTap: () {
            if (!isRead) {
              setState(() {
                msg['isRead'] = true;
              });
            }
          },
          child: CustomCard(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: msg['type'] == 'system'
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFFF9B00).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        msg['type'] == 'system'
                            ? Icons.notifications
                            : Icons.campaign,
                        color: msg['type'] == 'system'
                            ? AppColors.primary
                            : const Color(0xFFFF9B00),
                        size: 24.sp,
                      ),
                    ),
                    if (!isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            msg['title'] as String,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            msg['time'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        msg['content'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = '游戏问题';
  final int _maxLength = 300;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final types = ['游戏问题', '充提问题', '活动问题', '账户安全', '其他建议'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '选择问题类型',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...types.map((type) => ListTile(
                    title: Text(type, textAlign: TextAlign.center),
                    onTap: () {
                      setState(() => _selectedType = type);
                      context.pop();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: '意见反馈',
        rightText: '反馈记录',
        onClickRight: () {
          context.push('/feedback-records');
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '问题类型',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _showTypeSelector,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedType,
                      style: TextStyle(
                          fontSize: 15.sp, color: AppColors.textPrimary),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16.sp, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '问题描述',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _contentController,
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/$_maxLength',
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: TextField(
                controller: _contentController,
                maxLength: _maxLength,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '请详细描述您遇到的问题或建议...',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14.sp),
                  border: InputBorder.none,
                  counterText: '', // Hide default counter
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              '上传图片 (选填，最多3张)',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12.w,
                crossAxisSpacing: 12.w,
              ),
              itemCount: 1, // Only show the add button for now
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo,
                          color: AppColors.textSecondary, size: 32.sp),
                      SizedBox(height: 8.h),
                      Text(
                        '添加图片',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),
            CustomButton(
              text: '提交反馈',
              onPressed: () {
                if (_contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入反馈内容')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('感谢您的反馈！')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackRecordsScreen extends StatelessWidget {
  const FeedbackRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        'content': '游戏大厅加载速度有时候比较慢，希望能优化一下。',
        'time': '2024-04-20 14:30',
        'status': '处理中',
      },
      {
        'content': '建议增加夜间模式，晚上玩的时候太刺眼了。',
        'time': '2024-04-15 09:15',
        'status': '已采纳',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '反馈记录'),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isProcessing = record['status'] == '处理中';

          return CustomCard(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record['time'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isProcessing
                            ? const Color(0xFFFFF7E6)
                            : const Color(0xFFE6F7ED),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        record['status'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isProcessing
                              ? const Color(0xFFFF9B00)
                              : const Color(0xFF00B578),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  record['content'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
