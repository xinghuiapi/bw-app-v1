import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_exception.dart';
import '../../models/user/user_models.dart';
import '../../models/wallet/wallet_models.dart';
import '../../providers/user/user_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_error.dart';
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
              CustomButton(
                text: walletProvider.isRechargeOrderSubmitting
                    ? '提交中...'
                    : '确认充值',
                onPressed: walletProvider.isRechargeOrderSubmitting
                    ? null
                    : _submitRechargeOrder,
              ),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
    if (channel == null || !channel.shouldShowRate) {
      return const SizedBox.shrink();
    }
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

  Future<void> _submitRechargeOrder() async {
    final provider = context.read<WalletProvider>();
    final channel = provider.selectedDepositChannel;
    if (channel == null) {
      _showMessage('请选择充值通道');
      return;
    }

    final money = double.tryParse(_amountController.text.trim());
    final error = _validateDepositAmount(channel, money);
    if (error != null) {
      _showMessage(error);
      return;
    }

    try {
      final result = await provider.createRechargeOrder(
        DepositOrderRequest(id: channel.id, money: money!),
      );
      if (!mounted) return;
      await _handleRechargeOrderResult(result);
    } on ApiException catch (exception) {
      if (!mounted) return;
      _showMessage(exception.message);
    } catch (exception) {
      if (!mounted) return;
      _showMessage(exception.toString());
    }
  }

  String? _validateDepositAmount(DepositChannel channel, double? money) {
    if (money == null || money <= 0) return '请输入有效充值金额';
    if (channel.min > 0 && money < channel.min) {
      return '充值金额不能低于${_formatAmount(channel.min)}';
    }
    if (channel.max > 0 && money > channel.max) {
      return '充值金额不能高于${_formatAmount(channel.max)}';
    }
    if (channel.fixedAmountOnly) {
      final matched = channel.quickAmounts.any((amount) => amount == money);
      if (!matched) return '请选择固定充值金额';
    }
    return null;
  }

  Future<void> _handleRechargeOrderResult(DepositOrderResult result) async {
    final orderId = result.resolvedOrderId;
    final url = _normalizeUrl(result.normalizedUrl);

    if (result.type == 1 && url.isNotEmpty) {
      if (result.opensExternal) {
        final opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!opened) _showMessage('无法打开支付网关');
        return;
      }
      context.push(
        '/deposit/online-pay',
        extra: {'url': url, 'orderId': orderId?.toString() ?? ''},
      );
      return;
    }

    _showMessage('提交成功');
    if (orderId != null) {
      context.push('/deposit/order/${Uri.encodeComponent(orderId.toString())}');
    }
  }

  String _normalizeUrl(String url) {
    return url
        .replaceAll('`', '')
        .replaceAll(RegExp(r'''^['"]|['"]$'''), '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
}

class DepositOrderDetailScreen extends StatefulWidget {
  const DepositOrderDetailScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<DepositOrderDetailScreen> createState() =>
      _DepositOrderDetailScreenState();
}

class _DepositOrderDetailScreenState extends State<DepositOrderDetailScreen> {
  final _imagePicker = ImagePicker();
  final _txHashController = TextEditingController();
  final _cancelNoteController = TextEditingController();
  int _proofMode = 0;
  _ProofUploadImage? _proofImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.orderId?.trim();
      if (id == null || id.isEmpty) return;
      context.read<WalletProvider>().loadRechargeDetail(id);
    });
  }

  @override
  void dispose() {
    _txHashController.dispose();
    _cancelNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final id = widget.orderId?.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const CustomNavBar(title: '订单详情'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF5AA7FF),
              Color(0xFFEAF3FF),
              Color(0xFFF4F6F9),
            ],
            stops: [0, 0.18, 0.45, 0.7],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            if (id == null || id.isEmpty) return;
            await context.read<WalletProvider>().loadRechargeDetail(id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
            child: _buildBody(context, provider, id),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WalletProvider provider, String? id) {
    if (id == null || id.isEmpty) {
      return Column(
        children: [
          const AppError(message: '缺少订单ID，无法获取充值详情'),
          SizedBox(height: 24.h),
          CustomButton(
            text: '返回充值',
            onPressed: () => context.go('/deposit'),
          ),
        ],
      );
    }

    if (provider.isRechargeDetailLoading && provider.rechargeDetail == null) {
      return const AppLoading(message: '订单详情加载中...');
    }

    if (provider.rechargeDetailError != null &&
        provider.rechargeDetail == null) {
      return Column(
        children: [
          AppError(
            message: provider.rechargeDetailError!,
            onRetry: () => provider.loadRechargeDetail(id),
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: '返回充值',
            onPressed: () => context.go('/deposit'),
          ),
        ],
      );
    }

    final detail = provider.rechargeDetail;
    if (detail == null) {
      return Column(
        children: [
          const AppEmpty(title: '暂无订单详情'),
          SizedBox(height: 24.h),
          CustomButton(
            text: '返回充值',
            onPressed: () => context.go('/deposit'),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHeaderCard(context, detail, id),
        SizedBox(height: 12.h),
        if (_normalizeImageUrl(detail.img).isNotEmpty) ...[
          _buildQrCard(detail),
          SizedBox(height: 12.h),
        ],
        _buildInfoCard(context, detail, id),
        SizedBox(height: 12.h),
        _buildRiskCard(),
        SizedBox(height: 12.h),
        _buildProofCard(context, detail),
        if (_isPending(detail)) ...[
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => _openCancelSheet(context, detail),
            child: Text(
              '取消支付',
              style: TextStyle(
                color: const Color(0xFFEF4444),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    RechargeDetail detail,
    String id,
  ) {
    return _buildM1Card(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      shadowColor: const Color(0xFF1989FA).withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1989FA).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _headerIcon(detail),
                      size: 16.sp,
                      color: const Color(0xFF1989FA),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _headerTitle(detail),
                      style: TextStyle(
                        color: const Color(0xFF1989FA),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildStatusTag(detail),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  _amountDisplayText(detail),
                  style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildCopyButton(context, _moneyOnlyText(detail)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '订单ID：',
                style:
                    TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
              ),
              Expanded(
                child: Text(
                  id,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF111827),
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildMiniCopy(context, id),
              if (_startTimeText(detail).isNotEmpty) ...[
                SizedBox(width: 8.w),
                Text(
                  '提交：${_startTimeText(detail)}',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(RechargeDetail detail) {
    final url = _normalizeImageUrl(detail.img);
    final qrSize = 220.w.clamp(170.0, 220.0);
    return _buildM1Card(
      child: Column(
        children: [
          Container(
            width: 240.w.clamp(190.0, 240.0),
            height: 240.w.clamp(190.0, 240.0),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AppNetworkImage(
                url: url,
                width: qrSize,
                height: qrSize,
                fit: BoxFit.cover,
                errorWidget: Icon(
                  Icons.qr_code_2,
                  size: 80.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '点击二维码可预览，请按页面信息完成转账',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, RechargeDetail detail, String id) {
    final rows = _buildPaymentRows(detail);
    return _buildM1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('支付信息'),
          SizedBox(height: 10.h),
          _buildInfoRow(context, '支付类型', _payTypeText(detail)),
          _buildInfoRow(context, '开始时间', _startTimeText(detail, fallback: '-')),
          _buildInfoRow(context, '货币', detail.displayCurrency),
          _buildInfoRow(context, '充值金额', _formatAmount(detail.money),
              copy: _moneyOnlyText(detail)),
          ...rows,
          if (detail.msg?.trim().isNotEmpty == true)
            _buildInfoRow(context, '说明', detail.msg!.trim()),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    const tips = [
      ['请务必按页面展示的', '金额和收款信息', '完成转账。'],
      ['请勿保存旧收款信息重复转账，', '每笔订单信息可能不同', '。'],
      ['转账完成后请保留凭证，等待系统核对。'],
      ['如遇到账延迟，请联系在线客服处理。'],
    ];
    return _buildM1Card(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '重要提示',
            style: TextStyle(
              color: const Color(0xFFEF4444),
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          for (final parts in tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.only(top: 7.h, right: 8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 12.sp,
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(text: parts[0]),
                        if (parts.length > 1)
                          TextSpan(
                            text: parts[1],
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (parts.length > 2) TextSpan(text: parts[2]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _buildProofCard(BuildContext context, RechargeDetail detail) {
    final provider = context.watch<WalletProvider>();
    final showHash = detail.type == 3;
    final needHash = showHash && _proofMode == 0;
    final needProof = !showHash || _proofMode == 1;
    final isBusy =
        provider.isUploadingRechargeImage || provider.isRechargeProofSubmitting;
    return _buildM1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('上传凭证'),
          SizedBox(height: 12.h),
          if (showHash) ...[
            Row(
              children: [
                Expanded(
                  child: _buildProofModeTab('交易哈希', selected: _proofMode == 0),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildProofModeTab('支付凭证', selected: _proofMode == 1),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
          if (needHash) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                    color: const Color(0xFF1989FA).withValues(alpha: 0.18)),
                color: const Color(0xFFFAFCFF),
              ),
              child: TextField(
                controller: _txHashController,
                minLines: 4,
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '请输入交易哈希',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste),
                    onPressed: _pasteTxHash,
                  ),
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF333333),
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          if (needProof) ...[
            GestureDetector(
              onTap: isBusy ? null : () => _pickProofImage(provider),
              child: Container(
                height: 180.h.clamp(150.0, 180.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: const Color(0xFFDCDFe6), style: BorderStyle.solid),
                ),
                child: _proofImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (provider.isUploadingRechargeImage)
                            const CircularProgressIndicator(
                                color: AppColors.primary)
                          else
                            Icon(Icons.add,
                                size: 40.sp, color: const Color(0xFF999999)),
                          SizedBox(height: 10.h),
                          Text(
                            provider.isUploadingRechargeImage
                                ? '上传中...'
                                : '选择支付凭证',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '支持 png、jpg、webp 等图片格式，最大 10MB',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: AppNetworkImage(
                              url: _proofImage!.previewUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                              errorWidget: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48.sp,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: () => setState(() => _proofImage = null),
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          CustomButton(
            text: provider.isRechargeProofSubmitting ? '提交中...' : '提交凭证',
            onPressed: provider.isRechargeProofSubmitting
                ? null
                : () => _submitProof(detail),
          ),
        ],
      ),
    );
  }

  Widget _buildProofModeTab(String text, {required bool selected}) {
    return GestureDetector(
      onTap: () => setState(() => _proofMode = text == '交易哈希' ? 0 : 1),
      child: Container(
        height: 34.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _pickProofImage(WalletProvider provider) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        _showSnack('图片不能超过 10MB');
        return;
      }
      final result = await provider.uploadRechargeImage(
        bytes: bytes,
        filename: file.name,
      );
      final submitValue = result.path?.trim().isNotEmpty == true
          ? result.path!.trim()
          : result.url?.trim();
      final previewUrl = result.url?.trim().isNotEmpty == true
          ? result.url!.trim()
          : submitValue;
      if (submitValue == null ||
          submitValue.isEmpty ||
          previewUrl == null ||
          previewUrl.isEmpty) {
        throw const FormatException('Upload response missing image path');
      }
      if (!mounted) return;
      setState(() {
        _proofImage = _ProofUploadImage(
          previewUrl: previewUrl,
          submitValue: submitValue,
        );
      });
      _showSnack('上传成功');
    } on MissingPluginException {
      if (!mounted) return;
      _showSnack('图片选择组件未加载，请完整重启应用后重试');
    } catch (_) {
      if (!mounted) return;
      _showSnack(provider.rechargeImageUploadError ?? '上传失败');
    }
  }

  Future<void> _submitProof(RechargeDetail detail) async {
    final id = _detailOrderId(detail);
    if (id == null || id <= 0) {
      _showSnack('订单ID无效');
      return;
    }
    final needHash = detail.type == 3 && _proofMode == 0;
    final needProof = detail.type != 3 || _proofMode == 1;
    final hash = _txHashController.text.trim();
    if (needHash && hash.isEmpty) {
      _showSnack('请输入交易哈希');
      return;
    }
    if (needProof && _proofImage == null) {
      _showSnack('请先上传支付凭证');
      return;
    }
    final provider = context.read<WalletProvider>();
    try {
      await provider.submitRechargeProof(
        RechargeProofRequest(
          id: id,
          img: needProof ? _proofImage!.submitValue : null,
          hash: needHash ? hash : null,
        ),
      );
      if (!mounted) return;
      _showSnack('提交成功');
      context.go('/deposit/success/$id');
    } catch (_) {
      if (!mounted) return;
      _showSnack(provider.rechargeProofSubmitError ?? '提交失败');
    }
  }

  Future<void> _pasteTxHash() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) {
        _showSnack('剪贴板为空');
        return;
      }
      _txHashController.text = text;
    } catch (_) {
      _showSnack('读取剪贴板失败');
    }
  }

  void _openCancelSheet(BuildContext context, RechargeDetail detail) {
    _cancelNoteController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 14.h,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '取消支付',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '取消原因',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildCancelReasonChip('我不想充值了'),
                  _buildCancelReasonChip('信息填写错误'),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _cancelNoteController,
                minLines: 2,
                maxLines: 3,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: '请输入取消原因',
                  filled: true,
                  fillColor: const Color(0xFFF5F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: '返回',
                      isPrimary: false,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Consumer<WalletProvider>(
                      builder: (context, provider, _) {
                        return CustomButton(
                          text: provider.isRechargeCancelSubmitting
                              ? '取消中...'
                              : '确认取消',
                          onPressed: provider.isRechargeCancelSubmitting
                              ? null
                              : () => _confirmCancel(sheetContext, detail),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelReasonChip(String text) {
    return GestureDetector(
      onTap: () => _cancelNoteController.text = text,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF333333)),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext sheetContext,
    RechargeDetail detail,
  ) async {
    final id = _detailOrderId(detail);
    if (id == null || id <= 0) {
      _showSnack('订单ID无效');
      return;
    }
    final note = _cancelNoteController.text.trim();
    if (note.isEmpty) {
      _showSnack('请输入取消原因');
      return;
    }
    final provider = context.read<WalletProvider>();
    try {
      await provider.cancelRechargeOrder(
        RechargeCancelRequest(id: id, note: note),
      );
      if (!mounted) return;
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      _showSnack('取消成功');
      context.go('/deposit');
    } catch (_) {
      if (!mounted) return;
      _showSnack(provider.rechargeCancelError ?? '取消失败');
    }
  }

  int? _detailOrderId(RechargeDetail detail) {
    return detail.id ?? int.tryParse(widget.orderId?.trim() ?? '');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildM1Card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color color = Colors.white,
    Color? shadowColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black.withValues(alpha: 0.04),
            blurRadius: shadowColor == null ? 10 : 24,
            offset: Offset(0, shadowColor == null ? 2 : 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF111827),
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildStatusTag(RechargeDetail detail) {
    final status = detail.status ?? 5;
    final isSuccess = status == 1 || status == 2;
    final isFailed = status == 0 || status == 3 || status == 4;
    final color = isSuccess
        ? const Color(0xFF00B578)
        : isFailed
            ? const Color(0xFFEF4444)
            : const Color(0xFF1989FA);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, String value) {
    return TextButton.icon(
      onPressed: () => _copyText(context, value),
      icon: Icon(Icons.copy, size: 14.sp),
      label: const Text('复制'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1989FA),
        textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildMiniCopy(BuildContext context, String value) {
    return TextButton(
      onPressed: () => _copyText(context, value),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1989FA),
        textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('复制'),
    );
  }

  List<Widget> _buildPaymentRows(RechargeDetail detail) {
    final params = detail.params;
    final rows = <Widget>[];
    final type = detail.type;

    if (type == 4) {
      _addRow(rows, '开户行', params?.bank);
      _addRow(rows, '开户姓名', params?.bankName);
      _addRow(rows, '卡号', params?.card, copy: params?.card);
      _addRow(rows, '开户地', params?.address);
    } else if (type == 3 || type == 5) {
      _addRow(rows, '收款地址', params?.address, copy: params?.address);
      if (detail.displayCurrency.toUpperCase() == 'CNY') {
        _addRow(
            rows,
            'USDT汇率',
            detail.rate == null
                ? null
                : _formatAmount(detail.rate!, fractionDigits: 4));
        _addRow(rows, '虚拟币数量', _cryptoAmountText(detail));
      }
    } else if (type == 2) {
      _addRow(rows, '姓名', params?.name);
      _addRow(rows, '账号', params?.account, copy: params?.account);
    } else {
      _addRow(rows, '姓名', params?.name);
      _addRow(rows, '账号', params?.account, copy: params?.account);
      _addRow(rows, '收款地址', params?.address, copy: params?.address);
      _addRow(rows, '开户行', params?.bank);
      _addRow(rows, '开户姓名', params?.bankName);
      _addRow(rows, '卡号', params?.card, copy: params?.card);
      _addRow(rows, '开户地', params?.address);
    }

    if (rows.isEmpty) {
      rows.add(_buildInfoRow(context, '支付信息', '暂无'));
    }
    return rows;
  }

  void _addRow(
    List<Widget> rows,
    String label,
    String? value, {
    String? copy,
  }) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return;
    rows.add(_buildInfoRow(context, label, text, copy: copy));
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    String? copy,
  }) {
    final copyText = copy?.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF111827),
                height: 1.4,
              ),
              maxLines: copyText?.isNotEmpty == true ? 1 : 3,
              overflow: copyText?.isNotEmpty == true
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
            ),
          ),
          if (copyText?.isNotEmpty == true) ...[
            SizedBox(width: 8.w),
            _buildMiniCopy(context, copyText!),
          ],
        ],
      ),
    );
  }

  String _statusText(int status) {
    if (status == 1 || status == 2) return '充值成功';
    if (status == 0) return '已超时';
    if (status == 3) return '已取消';
    if (status == 4) return '已驳回';
    if (status == 5) return '处理中';
    return '待支付';
  }

  String _headerTitle(RechargeDetail detail) {
    if (detail.type == 4) return '银行卡转账';
    if (detail.type == 2) return '支付宝充值';
    if (detail.type == 3 || detail.type == 5) return '虚拟币充值';
    return _payTypeText(detail);
  }

  IconData _headerIcon(RechargeDetail detail) {
    if (detail.type == 4) return Icons.account_balance_outlined;
    if (detail.type == 2) return Icons.payments_outlined;
    if (detail.type == 3 || detail.type == 5) return Icons.diamond_outlined;
    return Icons.info_outline;
  }

  String _payTypeText(RechargeDetail detail) {
    if (detail.type == 4) return '银行卡';
    if (detail.type == 3 || detail.type == 5) return '虚拟币';
    if (detail.type == 2) return '支付宝';
    return detail.type == null ? '-' : '类型${detail.type}';
  }

  bool _isPending(RechargeDetail detail) => (detail.status ?? 5) == 5;

  String _amountDisplayText(RechargeDetail detail) {
    final money = _moneyOnlyText(detail);
    if (detail.type == 3 || detail.type == 5) return money;
    final prefix = _currencyPrefix(detail.displayCurrency);
    return money == '-' ? prefix : '$prefix $money';
  }

  String _moneyOnlyText(RechargeDetail detail) {
    if (detail.type == 5 && detail.usdtMoney != null) {
      return _formatAmount(detail.usdtMoney!, fractionDigits: 4);
    }
    return _formatAmount(detail.money);
  }

  String _currencyPrefix(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (normalized == 'CNY' || normalized == 'RMB') return '¥';
    if (normalized == 'USD') return r'$';
    return normalized.isEmpty ? '¥' : normalized;
  }

  String _cryptoAmountText(RechargeDetail detail) {
    if (detail.usdtMoney != null && detail.usdtMoney! > 0) {
      return _formatAmount(detail.usdtMoney!, fractionDigits: 4);
    }
    final rate = detail.rate ?? 0;
    if (rate > 0 && detail.money > 0) {
      return _formatAmount(detail.money / rate, fractionDigits: 4);
    }
    return '-';
  }

  String _formatAmount(double value, {int fractionDigits = 2}) {
    if (value % 1 == 0 && fractionDigits <= 2) return value.toStringAsFixed(0);
    return value.toStringAsFixed(fractionDigits);
  }

  String _startTimeText(RechargeDetail detail, {String fallback = ''}) {
    final value = detail.startTime?.trim();
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  String _normalizeImageUrl(String? input) {
    final raw = input?.trim();
    if (raw == null || raw.isEmpty) return '';
    return raw.replaceAll('`', '').replaceAll(RegExp(r'''^['"]|['"]$'''), '');
  }

  Future<void> _copyText(BuildContext context, String value) async {
    final text = value.trim();
    if (text.isEmpty || text == '-') return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制')),
    );
  }
}

class _ProofUploadImage {
  const _ProofUploadImage({
    required this.previewUrl,
    required this.submitValue,
  });

  final String previewUrl;
  final String submitValue;
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
        onClickRight: () => context.push('/fund-management?tab=withdraw'),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
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
  const OnlinePayDetailScreen({super.key, this.url, this.orderId});

  final String? url;
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final payUrl = url?.trim() ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '在线支付'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomCard(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: AppColors.primary,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '在线支付',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    payUrl.isEmpty ? '支付链接缺失' : '请在支付网关完成付款，完成后返回查看订单详情。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              text: '打开支付网关',
              onPressed:
                  payUrl.isEmpty ? null : () => _openPayUrl(context, payUrl),
            ),
            if (orderId?.trim().isNotEmpty == true) ...[
              SizedBox(height: 12.h),
              CustomButton(
                text: '查看订单详情',
                isPrimary: false,
                onPressed: () => context.push(
                  '/deposit/order/${Uri.encodeComponent(orderId!.trim())}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPayUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('支付链接无效')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开支付网关')),
      );
    }
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
