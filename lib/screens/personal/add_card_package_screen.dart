import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/screens/personal/card_packages_screen.dart';
import 'package:my_flutter_app/providers/withdraw_provider.dart';

class SelectedTypeNotifier extends Notifier<int> {
   @override
   int build() => 1;
   void set(int value) => this.state = value;
 }
 
 final selectedTypeProvider = NotifierProvider.autoDispose<SelectedTypeNotifier, int>(SelectedTypeNotifier.new);

final bankTypesProvider = FutureProvider.autoDispose.family<List<BankType>, int>((ref, type) async {
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
  ConsumerState<AddCardPackageScreen> createState() => _AddCardPackageScreenState();
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
        address: selectedType == 1 ? _addressController.text.trim() : null, // 仅银行卡需要开户地
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('添加收款方式', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
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
                        child: Text('填写信息', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
                      ),
                      _buildRealNameStatus(isRealNameSet, user?.realName),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cardController,
                        label: selectedType == 1 ? '银行卡号' : (selectedType == 2 ? '卡号/地址' : '账号'),
                        placeholder: selectedType == 1 ? '请输入银行卡号' : '请输入卡号或收款地址',
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
                          validator: (v) => v?.isEmpty ?? true ? '地址不能为空' : null,
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
                        const Text('上传收款码', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666))),
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
                          validator: (v) => v?.isEmpty ?? true ? '密码不能为空' : null,
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
      {'label': '银行卡', 'value': 1, 'emoji': '🏦'},
      {'label': '虚拟币', 'value': 2, 'emoji': '🪙'},
      {'label': '支付宝', 'value': 3, 'emoji': '💳'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = selectedType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedTypeProvider.notifier).set(type['value'] as int);
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
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primary.withAlpha(77), blurRadius: 8, offset: const Offset(0, 4))]
                        : null,
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(type['emoji'] as String, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF666666),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
              child: Text('选择方式', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: banks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bank = banks[index];
                final isSelected = _selectedBank?.id == bank.id;
                
                String? imageUrl = bank.img;
                if (imageUrl != null && !imageUrl.startsWith('http')) {
                  imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedBank = bank),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: WebSafeImage(
                            imageUrl: imageUrl ?? '',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            placeholder: Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.account_balance, size: 20, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            bank.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppTheme.primary : const Color(0xFFDCDCDC),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text('加载失败: $err', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(bankTypesProvider(ref.read(selectedTypeProvider))),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealNameStatus(bool isVerified, String? name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('真实姓名', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isVerified ? const Color(0xFFF6FFED) : const Color(0xFFFFFBE6),
            border: Border.all(color: isVerified ? const Color(0xFFB7EB8F) : const Color(0xFFFFE58F)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name ?? '尚未实名',
                  style: TextStyle(
                    color: isVerified ? const Color(0xFF52C41A) : const Color(0xFFFAAD14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF52C41A),
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
                  child: const Row(
                    children: [
                      Text('去实名', style: TextStyle(color: Color(0xFFFAAD14), fontSize: 12)),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFFFAAD14)),
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
      onTap: _goToSetPayPassword,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBE6),
          border: Border.all(color: const Color(0xFFFFE58F)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: Color(0xFFFAAD14)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('交易密码未设置', style: TextStyle(color: Color(0xFFFAAD14), fontWeight: FontWeight.bold)),
                  Text('请先设置6位数字交易密码', style: TextStyle(color: Color(0xFFFAAD14), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Color(0xFFFAAD14)),
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666))),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary),
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
          backgroundColor: isEnabled ? AppTheme.primary : const Color(0xFFEEEEEE),
          foregroundColor: isEnabled ? Colors.white : const Color(0xFF999999),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('确定绑定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDDDDD), style: BorderStyle.solid),
        ),
        child: _imageBytes != null
            ? Stack(
                children: [
                  Center(child: Image.memory(_imageBytes!, fit: BoxFit.contain)),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _imageFile = null;
                        _imageBytes = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 32, color: Color(0xFF999999)),
                  const SizedBox(height: 12),
                  const Text('点击上传收款码图片', style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('支持 JPG、PNG 格式，大小不超过 5MB', style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                ],
              ),
      ),
    );
  }
}
