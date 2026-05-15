import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
      context.read<UserProvider>().loadDayRevenue().catchError((_) {});
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
    final dayRevenue = userProvider.dayRevenue;

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
                              _profileText(
                                'profile.accountId',
                                namedArgs: {'id': accountId},
                              ),
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
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _profileText('user.walletBalance'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14.sp),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.visibility_outlined,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 16.sp),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.refresh,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 16.sp),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    _profileText('user.refresh'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14.sp),
                                  ),
                                ),
                              ],
                            ),
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
                          Expanded(
                            child: Text(
                              balance,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
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
                                    Flexible(
                                      child: Text(
                                          _profileText('common.deposit'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500)),
                                    ),
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
                                    Flexible(
                                      child: Text(
                                          _profileText('common.withdraw'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500)),
                                    ),
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
                        Expanded(
                          child: Row(
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
                              Flexible(
                                child: Text(_profileText('profile.todayProfit'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                              ),
                              SizedBox(width: 8.w),
                              Text(_profileText('profile.todayDate'),
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: userProvider.isDayRevenueLoading
                              ? null
                              : () => context
                                  .read<UserProvider>()
                                  .loadDayRevenue(refresh: true)
                                  .catchError((_) {}),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh,
                                  color: const Color(0xFF4A8AF4), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                  userProvider.isDayRevenueLoading
                                      ? _profileText('common.loading')
                                      : _profileText('user.refresh'),
                                  style: TextStyle(
                                      color: const Color(0xFF4A8AF4),
                                      fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProfitItem(
                            context,
                            value: (dayRevenue?.betCount ?? 0).toString(),
                            label: _profileText('profile.betCount'),
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 20.h,
                            color: Colors.grey.withValues(alpha: 0.2)),
                        Expanded(
                          child: _buildProfitItem(
                            context,
                            value: _amountText(dayRevenue?.profitLoss,
                                fallback: '0.00'),
                            label: _profileText('profile.totalProfitLoss'),
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 20.h,
                            color: Colors.grey.withValues(alpha: 0.2)),
                        Expanded(
                          child: _buildProfitItem(
                            context,
                            value: _amountText(dayRevenue?.unclaimedRebate,
                                fallback: '0.00'),
                            label: _profileText('profile.unclaimedRebate'),
                            showDot: (dayRevenue?.unclaimedRebate ?? 0) > 0,
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
                        Expanded(
                          child: Text(_profileText('profile.moreServices'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
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
                        _buildServiceItem(
                            Icons.grid_view_rounded,
                            _profileText('profile.gameManagement'),
                            context,
                            '/game-management'),
                        _buildServiceItem(
                            Icons.account_balance_wallet_outlined,
                            _profileText('profile.fundManagement'),
                            context,
                            '/fund-management'),
                        _buildServiceItem(
                            Icons.swap_horiz,
                            _profileText('profile.venueBalance'),
                            context,
                            '/wallet'),
                        _buildServiceItem(
                            Icons.credit_card_outlined,
                            _profileText('profile.bankCard'),
                            context,
                            '/cards'),
                        _buildServiceItem(Icons.reply_outlined,
                            _profileText('profile.share'), context, '/share'),
                        _buildServiceItem(Icons.workspace_premium_outlined,
                            'VIP', context, '/vip'),
                        _buildServiceItem(
                            Icons.chat_bubble_outline,
                            _profileText('profile.feedback'),
                            context,
                            '/feedback'),
                        _buildServiceItem(Icons.lightbulb_outline,
                            _profileText('profile.comingSoon'), context, null),
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

  Widget _buildProfitItem(
    BuildContext context, {
    required String value,
    required String label,
    bool showDot = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/game-manage?tab=rebate'),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: const Color(0xFF4A8AF4), fontSize: 12.sp)),
                    if (showDot)
                      Positioned(
                        right: -5.w,
                        top: -3.h,
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
              ),
              Icon(Icons.chevron_right,
                  color: const Color(0xFF4A8AF4), size: 12.sp),
            ],
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

  String _profileText(
    String key, {
    Map<String, String>? namedArgs,
  }) {
    return key.tr(namedArgs: namedArgs);
  }
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'settings.title'.tr()),
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
                    title: 'settings.changeLoginPassword'.tr(),
                    isLink: true,
                    onTap: () => context.push('/change-password'),
                  ),
                  CustomCell(
                    icon: Icon(Icons.shield_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: 'settings.setFundPassword'.tr(),
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
                    title: 'settings.aboutUs'.tr(),
                    isLink: true,
                    onTap: () => context.push('/about-us'),
                  ),
                  CustomCell(
                    icon: Icon(Icons.article_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: 'settings.registrationInfo'.tr(),
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
                    title: 'settings.clearCache'.tr(),
                    isLink: true,
                    onTap: () => _clearCache(context),
                  ),
                  CustomCell(
                    icon: Icon(Icons.download_outlined,
                        size: 18.sp, color: AppColors.textPrimary),
                    title: 'settings.version'.tr(),
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
                    ? 'settings.loggingOut'.tr()
                    : 'settings.logout'.tr(),
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
      SnackBar(content: Text('settings.clearingCache'.tr())),
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('settings.cacheCleared'.tr())),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('settings.logoutConfirmTitle'.tr()),
        content: Text('settings.logoutConfirmMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('common.confirm'.tr()),
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
    final title =
        _siteText(site?.title, fallback: 'about.fallbackSiteName'.tr());
    final description = _siteText(
      site?.desc ?? site?.appDesc,
      fallback: 'about.fallbackDescription'.tr(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'about.title'.tr()),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<SystemProvider>().loadConfig(refresh: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            if (systemProvider.isLoading && !systemProvider.hasLoadedConfig)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AppLoading(message: 'about.loading'.tr()),
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
      _AboutInfoRow(
          'about.domain'.tr(), _siteText(site?.domain, fallback: 'xh-bet.com')),
      _AboutInfoRow(
          'about.version'.tr(), _siteText(site?.appVersion, fallback: '1.0.0')),
      _AboutInfoRow('about.appDownload'.tr(),
          _siteText(site?.appDownload, fallback: 'common.notConfigured'.tr())),
      _AboutInfoRow('about.serviceEntry'.tr(),
          _siteText(site?.serviceLink, fallback: 'common.notConfigured'.tr())),
    ];
    final telegramLinks = site?.telegramLinks ?? const <String>[];
    if (telegramLinks.isNotEmpty) {
      rows.add(_AboutInfoRow(
          'about.telegramService'.tr(), telegramLinks.join('\n')));
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
            'about.platformIntro'.tr(),
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
              'about.loadFailedWithDefault'.tr(namedArgs: {'message': message}),
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
    final normalized = _stripHtml(text);
    if (normalized == '本次新增功能旨在优化操作效率、完善业务场景，提升用户使用体验，适配日常运营及管理需求，无额外操作') {
      return 'about.fallbackDescription'.tr();
    }
    return normalized;
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
        ? 'common.notFilled'.tr()
        : profile.hasRealName
            ? profile.realName!.trim()
            : 'common.notFilled'.tr();
    final realNameLabel = !hasProfile
        ? 'account.unverified'.tr()
        : _localizedProfileStatus(profile.realNameStatusText);
    final phoneText = !hasProfile
        ? '138****8888'
        : isPhoneBound
            ? _maskPhone(profile.phone!)
            : 'common.notBound'.tr();
    final phoneLabel = !hasProfile
        ? 'account.boundReadonly'.tr()
        : isPhoneBound
            ? 'account.boundReadonly'.tr()
            : 'common.notBound'.tr();
    final emailText = !hasProfile
        ? 'common.notBound'.tr()
        : isEmailBound
            ? _maskEmail(profile.email!)
            : 'common.notBound'.tr();
    final emailLabel = !hasProfile
        ? 'common.notBound'.tr()
        : isEmailBound
            ? 'account.boundReadonly'.tr()
            : 'common.notBound'.tr();
    final genderText = _localizedGenderText(profile?.genderText);
    final birthdayText = profile?.birthdayText ?? 'common.notSet'.tr();
    final avatarUrl = profile?.avatarUrl ?? profile?.img;
    final isUploadingAvatar = context.watch<UserProvider>().isUploadingAvatar;
    _syncInlineControllers(profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'account.profileTitle'.tr()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  CustomCell(
                    title: 'account.avatar'.tr(),
                    value: isUploadingAvatar
                        ? 'account.uploading'.tr()
                        : avatarUrl == null || avatarUrl.trim().isEmpty
                            ? 'account.defaultAvatar'.tr()
                            : 'account.configured'.tr(),
                    isLink: true,
                    onTap:
                        isUploadingAvatar ? null : () => _pickAvatar(context),
                  ),
                  CustomCell(
                    title: 'account.realNameVerification'.tr(),
                    value: realNameText,
                    label: realNameLabel,
                    isLink: true,
                    onTap: () => context.push('/real-name'),
                  ),
                  CustomCell(
                    title: 'account.bindPhone'.tr(),
                    value: phoneText,
                    label: phoneLabel,
                    isLink: !isPhoneBound,
                    onTap:
                        isPhoneBound ? null : () => context.push('/bind-phone'),
                  ),
                  CustomCell(
                    title: 'account.bindEmail'.tr(),
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
                    title: 'account.gender'.tr(),
                    value: genderText,
                    isLink: true,
                    onTap: () => _editGender(context, profile),
                  ),
                  CustomCell(
                    title: 'account.birthday'.tr(),
                    value: birthdayText,
                    isLink: true,
                    onTap: () => _editBirthday(context, profile),
                  ),
                  _InlineProfileField(
                    title: 'QQ',
                    controller: _qqController,
                    hintText: 'account.enterQq'.tr(),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _qqTouched = true,
                  ),
                  _InlineProfileField(
                    title: 'Telegram',
                    controller: _telegramController,
                    hintText: 'account.enterTelegram'.tr(),
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
                    ? 'common.saving'.tr()
                    : 'common.save'.tr(),
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

  String _localizedProfileStatus(String value) {
    final text = value.trim();
    if (text == '1' || text.toLowerCase() == 'verified') {
      return 'account.verified'.tr();
    }
    if (text == '0' || text.toLowerCase() == 'unverified') {
      return 'account.unverified'.tr();
    }
    return text.isEmpty ? 'account.unverified'.tr() : text;
  }

  String _localizedGenderText(String? value) {
    final text = value?.trim();
    if (text == '1' || text?.toLowerCase() == 'male') {
      return 'account.male'.tr();
    }
    if (text == '2' || text?.toLowerCase() == 'female') {
      return 'account.female'.tr();
    }
    if (text == '0' || text?.toLowerCase() == 'private') {
      return 'account.private'.tr();
    }
    return text == null || text.isEmpty ? 'common.notSet'.tr() : text;
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
        SnackBar(content: Text('account.avatarUpdated'.tr())),
      );
    } on MissingPluginException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('account.imagePickerMissing'.tr())),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(userFormErrorMessage(
                error, 'account.avatarUploadFailed'.tr()))),
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
              title: Text('account.male'.tr()),
              onTap: () => Navigator.of(sheetContext).pop('1'),
            ),
            ListTile(
              title: Text('account.female'.tr()),
              onTap: () => Navigator.of(sheetContext).pop('2'),
            ),
            ListTile(
              title: Text('account.private'.tr()),
              onTap: () => Navigator.of(sheetContext).pop('0'),
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
        SnackBar(content: Text('account.saveSuccess'.tr())),
      );
      _qqTouched = false;
      _telegramTouched = false;
      _lastProfileQq = _qqController.text.trim();
      _lastProfileTelegram = _telegramController.text.trim();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(userFormErrorMessage(error, 'account.saveFailed'.tr()))),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
      appBar: CustomNavBar(title: 'wallet.bankCardManagement'.tr()),
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
                  'wallet.addBankCard'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      return AppLoading(message: 'wallet.loadingCards'.tr());
    }

    if (walletProvider.cardsError != null && cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          SizedBox(height: 96.h),
          AppError(
            message: 'wallet.loadCardsFailed'.tr(
              namedArgs: {'message': walletProvider.cardsError!},
            ),
            onRetry: () => walletProvider.loadCards(refresh: true),
          ),
        ],
      );
    }

    if (cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          AppEmpty(
            title: 'wallet.emptyCards'.tr(),
            description: 'wallet.emptyCardsDesc'.tr(),
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
      cardNumber: card.maskedCard.isEmpty
          ? 'wallet.noCardNumber'.tr()
          : card.maskedCard,
      color: color,
      icon: _iconForCard(card),
      imageUrl: card.imageUrl,
      qrCodeUrl: card.qrCodeUrl,
      onDelete: () => _confirmDeleteCard(card),
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
    VoidCallback? onDelete,
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
                          'wallet.qrCode'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 11.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (onDelete != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onDelete,
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
                    child: Icon(
                      Icons.delete_outline,
                      size: 15.sp,
                      color: Colors.white,
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
                'wallet.receiptQrCode'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                child: Text('common.close'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCard(WalletCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('common.confirm'.tr()),
        content: Text(
            'wallet.deleteCardConfirm'.tr() == 'wallet.deleteCardConfirm'
                ? 'Confirm delete this card?'
                : 'wallet.deleteCardConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final walletProvider = context.read<WalletProvider>();
    try {
      await walletProvider.deleteCard(
        DeleteBankCardRequest(id: card.id),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'wallet.deleteCardSuccess'.tr() == 'wallet.deleteCardSuccess'
                    ? 'Deleted successfully'
                    : 'wallet.deleteCardSuccess'.tr())),
      );
    } catch (_) {
      if (!mounted) return;
      final error = walletProvider.deleteCardError ??
          ('wallet.deleteCardFailed'.tr() == 'wallet.deleteCardFailed'
              ? 'Delete failed'
              : 'wallet.deleteCardFailed'.tr());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
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
        'vip.sport': '0.30%',
        'vip.live': '0.40%',
        'vip.slot': '0.50%',
        'vip.poker': '0.40%',
        'vip.fishing': '0.50%',
        'vip.esports': '0.30%',
        'vip.lottery': '0.00%'
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
        'vip.sport': '0.40%',
        'vip.live': '0.50%',
        'vip.slot': '0.60%',
        'vip.poker': '0.50%',
        'vip.fishing': '0.60%',
        'vip.esports': '0.40%',
        'vip.lottery': '0.00%'
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
        'vip.sport': '0.45%',
        'vip.live': '0.55%',
        'vip.slot': '0.65%',
        'vip.poker': '0.55%',
        'vip.fishing': '0.65%',
        'vip.esports': '0.45%',
        'vip.lottery': '0.00%'
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
      appBar: CustomNavBar(title: 'vip.title'.tr()),
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
                  child: AppLoading(message: 'vip.loading'.tr()),
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
        'vip.fallbackNotice'.tr(namedArgs: {'message': message}),
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
        Expanded(
          child: Row(
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
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
          _buildTitleWithDot('vip.progressTitle'.tr(),
              rightWidget: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6B9CFF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                    'vip.currentLevel'.tr(
                      namedArgs: {'level': '${progress.currentLevel}'},
                    ),
                    style: TextStyle(
                        color: const Color(0xFF6B9CFF), fontSize: 11.sp)),
              )),
          if (progress.nextLevel != null) ...[
            SizedBox(height: 10.h),
            Text(
              'vip.nextLevel'.tr(
                namedArgs: {'level': '${progress.nextLevel}'},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: const Color(0xFF999999), fontSize: 12.sp),
            ),
          ],
          SizedBox(height: 24.h),
          _buildProgressBar(
            'vip.rechargeProgress'.tr(),
            progress.recharge,
            progress.nextRecharge,
            progress.rechargePercent,
          ),
          SizedBox(height: 20.h),
          _buildProgressBar(
            'vip.flowProgress'.tr(),
            progress.validBet,
            progress.nextValidBet,
            progress.flowPercent,
          ),
          SizedBox(height: 24.h),
          Text(
            progress.isMaxLevel
                ? 'vip.maxLevelHint'.tr()
                : 'vip.upgradeGapHint'.tr(namedArgs: {
                    'recharge': _formatMoney(progress.gapRecharge),
                    'flow': _formatMoney(progress.gapValidBet),
                  }),
            style: TextStyle(
                color: const Color(0xFF999999), fontSize: 12.sp, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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
          _buildTitleWithDot('vip.levelTitle'.tr()),
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
                  child: Text('vip.current'.tr(),
                      style: TextStyle(
                          color: const Color(0xFF6B9CFF), fontSize: 11.sp)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            selectedVipLevel == null
                ? 'vip.upgradeConditionFallback'.tr(namedArgs: {
                    'recharge': '${fallbackLevelData['recharge']}',
                    'turnover': '${fallbackLevelData['turnover']}',
                  })
                : 'vip.upgradeCondition'.tr(namedArgs: {
                    'recharge':
                        _formatDynamicAmount(selectedVipLevel.chargeLevel),
                    'flow': _formatDynamicAmount(selectedVipLevel.flowingLevel),
                  }),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666)),
          ),
          SizedBox(height: 24.h),
          Text('vip.benefitsTitle'.tr(),
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333))),
          SizedBox(height: 16.h),
          _buildListContainer([
            _buildListRow(
                'vip.upgradeBonus'.tr(),
                _vipValue(
                    selectedVipLevel?.levelGive, fallbackLevelData['upgrade'])),
            _buildListRow(
                'vip.weeklyBonus'.tr(),
                _vipValue(
                    selectedVipLevel?.weekRed, fallbackLevelData['weekly'])),
            _buildListRow(
                'vip.birthdayBonus'.tr(),
                _vipValue(selectedVipLevel?.birthdayGive,
                    fallbackLevelData['birthday'])),
            _buildListRow(
                'vip.dailyWithdrawCount'.tr(),
                selectedVipLevel?.dayCountDrawing == null
                    ? 'vip.times'.tr(namedArgs: {
                        'count': '${fallbackLevelData['dailyCount']}',
                      })
                    : 'vip.times'.tr(namedArgs: {
                        'count': '${selectedVipLevel!.dayCountDrawing}',
                      })),
            _buildListRow(
                'vip.dailyWithdrawLimit'.tr(),
                _vipValue(selectedVipLevel?.dayAmountDrawing,
                    fallbackLevelData['dailyLimit'])),
            _buildListRow(
                'vip.minWithdraw'.tr(),
                _vipValue(selectedVipLevel?.minDrawing,
                    fallbackLevelData['minWithdraw'])),
            _buildListRow(
                'vip.minRecharge'.tr(),
                _vipValue(selectedVipLevel?.minRecharge,
                    fallbackLevelData['minRecharge'])),
            _buildListRow(
                'vip.maxRecharge'.tr(),
                _vipValue(selectedVipLevel?.maxRecharge,
                    fallbackLevelData['maxRecharge']),
                showBorder: false),
          ]),
          SizedBox(height: 24.h),
          Text('vip.rebateTitle'.tr(),
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
                  isCurrent
                      ? 'vip.tabCurrent'.tr(namedArgs: {'title': levelTitle})
                      : levelTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          _buildTitleWithDot('vip.rulesTitle'.tr()),
          SizedBox(height: 20.h),
          _buildRuleText('vip.rule1'.tr()),
          _buildRuleText('vip.rule2'.tr()),
          _buildRuleText('vip.rule3'.tr()),
          _buildRuleText('vip.rule4'.tr()),
          _buildRuleText('vip.rule5'.tr()),
        ],
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
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
      MapEntry('vip.sport'.tr(),
          _rebateValue(selectedVipLevel?.sportBl, fallback['vip.sport'])),
      MapEntry('vip.live'.tr(),
          _rebateValue(selectedVipLevel?.liveBl, fallback['vip.live'])),
      MapEntry('vip.slot'.tr(),
          _rebateValue(selectedVipLevel?.gamesBl, fallback['vip.slot'])),
      MapEntry('vip.poker'.tr(),
          _rebateValue(selectedVipLevel?.pokerBl, fallback['vip.poker'])),
      MapEntry('vip.fishing'.tr(),
          _rebateValue(selectedVipLevel?.fishingBl, fallback['vip.fishing'])),
      MapEntry('vip.esports'.tr(),
          _rebateValue(selectedVipLevel?.gamingBl, fallback['vip.esports'])),
      MapEntry('vip.lottery'.tr(),
          _rebateValue(selectedVipLevel?.lotteryBl, fallback['vip.lottery'])),
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
      appBar: CustomNavBar(title: 'message.center'.tr()),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          final messages = _filteredMessages(provider.messages);
          return Column(
            children: [
              _buildTabs(provider.unreadCount),
              Expanded(
                child: provider.isLoading && provider.messages.isEmpty
                    ? AppLoading(message: 'message.loading'.tr())
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
      ('message.all'.tr(), unreadCount),
      ('message.unread'.tr(), unreadCount),
      ('message.read'.tr(), 0),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      return AppEmpty(title: 'message.empty'.tr());
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
                  provider.hasMore ? '' : 'common.noMore'.tr(),
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
    final title = _textFallback(message.title, 'message.systemNotice'.tr());
    final content = _textFallback(message.content, 'message.emptyContent'.tr());
    final time = _textFallback(message.createdAt, '');
    return GestureDetector(
      onTap: () async {
        try {
          await provider.markRead(message);
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(userFormErrorMessage(
                    error, 'message.markReadFailed'.tr()))),
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
                          'common.detail'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    if (text == null || text.isEmpty) return fallback;
    return text.startsWith('message.') ? text.tr() : text;
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
                  'feedback.selectType'.tr(),
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
        title: 'feedback.title'.tr(),
        rightText: 'feedback.records'.tr(),
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
              'feedback.type'.tr(),
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
                          ? 'common.loading'.tr()
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
                  'feedback.description'.tr(),
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
                  hintText: 'feedback.descriptionHint'.tr(),
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14.sp),
                  border: InputBorder.none,
                  counterText: '', // Hide default counter
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'feedback.uploadImages'.tr(),
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
              text: feedbackProvider.isSubmitting
                  ? 'common.submitting'.tr()
                  : 'feedback.submit'.tr(),
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
        SnackBar(content: Text('account.imagePickerMissing'.tr())),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback.pickImageFailed'.tr())),
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
        SnackBar(content: Text(error ?? 'feedback.imageUploadFailed'.tr())),
      );
    }
  }

  Future<void> _handleSubmit() async {
    final selectedType = _selectedType;
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback.selectCategory'.tr())),
      );
      return;
    }
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback.enterContent'.tr())),
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
        SnackBar(content: Text('feedback.submitSuccess'.tr())),
      );
      context.push('/feedback-records');
    } catch (_) {
      if (!mounted) return;
      final error = context.read<FeedbackProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'feedback.submitFailed'.tr())),
      );
    }
  }

  String _feedbackTypeTitle(FeedbackType? type) {
    final title = type?.title?.trim();
    if (title == null || title.isEmpty) return 'common.select'.tr();
    return title.startsWith('feedback.') ? title.tr() : title;
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
              isUploading
                  ? 'common.uploadingNoDots'.tr()
                  : 'feedback.addImage'.tr(),
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
      appBar: CustomNavBar(title: 'feedback.records'.tr()),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<FeedbackProvider>().loadRecords(refresh: true),
        child: feedbackProvider.isLoading && !feedbackProvider.hasRemoteRecords
            ? AppLoading(message: 'common.loading'.tr())
            : records.isEmpty
                ? AppEmpty(title: 'feedback.emptyRecords'.tr())
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
                        _textFallback(
                            record.title, 'feedback.defaultCategory'.tr()),
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
                      _textFallback(record.createdAt, 'feedback.justNow'.tr()),
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
            _textFallback(record.content, 'message.emptyContent'.tr()),
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
                '${'feedback.reply'.tr()}${_textFallback(record.reply, '')}',
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
    if (text == null || text.isEmpty) return fallback;
    return text.startsWith('feedback.') ? text.tr() : text;
  }
}
