import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../api/api_exception.dart';
import '../../models/user/user_models.dart';
import '../../models/wallet/wallet_models.dart';
import '../../providers/localization/language_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../security/url_policy.dart';
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
    {'name': 'deposit.wechat', 'icon': Icons.wechat, 'color': Colors.green},
    {'name': 'deposit.alipay', 'icon': Icons.payments, 'color': Colors.blue},
    {
      'name': 'deposit.unionPay',
      'icon': Icons.credit_card,
      'color': Colors.redAccent
    },
    {
      'name': 'deposit.quickPay',
      'icon': Icons.contactless,
      'color': Colors.red
    },
    {
      'name': 'deposit.jdPay',
      'icon': Icons.shopping_cart,
      'color': Colors.redAccent
    },
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
        title: 'deposit.title'.tr(),
        leftHitTargetWidth: 64.w,
        rightText: 'deposit.records'.tr(),
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
              _buildSectionHeader('deposit.type'.tr()),
              SizedBox(height: 12.h),
              _buildTypeGrid(walletProvider),
              SizedBox(height: 16.h),
              _buildSectionHeader('deposit.channel'.tr()),
              SizedBox(height: 12.h),
              _buildChannelGrid(walletProvider),
              SizedBox(height: 16.h),
              _buildSectionHeader('deposit.info'.tr()),
              SizedBox(height: 12.h),
              _buildAmountInput(walletProvider, symbol),
              SizedBox(height: 10.h),
              _buildRateText(walletProvider),
              _buildAmountGrid(walletProvider, symbol),
              SizedBox(height: 28.h),
              CustomButton(
                text: walletProvider.isRechargeOrderSubmitting
                    ? 'deposit.submitting'.tr()
                    : 'deposit.confirm'.tr(),
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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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
              'deposit.realNameTip'.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                'deposit.goVerify'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      return AppLoading(message: 'deposit.typeLoading'.tr());
    }

    if (categories.isNotEmpty) {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final category in categories)
            _buildTypeItem(
              selected: provider.selectedDepositCategoryId == category.id,
              title: _localizedDepositText(category.displayTitle),
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
          title: (type['name'] as String).tr(),
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
      return AppLoading(message: 'deposit.channelLoading'.tr());
    }
    if (channels.isNotEmpty) {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: [
          for (final channel in channels)
            _buildChannelItem(
              title: _localizedDepositText(channel.displayTitle),
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
      return AppEmpty(
        title: 'deposit.emptyChannel'.tr(),
        description: 'deposit.switchType'.tr(),
      );
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
                    ? 'deposit.selectChannel'.tr()
                    : readOnly
                        ? 'deposit.selectFixedAmount'.tr()
                        : 'deposit.enterAmount'.tr(),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        'deposit.rate'.tr(
          namedArgs: {'rate': channel.rate?.trim() ?? ''},
        ),
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
      _showMessage('deposit.selectChannel'.tr());
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
    if (money == null || money <= 0) return 'deposit.validAmount'.tr();
    if (channel.min > 0 && money < channel.min) {
      return 'deposit.minAmount'
          .tr(namedArgs: {'amount': _formatAmount(channel.min)});
    }
    if (channel.max > 0 && money > channel.max) {
      return 'deposit.maxAmount'
          .tr(namedArgs: {'amount': _formatAmount(channel.max)});
    }
    if (channel.fixedAmountOnly) {
      final matched = channel.quickAmounts.any((amount) => amount == money);
      if (!matched) return 'deposit.fixedAmountRequired'.tr();
    }
    return null;
  }

  Future<void> _handleRechargeOrderResult(DepositOrderResult result) async {
    final orderId = result.resolvedOrderId;
    final url = _normalizeUrl(result.normalizedUrl);

    if (result.type == 1 && url.isNotEmpty) {
      if (result.opensExternal) {
        final opened = await UrlPolicy.launchExternal(
          url,
          type: ExternalUrlType.payment,
        );
        if (!opened) _showMessage('deposit.openGatewayFailed'.tr());
        return;
      }
      if (UrlPolicy.externalUri(url, type: ExternalUrlType.payment) == null) {
        _showMessage('deposit.pay.invalidLink'.tr());
        return;
      }
      context.push(
        '/deposit/online-pay',
        extra: {'url': url, 'orderId': orderId?.toString() ?? ''},
      );
      return;
    }

    _showMessage('deposit.submitSuccess'.tr());
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
    return 'deposit.noLimit'.tr();
  }

  String _localizedDepositText(String text) {
    final value = text.trim();
    return value.startsWith('deposit.') ? value.tr() : value;
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
    final languageCode = context.watch<LanguageProvider>().currentCode;

    return KeyedSubtree(
      key: ValueKey(languageCode),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: CustomNavBar(title: 'deposit.detail.detailTitle'.tr()),
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
      ),
    );
  }

  Widget _buildBody(BuildContext context, WalletProvider provider, String? id) {
    if (id == null || id.isEmpty) {
      return Column(
        children: [
          AppError(message: 'deposit.detail.missingOrderId'.tr()),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'deposit.detail.backDeposit'.tr(),
            onPressed: () => context.go('/deposit'),
          ),
        ],
      );
    }

    if (provider.isRechargeDetailLoading && provider.rechargeDetail == null) {
      return AppLoading(message: 'deposit.detail.loadingDetail'.tr());
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
            text: 'deposit.detail.backDeposit'.tr(),
            onPressed: () => context.go('/deposit'),
          ),
        ],
      );
    }

    final detail = provider.rechargeDetail;
    if (detail == null) {
      return Column(
        children: [
          AppEmpty(title: 'deposit.detail.emptyDetail'.tr()),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'deposit.detail.backDeposit'.tr(),
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
              'deposit.detail.cancelPay'.tr(),
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
                'deposit.detail.orderId'.tr(),
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
                  'deposit.detail.submittedAt'.tr(namedArgs: {
                    'time': _startTimeText(detail),
                  }),
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
            'deposit.detail.qrHint'.tr(),
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
          _buildSectionTitle('deposit.detail.paymentInfo'.tr()),
          SizedBox(height: 10.h),
          _buildInfoRow(
              context, 'deposit.detail.payType'.tr(), _payTypeText(detail)),
          _buildInfoRow(context, 'deposit.detail.startTime'.tr(),
              _startTimeText(detail, fallback: '-')),
          _buildInfoRow(
              context, 'deposit.detail.currency'.tr(), detail.displayCurrency),
          _buildInfoRow(context, 'deposit.detail.amount'.tr(),
              _formatAmount(detail.money),
              copy: _moneyOnlyText(detail)),
          ...rows,
          if (detail.msg?.trim().isNotEmpty == true)
            _buildInfoRow(
                context, 'deposit.detail.note'.tr(), detail.msg!.trim()),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    final tips = [
      [
        'deposit.detail.risk1a'.tr(),
        'deposit.detail.risk1b'.tr(),
        'deposit.detail.risk1c'.tr(),
      ],
      [
        'deposit.detail.risk2a'.tr(),
        'deposit.detail.risk2b'.tr(),
        'deposit.detail.risk2c'.tr(),
      ],
      ['deposit.detail.risk3'.tr()],
      ['deposit.detail.risk4'.tr()],
    ];
    return _buildM1Card(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'deposit.detail.importantTips'.tr(),
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
          _buildSectionTitle('deposit.detail.uploadProof'.tr()),
          SizedBox(height: 12.h),
          if (showHash) ...[
            Row(
              children: [
                Expanded(
                  child: _buildProofModeTab('deposit.detail.txHash'.tr(),
                      selected: _proofMode == 0),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildProofModeTab('deposit.detail.payProof'.tr(),
                      selected: _proofMode == 1),
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
                  hintText: 'deposit.detail.enterTxHash'.tr(),
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
                                ? 'deposit.submitting'.tr()
                                : 'deposit.detail.choosePayProof'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'deposit.detail.proofFormatTip'.tr(),
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
            text: provider.isRechargeProofSubmitting
                ? 'deposit.submitting'.tr()
                : 'deposit.detail.submitProof'.tr(),
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
      onTap: () => setState(
          () => _proofMode = text == 'deposit.detail.txHash'.tr() ? 0 : 1),
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
        _showSnack('deposit.detail.imageTooLarge'.tr());
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
      _showSnack('deposit.detail.uploadSuccess'.tr());
    } on MissingPluginException {
      if (!mounted) return;
      _showSnack('deposit.detail.imagePickerMissing'.tr());
    } catch (_) {
      if (!mounted) return;
      _showSnack(provider.rechargeImageUploadError ??
          'deposit.detail.uploadFailed'.tr());
    }
  }

  Future<void> _submitProof(RechargeDetail detail) async {
    final id = _detailOrderId(detail);
    if (id == null || id <= 0) {
      _showSnack('deposit.detail.invalidOrderId'.tr());
      return;
    }
    final needHash = detail.type == 3 && _proofMode == 0;
    final needProof = detail.type != 3 || _proofMode == 1;
    final hash = _txHashController.text.trim();
    if (needHash && hash.isEmpty) {
      _showSnack('deposit.detail.enterTxHash'.tr());
      return;
    }
    if (needProof && _proofImage == null) {
      _showSnack('deposit.detail.uploadProofFirst'.tr());
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
      _showSnack('deposit.detail.submitSuccess'.tr());
      context.go('/deposit/success/$id');
    } catch (_) {
      if (!mounted) return;
      _showSnack(provider.rechargeProofSubmitError ??
          'deposit.detail.submitFailed'.tr());
    }
  }

  Future<void> _pasteTxHash() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) {
        _showSnack('deposit.detail.clipboardEmpty'.tr());
        return;
      }
      _txHashController.text = text;
    } catch (_) {
      _showSnack('deposit.detail.clipboardReadFailed'.tr());
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
                'deposit.detail.cancelPay'.tr(),
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
                  'deposit.detail.cancelReason'.tr(),
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
                  _buildCancelReasonChip(
                      'deposit.detail.cancelReasonNoWant'.tr()),
                  _buildCancelReasonChip(
                      'deposit.detail.cancelReasonWrongInfo'.tr()),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _cancelNoteController,
                minLines: 2,
                maxLines: 3,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'deposit.detail.enterCancelReason'.tr(),
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
                      text: 'deposit.detail.back'.tr(),
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
                              ? 'deposit.detail.canceling'.tr()
                              : 'deposit.detail.confirmCancel'.tr(),
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
      _showSnack('deposit.detail.invalidOrderId'.tr());
      return;
    }
    final note = _cancelNoteController.text.trim();
    if (note.isEmpty) {
      _showSnack('deposit.detail.enterCancelReason'.tr());
      return;
    }
    final provider = context.read<WalletProvider>();
    try {
      await provider.cancelRechargeOrder(
        RechargeCancelRequest(id: id, note: note),
      );
      if (!mounted) return;
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      _showSnack('deposit.detail.cancelSuccess'.tr());
      context.go('/deposit');
    } catch (_) {
      if (!mounted) return;
      _showSnack(
          provider.rechargeCancelError ?? 'deposit.detail.cancelFailed'.tr());
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
      label: Text('deposit.detail.copy'.tr()),
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
      child: Text('deposit.detail.copy'.tr()),
    );
  }

  List<Widget> _buildPaymentRows(RechargeDetail detail) {
    final params = detail.params;
    final rows = <Widget>[];
    final type = detail.type;

    if (type == 4) {
      _addRow(rows, 'deposit.detail.bank'.tr(), params?.bank);
      _addRow(rows, 'deposit.detail.bankName'.tr(), params?.bankName);
      _addRow(rows, 'deposit.detail.cardNo'.tr(), params?.card,
          copy: params?.card);
      _addRow(rows, 'deposit.detail.address'.tr(), params?.address);
    } else if (type == 3 || type == 5) {
      _addRow(rows, 'deposit.detail.receiveAddress'.tr(), params?.address,
          copy: params?.address);
      if (detail.displayCurrency.toUpperCase() == 'CNY') {
        _addRow(
            rows,
            'deposit.detail.usdtRate'.tr(),
            detail.rate == null
                ? null
                : _formatAmount(detail.rate!, fractionDigits: 4));
        _addRow(rows, 'deposit.detail.cryptoAmount'.tr(),
            _cryptoAmountText(detail));
      }
    } else if (type == 2) {
      _addRow(rows, 'deposit.detail.name'.tr(), params?.name);
      _addRow(rows, 'deposit.detail.account'.tr(), params?.account,
          copy: params?.account);
    } else {
      _addRow(rows, 'deposit.detail.name'.tr(), params?.name);
      _addRow(rows, 'deposit.detail.account'.tr(), params?.account,
          copy: params?.account);
      _addRow(rows, 'deposit.detail.receiveAddress'.tr(), params?.address,
          copy: params?.address);
      _addRow(rows, 'deposit.detail.bank'.tr(), params?.bank);
      _addRow(rows, 'deposit.detail.bankName'.tr(), params?.bankName);
      _addRow(rows, 'deposit.detail.cardNo'.tr(), params?.card,
          copy: params?.card);
      _addRow(rows, 'deposit.detail.address'.tr(), params?.address);
    }

    if (rows.isEmpty) {
      rows.add(_buildInfoRow(
        context,
        'deposit.detail.paymentInfo'.tr(),
        'deposit.detail.empty'.tr(),
      ));
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
    if (status == 1 || status == 2) return 'deposit.detail.statusSuccess'.tr();
    if (status == 0) return 'deposit.detail.statusTimeout'.tr();
    if (status == 3) return 'deposit.detail.statusCanceled'.tr();
    if (status == 4) return 'deposit.detail.statusRejected'.tr();
    if (status == 5) return 'deposit.detail.statusProcessing'.tr();
    return 'deposit.detail.statusPending'.tr();
  }

  String _headerTitle(RechargeDetail detail) {
    if (detail.type == 4) return 'deposit.detail.bankTransfer'.tr();
    if (detail.type == 2) return 'deposit.detail.alipayRecharge'.tr();
    if (detail.type == 3 || detail.type == 5) {
      return 'deposit.detail.cryptoRecharge'.tr();
    }
    return _payTypeText(detail);
  }

  IconData _headerIcon(RechargeDetail detail) {
    if (detail.type == 4) return Icons.account_balance_outlined;
    if (detail.type == 2) return Icons.payments_outlined;
    if (detail.type == 3 || detail.type == 5) return Icons.diamond_outlined;
    return Icons.info_outline;
  }

  String _payTypeText(RechargeDetail detail) {
    if (detail.type == 4) return 'deposit.detail.bankCard'.tr();
    if (detail.type == 3 || detail.type == 5) {
      return 'deposit.detail.crypto'.tr();
    }
    if (detail.type == 2) return 'deposit.detail.alipay'.tr();
    return detail.type == null
        ? '-'
        : 'deposit.detail.typeNumber'.tr(namedArgs: {'type': '${detail.type}'});
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
      SnackBar(content: Text('deposit.detail.copied'.tr())),
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
      appBar: CustomNavBar(
        title: 'deposit.success.title'.tr(),
        showLeftArrow: false,
      ),
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
                'deposit.success.message'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'deposit.success.description'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: 'deposit.success.viewWallet'.tr(),
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'deposit.success.continueDeposit'.tr(),
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

class DepositPayFailedScreen extends StatelessWidget {
  const DepositPayFailedScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: _failedText('title', '充值失败'),
        showLeftArrow: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 12.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68.w,
                      height: 68.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 38.sp,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _failedText('heading', '充值失败'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _failedText('desc', '本次支付未完成，请重新发起充值。'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    if (orderId?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _failedText('orderId', '订单号：{id}')
                            .replaceAll('{id}', orderId!.trim()),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              CustomButton(
                text: 'common.deposit'.tr(),
                onPressed: () => context.go('/deposit'),
              ),
              SizedBox(height: 10.h),
              CustomButton(
                text: _failedText('backHome', '返回首页'),
                isPrimary: false,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _failedText(String key, String fallback) {
    final localeKey = 'deposit.failed.$key';
    final value = localeKey.tr();
    return value == localeKey ? fallback : value;
  }
}

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payPasswordController = TextEditingController();
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
    _payPasswordController.dispose();
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
        title: 'finance.withdraw.title'.tr(),
        leftHitTargetWidth: 64.w,
        rightText: 'finance.withdraw.records'.tr(),
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
                _buildSectionTitle('finance.withdraw.amount'.tr()),
                _buildAmountCard(symbol, balance, minWithdraw),
                _buildSectionTitle(
                  'finance.withdraw.wallet'.tr(),
                  actionText: 'finance.withdraw.myCards'.tr(),
                  onActionTap: () => context.push('/cards'),
                ),
                _buildCardList(walletProvider, cards),
                _buildPayPasswordCard(profile?.hasPayPassword ?? false),
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
                text: walletProvider.isWithdrawSubmitting
                    ? 'deposit.submitting'.tr()
                    : 'finance.withdraw.confirm'.tr(),
                onPressed: walletProvider.isWithdrawSubmitting
                    ? null
                    : () => _submitWithdraw(
                          cards: cards,
                          balance: balance,
                          minWithdraw: minWithdraw,
                          waterEnough: waterEnough,
                          hasPayPassword: profile?.hasPayPassword ?? false,
                        ),
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
              'finance.withdraw.availableBalance'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                      walletProvider.isRecyclingVenues
                          ? 'finance.withdraw.recycling'.tr()
                          : 'finance.withdraw.recycle'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  'finance.withdraw.waterLock'.tr(namedArgs: {
                    'symbol': symbol,
                    'amount': left.toStringAsFixed(2),
                  }),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
            'finance.withdraw.currentWater'.tr(namedArgs: {
              'ok': '$symbol ${okWater.toStringAsFixed(2)}',
              'sum': '$symbol ${sumWater.toStringAsFixed(2)}',
            }),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    hintText: 'finance.withdraw.enterAmount'.tr(),
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
                  'finance.withdraw.all'.tr(),
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
            'finance.withdraw.minSingle'.tr(namedArgs: {
              'amount': minWithdraw > 0
                  ? '$symbol ${minWithdraw.toStringAsFixed(2)}'
                  : '-',
            }),
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(WalletProvider walletProvider, List<WalletCard> cards) {
    if (walletProvider.isCardsLoading && cards.isEmpty) {
      return AppLoading(message: 'finance.withdraw.cardLoading'.tr());
    }
    if (cards.isEmpty) {
      return CustomCard(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Column(
          children: [
            AppEmpty(
              title: 'finance.withdraw.emptyCards'.tr(),
              description: 'finance.withdraw.emptyCardsDesc'.tr(),
            ),
            SizedBox(height: 12.h),
            CustomButton(
                text: 'finance.withdraw.addCard'.tr(),
                onPressed: () => context.push('/add-card')),
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
                  'finance.withdraw.addCard'.tr(),
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
                    card.maskedCard.isEmpty
                        ? 'finance.withdraw.noAccount'.tr()
                        : card.maskedCard,
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

  Widget _buildPayPasswordCard(bool hasPayPassword) {
    return CustomCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'finance.withdraw.payPassword'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!hasPayPassword)
                GestureDetector(
                  onTap: () => context.push('/withdraw-password'),
                  child: Text(
                    _withdrawText('goSetPayPassword', '去设置'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (hasPayPassword)
            TextField(
              controller: _payPasswordController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                hintText: _withdrawText('enterPayPassword', '请输入6位取款密码'),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              ),
            )
          else
            Text(
              _withdrawText(
                'payPasswordTip',
                '为了您的资金安全，提现前请先设置取款密码',
              ),
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
        ],
      ),
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
          _buildRuleRow('finance.withdraw.minWithdraw'.tr(),
              '$symbol ${minWithdraw > 0 ? minWithdraw.toStringAsFixed(2) : '-'}'),
          _buildRuleRow(
              'finance.withdraw.dailyCount'.tr(),
              dayCount == null
                  ? '-'
                  : 'finance.withdraw.times'
                      .tr(namedArgs: {'count': '$dayCount'})),
          _buildRuleRow(
              'finance.withdraw.dailyLimit'.tr(),
              dayAmount == null
                  ? '-'
                  : '$symbol ${dayAmount.toStringAsFixed(2)}'),
          _buildRuleRow(
              'finance.withdraw.payPassword'.tr(),
              hasPayPassword
                  ? 'finance.withdraw.set'.tr()
                  : 'finance.withdraw.unsetPayPassword'.tr()),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _recycleVenues() async {
    try {
      await context.read<WalletProvider>().recycleVenueBalances();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('finance.withdraw.recycleSuccess'.tr())),
      );
    } catch (_) {
      if (!mounted) return;
      final error = context.read<WalletProvider>().venueActionError ??
          'finance.withdraw.recycleFailed'.tr();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _submitWithdraw({
    required List<WalletCard> cards,
    required double balance,
    required double minWithdraw,
    required bool waterEnough,
    required bool hasPayPassword,
  }) async {
    if (!waterEnough) {
      _showSnack('finance.withdraw.currentWater'.tr(namedArgs: {
        'ok': '-',
        'sum': '-',
      }));
      return;
    }
    if (cards.isEmpty) {
      _showSnack('finance.withdraw.emptyCards'.tr());
      return;
    }
    if (!hasPayPassword) {
      _showSnack('finance.withdraw.unsetPayPassword'.tr());
      return;
    }
    final payPassword = _payPasswordController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(payPassword)) {
      _showSnack(_withdrawText('passwordInvalid', '请输入6位取款密码'));
      return;
    }
    final selectedCard = cards[_activeCardIndex.clamp(0, cards.length - 1)];
    final money = double.tryParse(_amountController.text.trim());
    if (money == null || money <= 0) {
      _showSnack('finance.withdraw.enterAmount'.tr());
      return;
    }
    if (minWithdraw > 0 && money < minWithdraw) {
      _showSnack('finance.withdraw.minSingle'.tr(namedArgs: {
        'amount': minWithdraw.toStringAsFixed(2),
      }));
      return;
    }
    if (money > balance) {
      _showSnack('finance.withdraw.availableBalance'.tr());
      return;
    }

    try {
      await context.read<WalletProvider>().createWithdrawOrder(
            WithdrawRequest(
              id: selectedCard.id,
              money: money,
              payPassword: payPassword,
            ),
          );
      if (!mounted) return;
      _amountController.clear();
      _payPasswordController.clear();
      context.go('/withdraw/success');
    } catch (_) {
      if (!mounted) return;
      final error = context.read<WalletProvider>().withdrawSubmitError ??
          'deposit.detail.submitFailed'.tr();
      _showSnack(error);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  String _withdrawText(String key, String fallback) {
    final localeKey = 'finance.withdraw.$key';
    final value = localeKey.tr();
    return value == localeKey ? fallback : value;
  }
}

class WithdrawSuccessScreen extends StatelessWidget {
  const WithdrawSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomNavBar(
        title: 'finance.withdraw.submitTitle'.tr(),
        showLeftArrow: false,
      ),
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
                'finance.withdraw.submitTitle'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'finance.withdraw.submitHint'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: 'finance.withdraw.viewRecords'.tr(),
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'finance.withdraw.backHome'.tr(),
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
      appBar: CustomNavBar(title: 'deposit.pay.title'.tr()),
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
                    'deposit.pay.title'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    payUrl.isEmpty
                        ? 'deposit.pay.missingLink'.tr()
                        : 'deposit.pay.desc'.tr(),
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
              text: 'deposit.pay.openGateway'.tr(),
              onPressed:
                  payUrl.isEmpty ? null : () => _openPayUrl(context, payUrl),
            ),
            if (orderId?.trim().isNotEmpty == true) ...[
              SizedBox(height: 12.h),
              CustomButton(
                text: 'deposit.pay.viewOrder'.tr(),
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
    if (UrlPolicy.externalUri(url, type: ExternalUrlType.payment) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('deposit.pay.invalidLink'.tr())),
      );
      return;
    }
    final opened = await UrlPolicy.launchExternal(
      url,
      type: ExternalUrlType.payment,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('deposit.pay.openGatewayFailed'.tr())),
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
        'title': 'finance.record.gameSettlement'.tr(),
        'date': '2023-10-24 14:30',
        'amount': '+150.00',
        'status': 'finance.record.completed'.tr(),
        'isPositive': true
      },
      {
        'title': 'finance.record.depositArrived'.tr(),
        'date': '2023-10-23 09:15',
        'amount': '+1000.00',
        'status': 'finance.record.completed'.tr(),
        'isPositive': true
      },
      {
        'title': 'finance.record.buyItem'.tr(),
        'date': '2023-10-22 18:45',
        'amount': '-50.00',
        'status': 'finance.record.completed'.tr(),
        'isPositive': false
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'finance.record.title'.tr()),
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
        'title': 'deposit.wechat'.tr(),
        'date': '2023-10-24 10:20',
        'amount': '500.00',
        'status': 'deposit.detail.statusSuccess'.tr(),
        'type': 'deposit'
      },
      {
        'title': 'finance.withdraw.bankWithdraw'.tr(),
        'date': '2023-10-21 16:40',
        'amount': '2000.00',
        'status': 'deposit.detail.statusProcessing'.tr(),
        'type': 'withdraw'
      },
      {
        'title': 'deposit.alipay'.tr(),
        'date': '2023-10-20 11:10',
        'amount': '100.00',
        'status': 'deposit.detail.statusSuccess'.tr(),
        'type': 'deposit'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'finance.record.fundTitle'.tr()),
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
                        color: record['status'] ==
                                'deposit.detail.statusProcessing'.tr()
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
