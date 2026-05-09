import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/home/home_models.dart';
import '../../models/user/user_models.dart';
import '../../models/wallet/wallet_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/feedback/feedback_provider.dart';
import '../../providers/message/message_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_cell.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_error.dart';
import '../../widgets/common/app_loading.dart';
import 'forms/user_form_feedback.dart';

export 'forms/bind_phone_screen.dart';
export 'forms/bind_email_screen.dart';
export 'forms/change_password_screen.dart';
export 'forms/withdraw_password_screen.dart';
export 'forms/real_name_screen.dart';
export 'forms/add_bank_card_screen.dart';
export 'share_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messageProvider = context.read<MessageProvider>();
      if (messageProvider.messages.isEmpty && !messageProvider.isLoading) {
        messageProvider.loadMessages();
      }
    });
  }

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
                onTap: () => context.push('/user-profile'),
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
                                GestureDetector(
                                  onTap: () => context.push('/vip'),
                                  child: Container(
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
                      _buildHeaderActions(context),
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
                            '资金管理', context, '/fund-management'),
                        _buildServiceItem(
                            Icons.swap_horiz, '场馆余额', context, '/wallet'),
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

  Widget _buildHeaderActions(BuildContext context) {
    final unreadCount = context.watch<MessageProvider>().unreadCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/message'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.email_outlined,
                  size: 24.sp, color: const Color(0xFF333333)),
              if (unreadCount > 0)
                Positioned(
                  right: -1.w,
                  top: -1.h,
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D4F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/setting'),
          child: Icon(Icons.settings_outlined,
              size: 24.sp, color: const Color(0xFF333333)),
        ),
      ],
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
        padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
        child: Column(
          children: [
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    icon: Icon(Icons.lock_outline,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '修改登录密码',
                    isLink: true,
                    onTap: () => context.push('/change-password'),
                  ),
                  CustomCell(
                    icon: Icon(Icons.shield_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '设置资金密码',
                    isLink: true,
                    border: false,
                    onTap: () => context.push('/withdraw-password'),
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
                    icon: Icon(Icons.info_outline,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '关于我们',
                    isLink: true,
                    onTap: () => context.push('/about-us'),
                  ),
                  CustomCell(
                    icon: Icon(Icons.article_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '注册信息',
                    isLink: true,
                    border: false,
                    onTap: () => context.push('/user-profile'),
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
                    icon: Icon(Icons.delete_outline,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '清除缓存',
                    isLink: true,
                    onTap: () => _clearCache(context),
                  ),
                  CustomCell(
                    icon: Icon(Icons.download_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: '版本',
                    value: 'v1.0.0',
                    border: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomButton(
                text: context.watch<AuthProvider>().isSubmitting
                    ? '退出中...'
                    : '退出登录',
                onPressed: context.watch<AuthProvider>().isSubmitting
                    ? null
                    : () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在清理缓存...')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存已清除')),
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

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SystemProvider>();
      if (!provider.hasLoadedConfig && !provider.isLoading) {
        provider.loadConfig();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final systemProvider = context.watch<SystemProvider>();
    final site = systemProvider.config.siteConfig;
    final title = _siteText(site?.title, fallback: '星汇演示');
    final description = _siteText(
      site?.desc ?? site?.appDesc,
      fallback: '专注于提供稳定、便捷、安全的线上娱乐服务体验。',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '关于我们'),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<SystemProvider>().loadConfig(refresh: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            if (systemProvider.isLoading && !systemProvider.hasLoadedConfig)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: const AppLoading(message: '正在加载站点信息...'),
              ),
            if (systemProvider.error != null)
              _buildErrorHint(systemProvider.error!),
            _buildHeader(site, title, description),
            SizedBox(height: 12.h),
            _buildInfoCard(site),
            SizedBox(height: 12.h),
            _buildDescriptionCard(description),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SiteConfig? site, String title, String description) {
    return CustomCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppNetworkImage(
              url: site?.logo ?? site?.appIcon,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.contain,
              errorWidget: Icon(
                Icons.business_outlined,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(SiteConfig? site) {
    final rows = <_AboutInfoRow>[
      _AboutInfoRow('站点域名', _siteText(site?.domain, fallback: 'xh-bet.com')),
      _AboutInfoRow('当前版本', _siteText(site?.appVersion, fallback: '1.0.0')),
      _AboutInfoRow('APP下载', _siteText(site?.appDownload, fallback: '暂未配置')),
      _AboutInfoRow('客服入口', _siteText(site?.serviceLink, fallback: '暂未配置')),
    ];
    final telegramLinks = site?.telegramLinks ?? const <String>[];
    if (telegramLinks.isNotEmpty) {
      rows.add(_AboutInfoRow('TG客服', telegramLinks.join('\n')));
    }

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            _buildInfoRow(rows[i], border: i != rows.length - 1),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_AboutInfoRow row, {required bool border}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: border
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.65),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              row.label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '平台介绍',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHint(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: AppColors.warning),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '站点信息加载失败，已展示默认内容。$message',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _siteText(String? value, {required String fallback}) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text == '-') return fallback;
    return _stripHtml(text);
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
  }
}

class _AboutInfoRow {
  const _AboutInfoRow(this.label, this.value);

  final String label;
  final String value;
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _imagePicker = ImagePicker();
  final _qqController = TextEditingController();
  final _telegramController = TextEditingController();
  bool _qqTouched = false;
  bool _telegramTouched = false;
  String? _lastProfileQq;
  String? _lastProfileTelegram;

  @override
  void dispose() {
    _qqController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final hasProfile = profile != null;
    final isPhoneBound = profile?.isPhoneBound ?? false;
    final isEmailBound = profile?.isEmailBound ?? false;
    final realNameText = !hasProfile
        ? '未填写'
        : profile.hasRealName
            ? profile.realName!.trim()
            : '未填写';
    final realNameLabel = !hasProfile ? '未认证' : profile.realNameStatusText;
    final phoneText = !hasProfile
        ? '138****8888'
        : isPhoneBound
            ? _maskPhone(profile.phone!)
            : '未绑定';
    final phoneLabel = !hasProfile
        ? '已绑定，不可修改'
        : isPhoneBound
            ? '已绑定，不可修改'
            : '未绑定';
    final emailText = !hasProfile
        ? '未绑定'
        : isEmailBound
            ? _maskEmail(profile.email!)
            : '未绑定';
    final emailLabel = !hasProfile
        ? '未绑定'
        : isEmailBound
            ? '已绑定，不可修改'
            : '未绑定';
    final genderText = profile?.genderText ?? '未设置';
    final birthdayText = profile?.birthdayText ?? '未设置';
    final avatarUrl = profile?.avatarUrl ?? profile?.img;
    final isUploadingAvatar = context.watch<UserProvider>().isUploadingAvatar;
    _syncInlineControllers(profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '个人资料'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    title: '头像',
                    value: isUploadingAvatar
                        ? '上传中...'
                        : avatarUrl == null || avatarUrl.trim().isEmpty
                            ? '默认头像'
                            : '已设置',
                    isLink: true,
                    onTap:
                        isUploadingAvatar ? null : () => _pickAvatar(context),
                  ),
                  CustomCell(
                    title: '实名认证',
                    value: realNameText,
                    label: realNameLabel,
                    isLink: true,
                    onTap: () => context.push('/real-name'),
                  ),
                  CustomCell(
                    title: '绑定手机号',
                    value: phoneText,
                    label: phoneLabel,
                    isLink: !isPhoneBound,
                    onTap:
                        isPhoneBound ? null : () => context.push('/bind-phone'),
                  ),
                  CustomCell(
                    title: '绑定邮箱',
                    value: emailText,
                    label: emailLabel,
                    isLink: !isEmailBound,
                    border: false,
                    onTap:
                        isEmailBound ? null : () => context.push('/bind-email'),
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
                    title: '性别',
                    value: genderText,
                    isLink: true,
                    onTap: () => _editGender(context, profile),
                  ),
                  CustomCell(
                    title: '出生日期',
                    value: birthdayText,
                    isLink: true,
                    onTap: () => _editBirthday(context, profile),
                  ),
                  _InlineProfileField(
                    title: 'QQ',
                    controller: _qqController,
                    hintText: '请输入 QQ',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _qqTouched = true,
                  ),
                  _InlineProfileField(
                    title: 'Telegram',
                    controller: _telegramController,
                    hintText: '请输入 Telegram',
                    border: false,
                    onChanged: (_) => _telegramTouched = true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomButton(
                text: context.watch<UserProvider>().isSubmitting
                    ? '保存中...'
                    : '保存',
                onPressed: context.watch<UserProvider>().isSubmitting
                    ? null
                    : () => _saveProfileField(
                          context,
                          UserProfileUpdateRequest(
                            telegram: _telegramController.text.trim(),
                            realName: profile?.realName ?? '',
                            phone: profile?.phone ?? '',
                            areaCode: '+86',
                            gender: profile?.gender ?? '',
                            bornTime: profile?.bornTime ?? '',
                            qq: _qqController.text.trim(),
                            email: profile?.email ?? '',
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

  void _syncInlineControllers(UserProfile? profile) {
    final nextQq = profile?.qq?.trim() ?? '';
    final nextTelegram = profile?.telegram?.trim() ?? '';
    if (!_qqTouched && nextQq != _lastProfileQq) {
      _qqController.text = nextQq;
      _lastProfileQq = nextQq;
    }
    if (!_telegramTouched && nextTelegram != _lastProfileTelegram) {
      _telegramController.text = nextTelegram;
      _lastProfileTelegram = nextTelegram;
    }
  }

  String _maskPhone(String value) {
    final text = value.trim();
    if (text.length < 7) return text;
    return '${text.substring(0, 3)}****${text.substring(text.length - 4)}';
  }

  String _maskEmail(String value) {
    final text = value.trim();
    final atIndex = text.indexOf('@');
    if (atIndex <= 1) return text;
    return '${text.substring(0, 1)}***${text.substring(atIndex)}';
  }

  Future<void> _pickAvatar(BuildContext context) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image == null || !context.mounted) return;
      final bytes = await image.readAsBytes();
      if (bytes.isEmpty || !context.mounted) return;
      await context.read<UserProvider>().uploadAvatar(
            bytes: bytes,
            filename: image.name.isEmpty ? 'avatar.jpg' : image.name,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像已更新')),
      );
    } on MissingPluginException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片选择组件未加载，请完整重启应用后重试')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFormErrorMessage(error, '头像上传失败'))),
      );
    }
  }

  Future<void> _editGender(BuildContext context, UserProfile? profile) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('男'),
              onTap: () => Navigator.of(sheetContext).pop('男'),
            ),
            ListTile(
              title: const Text('女'),
              onTap: () => Navigator.of(sheetContext).pop('女'),
            ),
            ListTile(
              title: const Text('保密'),
              onTap: () => Navigator.of(sheetContext).pop('保密'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await _saveProfileField(
      context,
      UserProfileUpdateRequest(gender: selected),
    );
  }

  Future<void> _editBirthday(BuildContext context, UserProfile? profile) async {
    final currentDate = DateTime.tryParse(profile?.bornTime ?? '');
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (selected == null || !context.mounted) return;
    final dateText = selected.toIso8601String().split('T').first;
    await _saveProfileField(
      context,
      UserProfileUpdateRequest(bornTime: dateText),
    );
  }

  Future<void> _saveProfileField(
    BuildContext context,
    UserProfileUpdateRequest request,
  ) async {
    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.updateProfile(request);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      _qqTouched = false;
      _telegramTouched = false;
      _lastProfileQq = _qqController.text.trim();
      _lastProfileTelegram = _telegramController.text.trim();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFormErrorMessage(error, '保存失败'))),
      );
    }
  }
}

class _InlineProfileField extends StatelessWidget {
  const _InlineProfileField({
    required this.title,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.border = true,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool border;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: border
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 5,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class BankCardListScreen extends StatefulWidget {
  const BankCardListScreen({super.key});

  @override
  State<BankCardListScreen> createState() => _BankCardListScreenState();
}

class _BankCardListScreenState extends State<BankCardListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final cards = walletProvider.cards;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '银行卡管理'),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCards,
              child: _buildBody(walletProvider, cards),
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

  Future<void> _refreshCards() async {
    await context.read<WalletProvider>().loadCards(refresh: true);
  }

  Widget _buildBody(
    WalletProvider walletProvider,
    List<WalletCard> cards,
  ) {
    if (walletProvider.isCardsLoading && cards.isEmpty) {
      return const AppLoading(message: '卡包加载中...');
    }

    if (walletProvider.cardsError != null && cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          SizedBox(height: 96.h),
          AppError(
            message: '卡包加载失败：${walletProvider.cardsError}',
            onRetry: () => walletProvider.loadCards(refresh: true),
          ),
        ],
      );
    }

    if (cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: const [
          AppEmpty(
            title: '暂无卡包',
            description: '绑定银行卡或虚拟币地址后会展示在这里',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: cards.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return _buildWalletCard(cards[index]);
      },
    );
  }

  Widget _buildWalletCard(WalletCard card) {
    final color = _colorForCard(card);
    return _buildBankCard(
      bankName: card.displayTitle.isEmpty ? card.typeName : card.displayTitle,
      cardType: card.displayAlias.isEmpty
          ? card.typeName
          : '${card.typeName} · ${card.displayAlias}',
      cardNumber: card.maskedCard.isEmpty ? '暂无卡号' : card.maskedCard,
      color: color,
      icon: _iconForCard(card),
      imageUrl: card.imageUrl,
      qrCodeUrl: card.qrCodeUrl,
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String cardType,
    required String cardNumber,
    required Color color,
    required IconData icon,
    String? imageUrl,
    String? qrCodeUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final hasQrCode = qrCodeUrl != null && qrCodeUrl.trim().isNotEmpty;
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
                padding: EdgeInsets.all(hasImage ? 4.w : 8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: hasImage
                    ? AppNetworkImage(
                        url: imageUrl,
                        width: 32.w,
                        height: 32.w,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(16.r),
                        errorWidget:
                            Icon(icon, color: Colors.white, size: 24.sp),
                      )
                    : Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasQrCode) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showQrCode(qrCodeUrl),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_2, size: 14.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          '二维码',
                          style:
                              TextStyle(fontSize: 11.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  void _showQrCode(String? url) {
    final imageUrl = url?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '收款二维码',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              AppNetworkImage(
                url: imageUrl,
                width: 220.w,
                height: 220.w,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(12.r),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForCard(WalletCard card) {
    if (card.isCrypto) return const Color(0xFF16A085);
    if (card.isAlipay) return const Color(0xFF1677FF);
    return const Color(0xFF1E88E5);
  }

  IconData _iconForCard(WalletCard card) {
    if (card.isCrypto) return Icons.currency_bitcoin;
    if (card.isAlipay) return Icons.payments_outlined;
    return Icons.account_balance;
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
      body: RefreshIndicator(
        onRefresh: _refreshVipLevels,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              if (userProvider.isVipLevelsLoading && vipLevels.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: const AppLoading(message: 'VIP 信息加载中...'),
                ),
              if (userProvider.vipLevelsError != null && vipLevels.isEmpty)
                _buildVipFallbackNotice(userProvider.vipLevelsError!),
              _buildProgressCard(userProvider),
              SizedBox(height: 16.h),
              _buildVipLevelCard(profile, vipLevels),
              SizedBox(height: 16.h),
              _buildRulesCard(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshVipLevels() async {
    try {
      await context.read<UserProvider>().loadVipLevels(refresh: true);
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      setState(() {
        _selectedIndex = _indexForLevel(
          userProvider.vipLevels,
          _computedCurrentLevel(userProvider),
        );
      });
    } catch (_) {}
  }

  Widget _buildVipFallbackNotice(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFD9A1)),
      ),
      child: Text(
        'VIP 信息暂未同步，当前展示默认等级规则。$message',
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFFB36B00),
          height: 1.4,
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
      final recharge = _currentRecharge(userProvider);
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
          profile?.recharge ??
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

  double _currentRecharge(UserProvider userProvider) {
    final profile = userProvider.profile;
    return _toDouble(
      profile?.levelData?.recharge ??
          profile?.recharge ??
          profile?.totalRecharge ??
          profile?.totalDeposit ??
          profile?.rechargeAmount ??
          userProvider.vipOverview?.totalDeposit,
    );
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
      _currentRecharge(userProvider),
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

class _MessageScreenState extends State<MessageScreen> {
  int _activeTab = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MessageProvider>().loadMessages();
    });
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 120.h) return;
    context.read<MessageProvider>().loadMore();
  }

  List<UserMessage> _filteredMessages(List<UserMessage> messages) {
    if (_activeTab == 1) return messages.where((item) => !item.isRead).toList();
    if (_activeTab == 2) return messages.where((item) => item.isRead).toList();
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '消息中心'),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          final messages = _filteredMessages(provider.messages);
          return Column(
            children: [
              _buildTabs(provider.unreadCount),
              Expanded(
                child: provider.isLoading && provider.messages.isEmpty
                    ? const AppLoading(message: '消息加载中...')
                    : _buildMessageList(context, provider, messages),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs(int unreadCount) {
    final tabs = [
      ('全部', unreadCount),
      ('未读', unreadCount),
      ('已读', 0),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final active = _activeTab == index;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: active
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: active ? 8.r : 4.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      tab.$1,
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: active ? FontWeight.bold : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (tab.$2 > 0)
                    Positioned(
                      top: -6.h,
                      right: -8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D4F),
                          borderRadius: BorderRadius.circular(10.r),
                          border:
                              Border.all(color: AppColors.background, width: 2),
                        ),
                        child: Text(
                          '${tab.$2}',
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    MessageProvider provider,
    List<UserMessage> messages,
  ) {
    if (messages.isEmpty) {
      return const AppEmpty(title: '暂无消息');
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMessages(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(12.w),
        itemCount: messages.length + 1,
        itemBuilder: (context, index) {
          if (index == messages.length) {
            if (provider.isLoadingMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Center(
                child: Text(
                  provider.hasMore ? '' : '没有更多了',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.sp),
                ),
              ),
            );
          }

          return _buildMessageCard(context, provider, messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    MessageProvider provider,
    UserMessage message,
  ) {
    final title = _textFallback(message.title, '系统通知');
    final content = _textFallback(message.content, '暂无内容');
    final time = _textFallback(message.createdAt, '');
    return GestureDetector(
      onTap: () async {
        try {
          await provider.markRead(message);
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFormErrorMessage(error, '标记已读失败'))),
          );
        }
      },
      child: CustomCard(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '详情',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 13.sp),
                        ),
                        Icon(Icons.chevron_right,
                            color: AppColors.primary, size: 16.sp),
                      ],
                    ),
                  ],
                ),
                if (!message.isRead)
                  Positioned(
                    top: 0,
                    right: -8.w,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4D4F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              time,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  String _textFallback(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _contentController = TextEditingController();
  FeedbackType? _selectedType;
  final int _maxLength = 300;
  final ImagePicker _imagePicker = ImagePicker();
  final List<_FeedbackImage> _images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<FeedbackProvider>();
      provider.loadTypes();
      _selectedType ??= provider.types.firstOrNull;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showTypeSelector() {
    final provider = context.read<FeedbackProvider>();
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final types = provider.types;
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
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      return ListTile(
                        title: Text(
                          _feedbackTypeTitle(type),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          setState(() => _selectedType = type);
                          context.pop();
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = context.watch<FeedbackProvider>();
    _selectedType ??= feedbackProvider.types.firstOrNull;

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
              onTap: feedbackProvider.isTypesLoading ? null : _showTypeSelector,
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
                      feedbackProvider.isTypesLoading
                          ? '加载中...'
                          : _feedbackTypeTitle(_selectedType),
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
            _buildImageGrid(feedbackProvider),
            SizedBox(height: 40.h),
            CustomButton(
              text: feedbackProvider.isSubmitting ? '提交中...' : '提交反馈',
              onPressed: feedbackProvider.isSubmitting ? null : _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(FeedbackProvider feedbackProvider) {
    final itemCount = _images.length + (_images.length < 3 ? 1 : 0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _images.length) {
          return _FeedbackImageTile(
            image: _images[index],
            onDelete: () => setState(() => _images.removeAt(index)),
          );
        }
        return _FeedbackAddImageTile(
          isUploading: feedbackProvider.isUploadingImage,
          onTap: feedbackProvider.isUploadingImage ? null : _pickFeedbackImage,
        );
      },
    );
  }

  Future<void> _pickFeedbackImage() async {
    if (_images.length >= 3) return;
    try {
      final files =
          await _imagePicker.pickMultiImage(limit: 3 - _images.length);
      if (files.isEmpty) return;
      for (final file in files.take(3 - _images.length)) {
        await _uploadFeedbackImage(file);
      }
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片选择组件未加载，请完整重启应用后重试')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('选择图片失败')),
      );
    }
  }

  Future<void> _uploadFeedbackImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    try {
      final result = await context.read<FeedbackProvider>().uploadFeedbackImage(
            bytes: bytes,
            filename: file.name,
          );
      final imageUrl = (result.url?.trim().isNotEmpty ?? false)
          ? result.url!.trim()
          : result.path?.trim();
      if (imageUrl == null || imageUrl.isEmpty) {
        throw const FormatException('Upload response missing image url');
      }
      if (!mounted) return;
      setState(() => _images.add(_FeedbackImage(url: imageUrl)));
    } catch (_) {
      if (!mounted) return;
      final error = context.read<FeedbackProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '图片上传失败')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    final selectedType = _selectedType;
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择反馈分类')),
      );
      return;
    }
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入反馈内容')),
      );
      return;
    }

    try {
      await context.read<FeedbackProvider>().submitFeedback(
            SubmitFeedbackRequest(
              id: selectedType.id,
              text: content,
              img: _images.map((image) => image.url).join(','),
            ),
          );
      if (!mounted) return;
      _contentController.clear();
      setState(() => _images.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('反馈成功')),
      );
      context.push('/feedback-records');
    } catch (_) {
      if (!mounted) return;
      final error = context.read<FeedbackProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '提交反馈失败')),
      );
    }
  }

  String _feedbackTypeTitle(FeedbackType? type) {
    final title = type?.title?.trim();
    return title == null || title.isEmpty ? '请选择' : title;
  }
}

class _FeedbackImage {
  const _FeedbackImage({required this.url});

  final String url;
}

class _FeedbackImageTile extends StatelessWidget {
  const _FeedbackImageTile({required this.image, required this.onDelete});

  final _FeedbackImage image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: AppNetworkImage(
            url: image.url,
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Positioned(
          top: -6.w,
          right: -6.w,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Color(0xCC000000),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 14.sp),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackAddImageTile extends StatelessWidget {
  const _FeedbackAddImageTile({required this.isUploading, required this.onTap});

  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploading)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.add_a_photo,
                  color: AppColors.textSecondary, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              isUploading ? '上传中' : '添加图片',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackRecordsScreen extends StatefulWidget {
  const FeedbackRecordsScreen({super.key});

  @override
  State<FeedbackRecordsScreen> createState() => _FeedbackRecordsScreenState();
}

class _FeedbackRecordsScreenState extends State<FeedbackRecordsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FeedbackProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 120.h) return;
    context.read<FeedbackProvider>().loadMoreRecords();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = context.watch<FeedbackProvider>();
    final records = feedbackProvider.records;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '反馈记录'),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<FeedbackProvider>().loadRecords(refresh: true),
        child: feedbackProvider.isLoading && !feedbackProvider.hasRemoteRecords
            ? const AppLoading(message: '加载中...')
            : records.isEmpty
                ? const AppEmpty(title: '暂无反馈记录')
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: records.length +
                        (feedbackProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= records.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildRecordCard(records[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildRecordCard(FeedbackRecord record) {
    final isProcessing = !record.hasReply;
    return CustomCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _textFallback(record.title, '默认分类'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _textFallback(record.createdAt, '刚刚'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isProcessing
                      ? const Color(0xFFFFF7E6)
                      : const Color(0xFFE6F7ED),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  record.statusText,
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
            _textFallback(record.content, '暂无内容'),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (record.hasReply) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '回复：${record.reply}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _textFallback(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}
