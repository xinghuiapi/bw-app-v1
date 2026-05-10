import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user/user_models.dart';
import '../../models/wallet/wallet_models.dart';
import '../../providers/user/user_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_cell.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/app_network_image.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int _selectedType = 0;
  int _selectedChannel = 0;
  int _selectedAmount = -1;
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> _depositTypes = [
    {'name': '微信支付', 'icon': Icons.wechat, 'color': Colors.green},
    {'name': '支付宝', 'icon': Icons.payments, 'color': Colors.blue},
    {'name': '银联支付', 'icon': Icons.credit_card, 'color': Colors.redAccent},
    {'name': '云闪付', 'icon': Icons.contactless, 'color': Colors.red},
    {'name': '京东支付', 'icon': Icons.shopping_cart, 'color': Colors.redAccent},
    {'name': 'USDT-T...', 'icon': Icons.currency_bitcoin, 'color': Colors.teal},
  ];

  final List<String> _channels = ['USDT-TRC20'];

  final List<int> _quickAmounts = [100, 300, 500, 1000, 5000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().loadDepositBootstrap();
      context.read<UserProvider>().loadProfile().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final symbol = _textOr(profile?.symbol, '¥');
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC), // 浅灰蓝背景
      appBar: CustomNavBar(
        title: '充值',
        rightText: '充值记录',
        onClickRight: () => context.push('/fund-management'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WalletProvider>().loadDepositBootstrap(
              refresh: true,
            ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isRealNameVerified(profile)) _buildDepositAlert(),
              _buildSectionHeader('充值类型'),
              SizedBox(height: 12.h),
              _buildTypeGrid(walletProvider),
              SizedBox(height: 16.h),
              _buildSectionHeader('充值通道'),
              SizedBox(height: 12.h),
              _buildChannelGrid(walletProvider),
              SizedBox(height: 16.h),
              _buildSectionHeader('充值信息'),
              SizedBox(height: 12.h),
              _buildAmountInput(walletProvider, symbol),
              SizedBox(height: 10.h),
              _buildRateText(walletProvider),
              _buildAmountGrid(walletProvider, symbol),
              SizedBox(height: 28.h),
              CustomButton(text: '确认充值', onPressed: _showDepositSubmitTodo),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0EBFF), AppColors.primary],
            ),
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

  Widget _buildDepositAlert() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              '为保障资金安全，建议先完成实名认证',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/real-name'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '去认证',
                style: TextStyle(fontSize: 12.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeGrid(WalletProvider provider) {
    final categories = provider.depositCategories;
    if (provider.isDepositCategoriesLoading && categories.isEmpty) {
      return const AppLoading(message: '充值类型加载中...');
    }

    if (categories.isNotEmpty) {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final category in categories)
            _buildTypeItem(
              selected: provider.selectedDepositCategoryId == category.id,
              title: category.displayTitle,
              badge: category.msg,
              imageUrl: category.img,
              fallbackIcon: _fallbackDepositIcon(category.displayTitle),
              fallbackColor: _fallbackDepositColor(category.displayTitle),
              onTap: () {
                _amountController.clear();
                _selectedAmount = -1;
                provider.loadDepositChannels(category.id, refresh: true);
              },
            ),
        ],
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_depositTypes.length, (index) {
        final type = _depositTypes[index];
        final isSelected = _selectedType == index;
        return _buildTypeItem(
          selected: isSelected,
          title: type['name'],
          fallbackIcon: type['icon'],
          fallbackColor: type['color'],
          onTap: () => setState(() => _selectedType = index),
        );
      }),
    );
  }

  Widget _buildTypeItem({
    required bool selected,
    required String title,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required VoidCallback onTap,
    String? imageUrl,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (1.sw - 32.w - 24.w) / 3 - 0.1, // 3列, 减0.1防止浮点误差导致换行
        height: 48.h,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl?.trim().isNotEmpty == true)
                      AppNetworkImage(
                        url: imageUrl!.trim(),
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(4.r),
                      )
                    else
                      Icon(fallbackIcon, color: fallbackColor, size: 18.sp),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (badge?.trim().isNotEmpty == true)
              Positioned(
                top: -8.h,
                right: -4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    badge!.trim(),
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                ),
              ),
            if (selected) _buildCheckMark(size: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelGrid(WalletProvider provider) {
    final channels = provider.depositChannels;
    if (provider.isDepositChannelsLoading && channels.isEmpty) {
      return const AppLoading(message: '充值通道加载中...');
    }
    if (channels.isNotEmpty) {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final channel in channels)
            _buildChannelItem(
              title: channel.displayTitle,
              selected: provider.selectedDepositChannelId == channel.id,
              onTap: () {
                provider.selectDepositChannel(channel);
                _applyChannelDefaults(channel);
              },
            ),
        ],
      );
    }

    if (provider.depositCategories.isNotEmpty &&
        provider.depositChannelsError == null) {
      return const AppEmpty(title: '暂无充值通道', description: '请切换其他充值类型');
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_channels.length, (index) {
        final channel = _channels[index];
        final isSelected = _selectedChannel == index;
        return _buildChannelItem(
          title: channel,
          selected: isSelected,
          onTap: () => setState(() => _selectedChannel = index),
        );
      }),
    );
  }

  Widget _buildChannelItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (1.sw - 32.w - 12.w) / 2 - 0.1, // 2列, 减0.1防止换行
        height: 50.h,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (selected) _buildCheckMark(size: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckMark({required double size}) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Icon(Icons.check, color: Colors.white, size: 12.sp),
      ),
    );
  }

  Widget _buildAmountInput(WalletProvider provider, String symbol) {
    final channel = provider.selectedDepositChannel;
    final readOnly = channel?.fixedAmountOnly ?? false;
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _amountController,
              readOnly: readOnly,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: channel == null
                    ? '请选择充值通道'
                    : readOnly
                        ? '请选择固定金额'
                        : '请输入金额',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedAmount = -1; // 重新输入时取消快捷金额的选中状态
                  final normalized = _normalizeAmount(value);
                  if (normalized != value) {
                    _amountController.value = TextEditingValue(
                      text: normalized,
                      selection:
                          TextSelection.collapsed(offset: normalized.length),
                    );
                  }
                });
              },
            ),
          ),
          Text(
            _limitText(channel, symbol),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateText(WalletProvider provider) {
    final channel = provider.selectedDepositChannel;
    if (channel == null || !channel.shouldShowRate)
      return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        '参考汇率：${channel.rate}',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAmountGrid(WalletProvider provider, String symbol) {
    final channel = provider.selectedDepositChannel;
    final amounts = channel?.quickAmounts ?? const <double>[];
    if (channel != null && channel.normalizedAmountType == 1) {
      return const SizedBox.shrink();
    }
    if (amounts.isNotEmpty) {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: List.generate(amounts.length, (index) {
          final amount = amounts[index];
          final isSelected = _selectedAmount == index;
          return _buildAmountItem(
            text: '$symbol${_formatAmount(amount)}',
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedAmount = index;
                _amountController.text = _formatAmount(amount);
              });
            },
          );
        }),
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_quickAmounts.length, (index) {
        final amount = _quickAmounts[index];
        final isSelected = _selectedAmount == index;
        return _buildAmountItem(
          text: '$symbol$amount',
          selected: isSelected,
          onTap: () {
            setState(() {
              _selectedAmount = index;
              _amountController.text = amount.toString();
            });
          },
        );
      }),
    );
  }

  Widget _buildAmountItem({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (1.sw - 24.w - 36.w) / 4 - 0.1,
        height: 44.h,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _applyChannelDefaults(DepositChannel channel) {
    setState(() {
      _selectedAmount = -1;
      if (channel.fixedAmountOnly && channel.quickAmounts.isNotEmpty) {
        _selectedAmount = 0;
        _amountController.text = _formatAmount(channel.quickAmounts.first);
      } else {
        _amountController.clear();
      }
    });
  }

  String _limitText(DepositChannel? channel, String symbol) {
    if (channel == null) return '';
    final hasMin = channel.min > 0;
    final hasMax = channel.max > 0;
    if (hasMin && hasMax) {
      return '$symbol${_formatAmount(channel.min)}-$symbol${_formatAmount(channel.max)}';
    }
    if (hasMin) return '≥ $symbol${_formatAmount(channel.min)}';
    if (hasMax) return '≤ $symbol${_formatAmount(channel.max)}';
    return '不限额';
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  String _normalizeAmount(String raw) {
    var value = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (value.isEmpty) return '';
    final parts = value.split('.');
    final intPart = parts.first.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (parts.length == 1) return intPart;
    final decimal = parts
        .skip(1)
        .join()
        .substring(0, parts.skip(1).join().length.clamp(0, 2));
    value = '${intPart.isEmpty ? '0' : intPart}.$decimal';
    return value;
  }

  bool _isRealNameVerified(UserProfile? profile) {
    return profile?.realName?.trim().isNotEmpty == true;
  }

  String _textOr(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  IconData _fallbackDepositIcon(String title) {
    if (title.contains('微信')) return Icons.wechat;
    if (title.contains('支付宝')) return Icons.payments;
    if (title.toUpperCase().contains('USDT')) return Icons.currency_bitcoin;
    if (title.contains('银') || title.contains('卡')) return Icons.credit_card;
    return Icons.account_balance_wallet;
  }

  Color _fallbackDepositColor(String title) {
    if (title.contains('微信')) return Colors.green;
    if (title.contains('支付宝')) return Colors.blue;
    if (title.toUpperCase().contains('USDT')) return Colors.teal;
    if (title.contains('银') || title.contains('卡')) return Colors.redAccent;
    return AppColors.primary;
  }

  void _showDepositSubmitTodo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('充值提交功能待接入')),
    );
  }
}

class DepositOrderDetailScreen extends StatelessWidget {
  const DepositOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '订单详情'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomCard(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    '充值金额',
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '¥ 10,000.00',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  const Divider(color: Color(0xFFEEEEEE)),
                  SizedBox(height: 24.h),
                  _buildDetailRow('订单状态', '处理中',
                      valueColor: const Color(0xFFFF9B00)),
                  _buildDetailRow('订单编号', 'DP20240424102345'),
                  _buildDetailRow('充值方式', '银行卡转账'),
                  _buildDetailRow('创建时间', '2024-04-24 10:23:45'),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: '返回首页',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight:
                  valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class DepositPaySuccessScreen extends StatelessWidget {
  const DepositPaySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavBar(title: '支付结果', showLeftArrow: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  color: const Color(0xFF00B578), size: 80.sp),
              SizedBox(height: 24.h),
              Text(
                '充值成功',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '资金已到达您的钱包账户',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '查看钱包',
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: '继续充值',
                isPrimary: false,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/deposit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  int _activeCardIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().loadCards();
      context.read<WalletProvider>().loadRealtimeBalance();
      context.read<UserProvider>().loadProfile().catchError((_) {});
      context.read<UserProvider>().loadVipLevels().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();
    final cards = walletProvider.cards;
    if (_activeCardIndex >= cards.length) _activeCardIndex = 0;
    final profile = userProvider.profile;
    final symbol = _textOr(profile?.symbol, '¥');
    final balance = walletProvider.realtimeBalance?.balance ??
        _toDouble(profile?.balance) ??
        0;
    final vipLevel = _currentVipLevel(userProvider);
    final minWithdraw = _toDouble(vipLevel?.minDrawing) ?? 0;
    final dayCount = _toInt(vipLevel?.dayCountDrawing);
    final dayAmount = _toDouble(vipLevel?.dayAmountDrawing);
    final sumWater = _toDouble(profile?.sumWater) ?? 0;
    final okWater = _toDouble(profile?.okWater) ?? 0;
    final waterEnough = sumWater <= 0 || okWater >= sumWater;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: '提现',
        rightText: '提现记录',
        onClickRight: () => context.push('/fund-management'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWithdrawData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(symbol, balance, walletProvider),
              if (!waterEnough)
                _buildWaterLock(symbol, sumWater, okWater)
              else ...[
                _buildSectionTitle('提现金额'),
                _buildAmountCard(symbol, balance, minWithdraw),
                _buildSectionTitle(
                  '收款卡包',
                  actionText: '我的卡包',
                  onActionTap: () => context.push('/cards'),
                ),
                _buildCardList(walletProvider, cards),
                _buildWithdrawRuleCard(
                  symbol: symbol,
                  minWithdraw: minWithdraw,
                  dayCount: dayCount,
                  dayAmount: dayAmount,
                  hasPayPassword: profile?.hasPayPassword ?? false,
                ),
              ],
              SizedBox(height: 32.h),
              CustomButton(
                text: '确认提现',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('提现提交功能待接入')),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWithdrawData() async {
    await Future.wait([
      context.read<WalletProvider>().loadCards(refresh: true),
      context.read<WalletProvider>().loadRealtimeBalance(refresh: true),
      context
          .read<UserProvider>()
          .loadProfile(refresh: true)
          .catchError((_) {}),
      context
          .read<UserProvider>()
          .loadVipLevels(refresh: true)
          .catchError((_) {}),
    ]);
  }

  Widget _buildBalanceCard(
    String symbol,
    double balance,
    WalletProvider walletProvider,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      height: 112.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DA1FF), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70.h,
            right: -40.w,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              '可提现余额',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              '$symbol ${balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 2.h,
            child: GestureDetector(
              onTap: walletProvider.isRecyclingVenues ? null : _recycleVenues,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      walletProvider.isRecyclingVenues ? '归户中' : '一键归户',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterLock(String symbol, double sumWater, double okWater) {
    final left = (sumWater - okWater).clamp(0, double.infinity);
    final percent = sumWater <= 0 ? 1.0 : (okWater / sumWater).clamp(0.0, 1.0);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.warning, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '还需 $symbol ${left.toStringAsFixed(2)} 流水可提现',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8.h,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '当前流水：$symbol ${okWater.toStringAsFixed(2)} / $symbol ${sumWater.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0EBFF), AppColors.primary],
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(String symbol, double balance, double minWithdraw) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入提现金额',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _amountController.text = balance.toStringAsFixed(2),
                child: Text(
                  '全部',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.border, height: 16.h),
          Text(
            '单笔最低提现：$symbol ${minWithdraw > 0 ? minWithdraw.toStringAsFixed(2) : '-'}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(WalletProvider walletProvider, List<WalletCard> cards) {
    if (walletProvider.isCardsLoading && cards.isEmpty) {
      return const AppLoading(message: '卡包加载中...');
    }
    if (cards.isEmpty) {
      return CustomCard(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Column(
          children: [
            const AppEmpty(title: '暂无收款卡包', description: '请先添加银行卡、虚拟币或支付宝'),
            SizedBox(height: 12.h),
            CustomButton(
                text: '添加卡包', onPressed: () => context.push('/add-card')),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++)
          _buildWithdrawCardItem(cards[i], i, _activeCardIndex == i),
        GestureDetector(
          onTap: () => context.push('/add-card'),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  '添加卡包',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawCardItem(WalletCard card, int index, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _activeCardIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            _buildCardIcon(card),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.displayTitle.isEmpty
                        ? card.typeName
                        : card.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    card.maskedCard.isEmpty ? '暂无账号' : card.maskedCard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 14.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardIcon(WalletCard card) {
    final icon = card.isCrypto
        ? Icons.currency_bitcoin
        : card.isAlipay
            ? Icons.payments_outlined
            : Icons.account_balance;
    if (card.imageUrl.isNotEmpty) {
      return AppNetworkImage(
        url: card.imageUrl,
        width: 36.w,
        height: 36.w,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.circular(12.r),
      );
    }
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20.sp),
    );
  }

  Widget _buildWithdrawRuleCard({
    required String symbol,
    required double minWithdraw,
    required int? dayCount,
    required double? dayAmount,
    required bool hasPayPassword,
  }) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          _buildRuleRow('最低提现',
              '$symbol ${minWithdraw > 0 ? minWithdraw.toStringAsFixed(2) : '-'}'),
          _buildRuleRow('每日提现次数', dayCount == null ? '-' : '$dayCount 次'),
          _buildRuleRow(
              '每日提现额度',
              dayAmount == null
                  ? '-'
                  : '$symbol ${dayAmount.toStringAsFixed(2)}'),
          _buildRuleRow('取款密码', hasPayPassword ? '已设置' : '未设置，请先设置'),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Text(title,
              style:
                  TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _recycleVenues() async {
    try {
      await context.read<WalletProvider>().recycleVenueBalances();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('归户成功')),
      );
    } catch (_) {
      if (!mounted) return;
      final error = context.read<WalletProvider>().venueActionError ?? '归户失败';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  VipLevel? _currentVipLevel(UserProvider provider) {
    final profileLevel = _levelNumber(provider.profile?.displayVipLevel ?? '');
    if (provider.vipLevels.isEmpty) return null;
    for (final level in provider.vipLevels) {
      if (level.levelNumber == profileLevel) return level;
    }
    return provider.vipLevels.first;
  }

  int _levelNumber(String text) {
    return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', ''));
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _textOr(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}

class WithdrawSuccessScreen extends StatelessWidget {
  const WithdrawSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavBar(title: '提现申请已提交', showLeftArrow: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  color: const Color(0xFF00B578), size: 80.sp),
              SizedBox(height: 24.h),
              Text(
                '提现申请已提交',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '预计 2 小时内到账，请留意资金变动',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '查看提现记录',
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: '返回首页',
                isPrimary: false,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnlinePayDetailScreen extends StatelessWidget {
  const OnlinePayDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '在线支付'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24.h),
            Text(
              '正在跳转至支付网关...',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionRecordScreen extends StatelessWidget {
  const TransactionRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        'title': '游戏结算',
        'date': '2023-10-24 14:30',
        'amount': '+150.00',
        'status': '已完成',
        'isPositive': true
      },
      {
        'title': '充值到账',
        'date': '2023-10-23 09:15',
        'amount': '+1000.00',
        'status': '已完成',
        'isPositive': true
      },
      {
        'title': '购买道具',
        'date': '2023-10-22 18:45',
        'amount': '-50.00',
        'status': '已完成',
        'isPositive': false
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '交易记录'),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return CustomCard(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['date'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      record['amount'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: record['isPositive']
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['status'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FundRecordScreen extends StatelessWidget {
  const FundRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        'title': '微信充值',
        'date': '2023-10-24 10:20',
        'amount': '500.00',
        'status': '充值成功',
        'type': 'deposit'
      },
      {
        'title': '银行卡提现',
        'date': '2023-10-21 16:40',
        'amount': '2000.00',
        'status': '处理中',
        'type': 'withdraw'
      },
      {
        'title': '支付宝充值',
        'date': '2023-10-20 11:10',
        'amount': '100.00',
        'status': '充值成功',
        'type': 'deposit'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '充提记录'),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isDeposit = record['type'] == 'deposit';
          return CustomCard(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: (isDeposit ? Colors.blue : Colors.orange)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDeposit ? Colors.blue : Colors.orange,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          record['date'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isDeposit ? '+' : '-'}${record['amount']}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['status'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: record['status'] == '处理中'
                            ? Colors.orange
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
