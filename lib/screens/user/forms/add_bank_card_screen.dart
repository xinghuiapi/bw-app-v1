import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/wallet/wallet_models.dart';
import '../../../providers/user/user_provider.dart';
import '../../../providers/wallet/wallet_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/common/app_network_image.dart';
import '../../../widgets/common/app_loading.dart';

class AddBankCardScreen extends StatefulWidget {
  const AddBankCardScreen({super.key});

  @override
  State<AddBankCardScreen> createState() => _AddBankCardScreenState();
}

class _AddBankCardScreenState extends State<AddBankCardScreen> {
  final _cardController = TextEditingController();
  final _branchController = TextEditingController();
  final _aliasController = TextEditingController();
  final _imagePicker = ImagePicker();

  int _selectedCategory = 1;
  CardType? _selectedCardType;
  _CardUploadImage? _qrImage;

  static const _categories = <int, String>{
    1: '银行卡',
    2: '虚拟币',
    3: '支付宝',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadProfile();
      context.read<WalletProvider>().loadCardTypes(_selectedCategory);
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _branchController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final realName = profile?.realName?.trim() ?? '';
    final hasRealName = realName.isNotEmpty;
    final availableTypes = walletProvider.cardTypes[_selectedCategory] ?? [];
    if (_selectedCardType != null &&
        !availableTypes.any((type) => type.id == _selectedCardType!.id)) {
      _selectedCardType = null;
    }
    if (_selectedCategory == 3 &&
        _selectedCardType == null &&
        availableTypes.isNotEmpty) {
      _selectedCardType = availableTypes.first;
    }
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA), // Light gray background matching design
      appBar: const CustomNavBar(title: '添加银行卡'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Type Selector ---
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                child: Text(
                  '请选择收款类型',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF5C6573),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTypeItem(1, '银行卡'),
                  SizedBox(width: 12.w),
                  _buildTypeItem(2, '虚拟币'),
                  SizedBox(width: 12.w),
                  _buildTypeItem(3, '支付宝'),
                ],
              ),
              SizedBox(height: 20.h),
              _buildSupportedTypes(walletProvider, availableTypes),
              SizedBox(height: 20.h),

              // --- 2. Form Card ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    if (_selectedCategory != 2) ...[
                      _buildFormRow(
                        label: '姓名',
                        child: Text(
                          hasRealName ? realName : '请先完成实名',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasRealName
                                ? AppColors.textPrimary
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                        ),
                        trailing: hasRealName
                            ? null
                            : GestureDetector(
                                onTap: () => context.push('/real-name'),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    '去认证',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      _buildDivider(),
                    ],
                    if (_selectedCategory != 1) ...[
                      _buildFormRow(
                        label: _selectedCategory == 2 ? '收款类型' : '账户类型',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showTypePicker(walletProvider),
                          child: Text(
                            _selectedCardType?.displayName.isNotEmpty == true
                                ? _selectedCardType!.displayName
                                : '请选择${_categories[_selectedCategory]}类型',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedCardType == null
                                  ? AppColors.textSecondary
                                      .withValues(alpha: 0.5)
                                  : AppColors.textPrimary,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        trailing: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showTypePicker(walletProvider),
                          child: Icon(
                            Icons.chevron_right,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 20.sp,
                          ),
                        ),
                      ),
                      _buildDivider(),
                    ],
                    if (_selectedCategory == 1) ...[
                      _buildFormRow(
                        label: '开户银行',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showTypePicker(walletProvider),
                          child: Text(
                            _selectedCardType?.displayName.isNotEmpty == true
                                ? _selectedCardType!.displayName
                                : '请选择开户银行',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedCardType == null
                                  ? AppColors.textSecondary
                                      .withValues(alpha: 0.5)
                                  : AppColors.textPrimary,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        trailing: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showTypePicker(walletProvider),
                          child: Icon(
                            Icons.chevron_right,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 20.sp,
                          ),
                        ),
                      ),
                      _buildDivider(),
                    ],
                    _buildFormRow(
                      label: switch (_selectedCategory) {
                        2 => '收款地址',
                        3 => '支付宝账号',
                        _ => '银行卡号',
                      },
                      child: TextField(
                        controller: _cardController,
                        keyboardType: _selectedCategory == 2
                            ? TextInputType.text
                            : TextInputType.number,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: switch (_selectedCategory) {
                            2 => '请输入虚拟币收款地址',
                            3 => '请输入支付宝账号',
                            _ => '请输入银行卡号',
                          },
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    if (_selectedCategory == 1) ...[
                      _buildFormRow(
                        label: '开户支行',
                        child: TextField(
                          controller: _branchController,
                          style: TextStyle(
                              fontSize: 15.sp, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '请输入开户支行(选填)',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5),
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      _buildDivider(),
                    ],
                    _buildFormRow(
                      label: '别名备注',
                      child: TextField(
                        controller: _aliasController,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '请输入别名备注(选填)',
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_selectedCategory != 1) ...[
                      _buildDivider(),
                      _buildQrUploadRow(walletProvider),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // --- 3. Submit Button ---
              CustomButton(
                text: walletProvider.isBindingCard ? '提交中...' : '确认添加',
                onPressed: walletProvider.isBindingCard
                    ? null
                    : () => _submit(walletProvider, hasRealName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeItem(int category, String title) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _selectedCardType = null;
            _cardController.clear();
            _branchController.clear();
            _aliasController.clear();
            _qrImage = null;
          });
          context.read<WalletProvider>().loadCardTypes(category);
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportedTypes(
    WalletProvider walletProvider,
    List<CardType> availableTypes,
  ) {
    final isLoading = walletProvider.isCardTypeLoading(_selectedCategory);
    final error = walletProvider.cardTypeError(_selectedCategory);
    if (isLoading && availableTypes.isEmpty) {
      return Container(
        height: 72.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const AppLoading(message: '类型加载中...'),
      );
    }

    if (availableTypes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          error == null
              ? '暂无${_categories[_selectedCategory]}类型，请稍后刷新'
              : '${_categories[_selectedCategory]}类型暂未同步，$error',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            height: 1.4,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '请选择${_categories[_selectedCategory]}类型',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: availableTypes.map((type) {
              final isSelected = _selectedCardType?.id == type.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCardType = type;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    type.displayName.isEmpty ? '未命名类型' : type.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQrUploadRow(WalletProvider walletProvider) {
    final isUploading = walletProvider.isUploadingCardImage;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '收款码',
              style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap:
                      isUploading ? null : () => _pickQrImage(walletProvider),
                  child: Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    child: _qrImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isUploading ? Icons.hourglass_empty : Icons.add,
                                size: 24.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isUploading ? '上传中' : '上传',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              AppNetworkImage(
                                url: _qrImage!.previewUrl,
                                width: 88.w,
                                height: 88.w,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              Positioned(
                                right: 4.w,
                                top: 4.w,
                                child: GestureDetector(
                                  onTap: () => setState(() => _qrImage = null),
                                  child: Container(
                                    width: 20.w,
                                    height: 20.w,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close,
                                        size: 14.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '选填：上传收款二维码',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTypePicker(WalletProvider walletProvider) async {
    final availableTypes = walletProvider.cardTypes[_selectedCategory] ?? [];
    if (walletProvider.isCardTypeLoading(_selectedCategory)) {
      _showSnack('类型加载中，请稍候');
      return;
    }
    if (availableTypes.isEmpty) {
      await walletProvider.loadCardTypes(_selectedCategory, refresh: true);
      if (!mounted) return;
    }

    final latestTypes = walletProvider.cardTypes[_selectedCategory] ?? [];
    if (latestTypes.isEmpty) {
      _showSnack(
        walletProvider.cardTypeError(_selectedCategory) ??
            '暂无${_categories[_selectedCategory]}类型',
      );
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var keyword = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredTypes = latestTypes.where((type) {
              final name = type.displayName.toLowerCase();
              if (keyword.isEmpty) return true;
              return name.contains(keyword.toLowerCase());
            }).toList();

            return SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                constraints: BoxConstraints(maxHeight: 560.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24.r,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.h),
                    Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                    _buildPickerHeader(sheetContext),
                    _buildPickerSearch(
                        setSheetState, (value) => keyword = value),
                    SizedBox(height: 10.h),
                    Flexible(
                        child: _buildPickerList(sheetContext, filteredTypes)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPickerHeader(BuildContext sheetContext) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_pickerIcon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pickerTitle,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '请选择一个可用收款类型',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            icon:
                Icon(Icons.close, size: 20.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSearch(
    void Function(void Function()) setSheetState,
    ValueChanged<String> onKeywordChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: TextField(
          onChanged: (value) =>
              setSheetState(() => onKeywordChanged(value.trim())),
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.search, size: 20.sp, color: AppColors.textSecondary),
            hintText: '搜索${_categories[_selectedCategory]}类型',
            hintStyle:
                TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildPickerList(BuildContext sheetContext, List<CardType> types) {
    if (types.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 36.h),
          child: Text(
            '未找到匹配的类型',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final selected = _selectedCardType?.id == type.id;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              setState(() => _selectedCardType = type);
              Navigator.of(sheetContext).pop();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _pickerIcon,
                      size: 18.sp,
                      color: selected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      type.displayName.isEmpty ? '未命名类型' : type.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20.sp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String get _pickerTitle {
    if (_selectedCategory == 1) return '选择开户银行';
    if (_selectedCategory == 2) return '选择虚拟币类型';
    return '选择支付宝类型';
  }

  IconData get _pickerIcon {
    if (_selectedCategory == 1) return Icons.account_balance;
    if (_selectedCategory == 2) return Icons.currency_bitcoin;
    return Icons.payments_outlined;
  }

  Widget _buildFormRow({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.3),
    );
  }

  Future<void> _submit(WalletProvider walletProvider, bool hasRealName) async {
    if (walletProvider.isBindingCard) return;
    if ((_selectedCategory == 1 || _selectedCategory == 3) && !hasRealName) {
      _showSnack('请先完成实名认证');
      return;
    }

    final selectedType = _selectedCardType;
    if (selectedType == null || selectedType.id <= 0) {
      _showSnack('请选择${_categories[_selectedCategory]}类型');
      return;
    }

    final card = _cardController.text.trim();
    if (card.isEmpty) {
      _showSnack(switch (_selectedCategory) {
        2 => '请输入虚拟币收款地址',
        3 => '请输入支付宝账号',
        _ => '请输入银行卡号',
      });
      return;
    }

    final request = BindCardRequest(
      id: selectedType.id,
      card: card,
      address: _selectedCategory == 1 ? _branchController.text.trim() : '',
      alias: _aliasController.text.trim(),
      img: _qrImage?.submitValue ?? '',
    );

    try {
      await walletProvider.bindCard(request);
      if (!mounted) return;
      _showSnack('绑定成功');
      context.pop();
    } catch (_) {
      if (!mounted) return;
      _showSnack(walletProvider.bindCardError ?? '绑定失败');
    }
  }

  Future<void> _pickQrImage(WalletProvider walletProvider) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final result = await walletProvider.uploadCardImage(
        bytes: await file.readAsBytes(),
        filename: file.name,
      );
      final submitValue = result.path?.trim().isNotEmpty == true
          ? result.path!.trim()
          : result.url?.trim();
      final previewUrl = result.url?.trim().isNotEmpty == true
          ? result.url!.trim()
          : submitValue;
      if (submitValue == null || submitValue.isEmpty || previewUrl == null) {
        throw const FormatException('Upload response missing image path');
      }
      if (!mounted) return;
      setState(() {
        _qrImage = _CardUploadImage(
          previewUrl: previewUrl,
          submitValue: submitValue,
        );
      });
    } on MissingPluginException {
      if (!mounted) return;
      _showSnack('图片选择组件未加载，请完整重启应用后重试');
    } catch (_) {
      if (!mounted) return;
      _showSnack(walletProvider.cardImageUploadError ?? '二维码上传失败');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CardUploadImage {
  const _CardUploadImage({
    required this.previewUrl,
    required this.submitValue,
  });

  final String previewUrl;
  final String submitValue;
}
