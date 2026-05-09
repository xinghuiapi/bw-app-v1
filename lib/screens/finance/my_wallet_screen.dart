import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/wallet/wallet_models.dart';
import '../../providers/user/user_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_loading.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  static const _fallbackVenues = [
    VenueBalance(id: 1, title: 'PA接口', code: 'AG', money: 0),
    VenueBalance(id: 3, title: 'DG视讯', code: 'DG', money: 0),
    VenueBalance(id: 4, title: '乐游棋牌', code: 'LEG', money: 0),
    VenueBalance(id: 5, title: '沙巴体育', code: 'IBC', money: 0),
    VenueBalance(id: 6, title: '三晟体育', code: 'SS', money: 0),
    VenueBalance(id: 7, title: '雷火电竞', code: 'TFG', money: 0),
    VenueBalance(id: 8, title: '百盛棋牌', code: 'BSQP', money: 0),
    VenueBalance(id: 9, title: '欧博视讯', code: 'AB', money: 0),
    VenueBalance(id: 10, title: 'FB体育', code: 'FB', money: 0),
  ];

  bool _showBalance = true;
  VenueBalance? _activeVenue;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().loadWalletOverview();
      context
          .read<UserProvider>()
          .loadProfile(refresh: true)
          .catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: '我的钱包',
        rightIcon: Text(
          '转账记录',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        onClickRight: () {
          context.push('/fund-manage?tab=transfer');
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWallet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWalletCard(walletProvider, userProvider),
              _buildVenueModeCard(userProvider),
              _buildVenueListCard(walletProvider),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWallet() async {
    await Future.wait([
      context.read<WalletProvider>().loadWalletOverview(refresh: true),
      context
          .read<UserProvider>()
          .loadProfile(refresh: true)
          .catchError((_) {}),
    ]);
  }

  Widget _buildWalletCard(
    WalletProvider walletProvider,
    UserProvider userProvider,
  ) {
    final profile = userProvider.profile;
    final symbol = profile?.symbol?.trim().isNotEmpty == true
        ? profile!.symbol!.trim()
        : '¥';
    final fallbackBalance = _toDouble(profile?.balance);
    final balance = walletProvider.realtimeBalance?.balance ?? fallbackBalance;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
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
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBalance = !_showBalance;
                      });
                    },
                    child: Icon(
                      _showBalance
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: walletProvider.isBalanceLoading
                    ? null
                    : () => context
                        .read<WalletProvider>()
                        .loadRealtimeBalance(refresh: true),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '刷新',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$symbol ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _showBalance ? _formatMoney(balance) : '***',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (walletProvider.balanceError != null) ...[
            SizedBox(height: 8.h),
            Text(
              '实时余额暂未同步，当前展示账户资料余额。${walletProvider.balanceError}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.sp,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 24.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
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
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.currency_yen,
                              color: Colors.white, size: 14.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '充值',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 20.h,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/withdraw'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.account_balance_wallet,
                              color: Colors.white, size: 14.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '提现',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }

  Widget _buildVenueModeCard(UserProvider userProvider) {
    final transferMode = userProvider.profile?.transfer;
    final isAutoTransfer = transferMode == 2;
    final walletProvider = context.watch<WalletProvider>();
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleWithDot('场馆模式'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoSwitch(
                    value: isAutoTransfer,
                    activeTrackColor: AppColors.primary,
                    onChanged: walletProvider.isTransferModeSubmitting
                        ? null
                        : (value) {
                            _setTransferMode(value);
                          },
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: walletProvider.isTransferModeSubmitting
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          if (walletProvider.transferModeError != null) ...[
            SizedBox(height: 8.h),
            Text(
              walletProvider.transferModeError!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.danger,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            '默认开启自动转账模式（余额自动携带进入场馆，关闭后需手动转入/转出）',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueListCard(WalletProvider walletProvider) {
    final showFallback =
        walletProvider.venuesError != null && walletProvider.venues.isEmpty;
    final venues = showFallback ? _fallbackVenues : walletProvider.venues;
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleWithDot('场馆列表'),
              GestureDetector(
                onTap: walletProvider.isRecyclingVenues ? null : _recycleVenues,
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: walletProvider.isRecyclingVenues
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      walletProvider.isRecyclingVenues ? '归户中...' : '资金一键归户',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: walletProvider.isRecyclingVenues
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (walletProvider.isVenuesLoading && venues.isEmpty) ...[
            SizedBox(height: 16.h),
            const AppLoading(message: '场馆余额加载中...'),
          ] else if (venues.isEmpty) ...[
            SizedBox(height: 16.h),
            const AppEmpty(
              title: '暂无场馆余额',
              description: '登录后可查看各场馆余额',
            ),
          ] else ...[
            if (walletProvider.venueActionError != null) ...[
              SizedBox(height: 12.h),
              _buildActionError(walletProvider.venueActionError!),
            ],
            if (showFallback) ...[
              SizedBox(height: 12.h),
              _buildFallbackNotice(walletProvider.venuesError!),
            ],
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio:
                    1.6, // Adjusted for typical width/height ratio
              ),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return GestureDetector(
                  onTap: showFallback ? null : () => _openVenueSheet(venue),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          venue.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¥ ${_formatMoney(venue.money)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.refresh,
                                color: AppColors.primary, size: 14.sp),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setTransferMode(bool enabled) async {
    final walletProvider = context.read<WalletProvider>();
    final userProvider = context.read<UserProvider>();
    try {
      await walletProvider.setTransferMode(enabled ? 2 : 1);
      if (!mounted) return;
      await userProvider.loadProfile(refresh: true).catchError((_) {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(enabled ? '已开启自动转账' : '已切换为手动转账')),
      );
    } catch (_) {
      if (!mounted) return;
      final message = walletProvider.transferModeError ?? '转账模式切换失败';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _recycleVenues() async {
    final walletProvider = context.read<WalletProvider>();
    try {
      await walletProvider.recycleVenueBalances();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('一键回收成功')),
      );
    } catch (_) {
      if (!mounted) return;
      final message = walletProvider.venueActionError ?? '一键回收失败';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _openVenueSheet(VenueBalance venue) {
    _activeVenue = venue;
    _amountController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            final active = _latestActiveVenue(walletProvider) ?? venue;
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 14.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        active.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '场馆余额',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '¥ ${_formatMoney(active.money)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '转账金额',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: '请输入转账金额',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10.w,
                          children: [100, 500, 1000, 5000].map((amount) {
                            return GestureDetector(
                              onTap: () {
                                _amountController.text = amount.toString();
                              },
                              child: Chip(
                                label: Text('$amount'),
                                backgroundColor: const Color(0xFFF6F7F9),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  if (walletProvider.venueActionError != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      walletProvider.venueActionError!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: walletProvider.isVenueTransferSubmitting
                          ? null
                          : () => _submitVenueTransfer(active, true),
                      child: Text(
                        walletProvider.isVenueTransferSubmitting
                            ? '处理中...'
                            : '转入',
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: OutlinedButton(
                      onPressed: walletProvider.isVenueTransferSubmitting
                          ? null
                          : () => _submitVenueTransfer(active, false),
                      child: const Text('转出'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  VenueBalance? _latestActiveVenue(WalletProvider walletProvider) {
    final active = _activeVenue;
    if (active == null) return null;
    for (final venue in walletProvider.venues) {
      if (venue.id == active.id) return venue;
    }
    return active;
  }

  Future<void> _submitVenueTransfer(VenueBalance venue, bool isIn) async {
    final amount = _parseAmount(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效转账金额')),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    try {
      if (isIn) {
        await walletProvider.transferInVenue(id: venue.id, money: amount);
      } else {
        await walletProvider.transferOutVenue(id: venue.id, money: amount);
      }
      if (!mounted) return;
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isIn ? '转入成功' : '转出成功')),
      );
    } catch (_) {
      if (!mounted) return;
      final message =
          walletProvider.venueActionError ?? (isIn ? '转入失败' : '转出失败');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildActionError(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFCCC7)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.danger,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFallbackNotice(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFD9A1)),
      ),
      child: Text(
        '场馆余额暂未同步，当前展示默认场馆。$message',
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFFB36B00),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTitleWithDot(String title) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: Color(0xFF90C2FF),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double _parseAmount(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 0;
    return (parsed * 100).floor() / 100;
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);
}
