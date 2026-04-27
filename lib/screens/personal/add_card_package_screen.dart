import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/services/wallet/finance_service.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';
import 'package:my_flutter_app/models/wallet/finance_models.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/screens/personal/card_packages_screen.dart';
import 'package:my_flutter_app/providers/wallet/withdraw_provider.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class SelectedTypeNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void set(int value) => this.state = value;
}

final selectedTypeProvider =
    NotifierProvider.autoDispose<SelectedTypeNotifier, int>(
      SelectedTypeNotifier.new,
    );

final bankTypesProvider = FutureProvider.autoDispose
    .family<List<BankType>, int>((ref, type) async {
      final response = await FinanceService.getBankTypes(type);
      if (response.code == 200) {
        return response.data ?? [];
      } else {
        throw Exception(response.msg ?? '获取银行列表失败');
      }
    });

class AddCardPackageScreen extends ConsumerStatefulWidget {
  const AddCardPackageScreen({super.key});

  @override
  ConsumerState<AddCardPackageScreen> createState() =>
      _AddCardPackageScreenState();
}

class _AddCardPackageScreenState extends ConsumerState<AddCardPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _aliasController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _payPasswordController = TextEditingController();

  BankType? _selectedBank;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isSubmitting = false;
  bool _banksExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserInfo();
    });
  }

  void _checkUserInfo() {
    final user = ref.read(userProvider).user;
    if (user == null) return;

    if (user.realName != null && user.realName!.isNotEmpty) {
      _nameController.text = user.realName!;
    }
  }

  void _goToBindRealName() {
    context.push('/personal-center-profile-realname');
  }

  void _goToSetPayPassword() {
    context.push('/personal-center-profile-paypassword');
  }

  @override
  void dispose() {
    _cardController.dispose();
    _aliasController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _payPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageFile = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    final user = ref.read(userProvider).user;
    if (user == null) return;

    if (user.realName == null || user.realName!.isEmpty) {
      ToastUtils.showError('请先完成实名认证');
      _goToBindRealName();
      return;
    }

    if (!user.hasPayPassword) {
      ToastUtils.showError('请先设置交易密码');
      _goToSetPayPassword();
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      ToastUtils.showError('请选择银行/平台');
      return;
    }

    final selectedType = ref.read(selectedTypeProvider);
    if (selectedType != 1 && _imageBytes == null) {
      ToastUtils.showError('请上传收款二维码');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? uploadedImageUrl;
      if (selectedType != 1 && _imageBytes != null) {
        final uploadResponse = await FinanceService.uploadImage(_imageBytes!);
        if (uploadResponse.code == 200) {
          uploadedImageUrl = uploadResponse.data;
        } else {
          ToastUtils.showError(uploadResponse.msg ?? '二维码上传失败');
          setState(() => _isSubmitting = false);
          return;
        }
      }

      final request = BindPaymentRequest(
        id: _selectedBank!.id,
        card: _cardController.text.trim(),
        alias: _aliasController.text.trim(),
        name: user.realName!, // 使用实名
        address: selectedType == 1
            ? _addressController.text.trim()
            : null, // 仅银行卡需要开户地
        img: selectedType != 1 ? uploadedImageUrl : null, // 虚拟币/支付宝需要二维码
        payPassword: _payPasswordController.text.trim(),
      );

      final response = await FinanceService.bindPaymentMethod(request);
      if (response.code == 200) {
        ToastUtils.showSuccess('绑定成功');
        if (mounted) {
          // 刷新用户信息和收款方式列表
          ref.refresh(userProvider.notifier).fetchUserInfo();
          // 如果 CardPackagesScreen 中定义了 paymentMethodsProvider，尝试刷新它
          // 由于 paymentMethodsProvider 定义在 card_packages_screen.dart 中，
          // 我们需要确保能访问到它，或者通过 ref.invalidate 刷新
          try {
            // 尝试通过 invalidate 刷新收款方式列表
            // 注意：这里需要导入对应的 provider，或者如果 provider 是全局的可以直接引用
            // 在 card_packages_screen.dart 中定义的是全局的 paymentMethodsProvider
            ref.invalidate(paymentMethodsProvider);
            // 同时刷新提现页面的 provider，确保数据同步
            ref.invalidate(withdrawProvider);
          } catch (e) {
            debugPrint('Refresh paymentMethodsProvider failed: $e');
          }

          context.pop();
        }
      } else {
        ToastUtils.showError(response.msg ?? '绑定失败');
      }
    } catch (e) {
      ToastUtils.showError('操作失败: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedTypeProvider);
    final bankTypesAsync = ref.watch(bankTypesProvider(selectedType));
    final user = ref.watch(userProvider).user;
    final isRealNameSet = user?.realName != null && user!.realName!.isNotEmpty;
    final hasPayPassword = user?.hasPayPassword ?? false;

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          '添加收款方式',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        foregroundColor: AppTheme.getTextPrimary(context),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTypeSelector(selectedType),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBankGrid(bankTypesAsync),
                    if (_selectedBank != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 12),
                        child: Text(
                          '填写信息',
                          style: TextStyle(fontSize: 14),
                        ), // Removed color to use default or inherited
                      ),
                      _buildRealNameStatus(isRealNameSet, user?.realName),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cardController,
                        label: selectedType == 1
                            ? '银行卡号'
                            : (selectedType == 2 ? '卡号/地址' : '账号'),
                        placeholder: selectedType == 1
                            ? '请输入银行卡号'
                            : '请输入卡号或收款地址',
                        required: true,
                        validator: (v) => v?.isEmpty ?? true ? '不能为空' : null,
                      ),
                      const SizedBox(height: 16),
                      if (selectedType == 1) ...[
                        _buildTextField(
                          controller: _addressController,
                          label: '开户行地址',
                          placeholder: '请输入开户行详细地址',
                          required: true,
                          validator: (v) =>
                              v?.isEmpty ?? true ? '地址不能为空' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _aliasController,
                        label: '备注',
                        placeholder: '请输入备注 (选填)',
                      ),
                      const SizedBox(height: 16),
                      if (selectedType != 1) ...[
                        Text(
                          '上传收款码',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildImagePicker(),
                        const SizedBox(height: 16),
                      ],
                      if (hasPayPassword) ...[
                        _buildTextField(
                          controller: _payPasswordController,
                          label: '交易密码',
                          placeholder: '请输入6位交易密码',
                          obscureText: true,
                          required: true,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty ?? true ? '密码不能为空' : null,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildPayPasswordStatus(),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(int selectedType) {
    final types = [
      {'label': '银行卡', 'value': 1, 'icon': Icons.account_balance},
      {'label': '虚拟币', 'value': 2, 'icon': Icons.currency_bitcoin},
      {'label': '支付宝', 'value': 3, 'icon': Icons.payment},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.getInputFillColor(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = selectedType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(selectedTypeProvider.notifier)
                    .set(type['value'] as int);
                setState(() {
                  _selectedBank = null;
                  _banksExpanded = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  // Removed BoxShadow for web optimization
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getTextSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.getTextSecondary(context),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBankGrid(AsyncValue<List<BankType>> bankTypesAsync) {
    return bankTypesAsync.when(
      data: (banks) {
        if (banks.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('选择方式', style: TextStyle(fontSize: 14)),
            ),
            Column(
              children: List.generate(banks.length, (index) {
                final bank = banks[index];
                final isSelected = _selectedBank?.id == bank.id;

                String? imageUrl = bank.img;
                if (imageUrl != null && !imageUrl.startsWith('http')) {
                  imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < banks.length - 1 ? 10.0 : 0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedBank = bank),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.getDividerColor(context),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          WebSafeImage(
                            imageUrl: imageUrl ?? '',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            borderRadius: BorderRadius.circular(8),
                            placeholder: Container(
                              color: AppTheme.getPlaceholderColor(context),
                              child: Icon(
                                Icons.account_balance,
                                size: 20,
                                color: AppTheme.getPlaceholderColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bank.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.getTextPrimary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.getPlaceholderColor(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, _) => ErrorStateWidget(
        message: '加载失败: $err',
        onRetry: () => ref.refresh(
          bankTypesProvider(ref.read(selectedTypeProvider)),
        ),
      ),
    );
  }

  Widget _buildRealNameStatus(bool isVerified, String? name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '真实姓名',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isVerified
                ? AppTheme.success.withAlpha(25)
                : AppTheme.warning.withAlpha(25),
            border: Border.all(
              color: isVerified
                  ? AppTheme.success.withAlpha(100)
                  : AppTheme.warning.withAlpha(100),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name ?? '尚未实名',
                  style: TextStyle(
                    color: isVerified ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '已实名',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                )
              else
                GestureDetector(
                  onTap: _goToBindRealName,
                  child: Row(
                    children: [
                      Text(
                        '去实名',
                        style: TextStyle(color: AppTheme.warning, fontSize: 12),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayPasswordStatus() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _goToSetPayPassword,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withAlpha(25),
          border: Border.all(color: AppTheme.warning.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: AppTheme.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '交易密码未设置',
                    style: TextStyle(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '请先设置6位数字交易密码',
                    style: TextStyle(color: AppTheme.warning, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool obscureText = false,
    bool enabled = true,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(color: AppTheme.error, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: AppTheme.getPlaceholderColor(context),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _selectedBank != null && !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppTheme.primary
              : AppTheme.getDisabledColor(context),
          foregroundColor: isEnabled
              ? Colors.white
              : AppTheme.getDisabledTextColor(context),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '确定绑定',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: AppTheme.getInputFillColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.getDividerColor(context)),
        ),
        child: _imageBytes != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(_imageBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    color: AppTheme.getPlaceholderColor(context),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击上传',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getPlaceholderColor(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
