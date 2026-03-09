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
        address: selectedType == 1 ? _addressController.text.trim() : uploadedImageUrl,
        payPassword: _payPasswordController.text.trim(),
      );

      final response = await FinanceService.bindPaymentMethod(request);
      if (response.code == 200) {
        ToastUtils.showSuccess('绑定成功');
        if (mounted) {
          ref.refresh(userProvider.notifier).fetchUserInfo();
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
                      const SizedBox(height: 24),
                      const Text('填写信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildRealNameStatus(isRealNameSet, user?.realName),
                      if (!hasPayPassword) ...[
                        const SizedBox(height: 12),
                        _buildPayPasswordStatus(),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cardController,
                        label: selectedType == 1 ? '银行卡号' : (selectedType == 2 ? '钱包地址' : '账号'),
                        placeholder: '请输入账号/地址',
                        required: true,
                        validator: (v) => v?.isEmpty ?? true ? '不能为空' : null,
                      ),
                      if (selectedType == 1) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: '开户行地址',
                          placeholder: '请输入开户行详细地址',
                          required: true,
                          validator: (v) => v?.isEmpty ?? true ? '地址不能为空' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _aliasController,
                        label: '备注名',
                        placeholder: '例如：常用卡',
                      ),
                      if (selectedType != 1) ...[
                        const SizedBox(height: 16),
                        const Text('上传收款码', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666))),
                        const SizedBox(height: 8),
                        _buildImagePicker(),
                      ],
                      if (hasPayPassword) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _payPasswordController,
                          label: '交易密码',
                          placeholder: '请输入6位交易密码',
                          obscureText: true,
                          required: true,
                          keyboardType: TextInputType.number,
                          validator: (v) => v?.isEmpty ?? true ? '密码不能为空' : null,
                        ),
                      ],
                      const SizedBox(height: 40),
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
      {'label': '数字货币', 'value': 2, 'emoji': '🪙'},
      {'label': '第三方', 'value': 3, 'emoji': '💳'},
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
        
        final displayedBanks = _banksExpanded || banks.length <= 4 
            ? banks 
            : banks.sublist(0, 4);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择支付方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: displayedBanks.length,
              itemBuilder: (context, index) {
                final bank = displayedBanks[index];
                final isSelected = _selectedBank?.id == bank.id;
                
                String? imageUrl = bank.img;
                if (imageUrl != null && !imageUrl.startsWith('http')) {
                  imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedBank = bank),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF1F1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 1.5,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bank.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (banks.length > 4) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _banksExpanded = !_banksExpanded),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _banksExpanded ? '收起部分' : '查看更多 (${banks.length - 4})',
                        style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _banksExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                        color: const Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      )),
      error: (err, _) => Center(child: Text('加载失败: $err')),
    );
  }

  Widget _buildRealNameStatus(bool isVerified, String? name) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FFED),
          border: Border.all(color: const Color(0xFFB7EB8F)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user, size: 18, color: Color(0xFF52C41A)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '持卡人姓名：$name',
                style: const TextStyle(color: Color(0xFF52C41A), fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              '已实名',
              style: TextStyle(fontSize: 12, color: Color(0xFF52C41A)),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: _goToBindRealName,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBE6),
            border: Border.all(color: const Color(0xFFFFE58F)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFFAAD14)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('尚未实名', style: TextStyle(color: Color(0xFFFAAD14), fontWeight: FontWeight.bold)),
                    Text('请先完善真实姓名', style: TextStyle(color: Color(0xFFFAAD14), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Color(0xFFFAAD14)),
            ],
          ),
        ),
      );
    }
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666))),
              if (required)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('确认添加', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: _imageBytes != null
            ? Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo, color: Color(0xFF999999), size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text('上传二维码图片', style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('支持 JPG、PNG 格式，不超过 5MB', style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                ],
              ),
      ),
    );
  }
}
