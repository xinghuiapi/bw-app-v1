import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_models.dart';
import '../../services/auth_service.dart';
import '../../models/home_data.dart';
import '../../providers/home_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all possible fields
  final Map<String, TextEditingController> _controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
    'o_password': TextEditingController(),
    'pay_password': TextEditingController(),
    'phone': TextEditingController(),
    'phone_code': TextEditingController(),
    'email': TextEditingController(),
    'email_code': TextEditingController(),
    'name': TextEditingController(),
    'qq': TextEditingController(),
    'telegram': TextEditingController(),
    'invicode': TextEditingController(),
    'captcha_code': TextEditingController(),
  };

  final String _areaCode = '86';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscurePayPassword = true;
  CaptchaData? _captchaData;
  bool _isLoadingCaptcha = false;

  @override
  void initState() {
    super.initState();
    _refreshCaptcha();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _refreshCaptcha() async {
    if (_isLoadingCaptcha) return;
    setState(() => _isLoadingCaptcha = true);
    
    final response = await AuthService.getCaptcha();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _captchaData = response.data;
        _isLoadingCaptcha = false;
      });
    } else {
      setState(() => _isLoadingCaptcha = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final request = RegisterRequest(
      username: _controllers['username']!.text.trim(),
      password: _controllers['password']!.text.trim(),
      oPassword: _controllers['o_password']!.text.trim(),
      payPassword: _controllers['pay_password']!.text.trim(),
      phone: _controllers['phone']?.text.trim(),
      areaCode: _areaCode,
      phoneCode: _controllers['phone_code']?.text.trim(),
      email: _controllers['email']?.text.trim(),
      emailCode: _controllers['email_code']?.text.trim(),
      name: _controllers['name']?.text.trim(),
      qq: int.tryParse(_controllers['qq']?.text.trim() ?? ''),
      telegram: _controllers['telegram']?.text.trim(),
      invicode: _controllers['invicode']?.text.trim() ?? '',
      captchaCode: _controllers['captcha_code']?.text.trim(),
      captchaKey: _captchaData?.captchaKey,
    );

    final response = await ref.read(authProvider.notifier).register(request);

    if (mounted) {
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功')),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg ?? '注册失败')),
        );
        _refreshCaptcha();
        _controllers['captcha_code']?.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: homeDataAsync.when(
          data: (homeData) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                
                // Always required fields
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 16),
                _buildPayPasswordField(),
                
                // Dynamic fields from config
                if (homeData.regConfig != null)
                  ...homeData.regConfig!.where((c) => c.status == 1).map((config) {
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildDynamicField(config),
                      ],
                    );
                  }),
                
                // Captcha field if enabled
                if (homeData.picConfig?.status == 1) ...[
                  const SizedBox(height: 16),
                  _buildCaptchaField(),
                ],
                
                const SizedBox(height: 32),
                _buildRegisterButton(authState.isLoading),
                const SizedBox(height: 24),
                _buildLoginPrompt(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('加载配置失败: $err')),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.stars_outlined,
            color: Colors.amber,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '加入我们',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '创建您的账号，开启精彩旅程',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicField(RegConfig config) {
    final isRequired = config.isRequired == 1;
    final String label = config.title ?? config.name ?? '';
    final String name = config.name ?? '';

    switch (name) {
      case 'phone':
        return _buildPhoneField(isRequired, label);
      case 'email':
        return _buildEmailField(isRequired, label);
      case 'name':
        return _buildTextField(
          controller: _controllers['name']!,
          label: label,
          hint: '请输入$label',
          prefixIcon: Icons.badge_outlined,
          validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
        );
      case 'qq':
        return _buildTextField(
          controller: _controllers['qq']!,
          label: label,
          hint: '请输入$label',
          prefixIcon: Icons.chat_bubble_outline,
          keyboardType: TextInputType.number,
          validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
        );
      case 'telegram':
        return _buildTextField(
          controller: _controllers['telegram']!,
          label: label,
          hint: '请输入$label',
          prefixIcon: Icons.send_outlined,
          validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
        );
      case 'invicode':
        return _buildTextField(
          controller: _controllers['invicode']!,
          label: label,
          hint: '请输入$label',
          prefixIcon: Icons.card_giftcard_outlined,
          validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhoneField(bool isRequired, String label) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: _buildTextField(
                controller: TextEditingController(text: '+$_areaCode'),
                label: '区号',
                hint: '+86',
                readOnly: true,
                onTap: () {
                  // TODO: Show Country Code Picker
                },
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _controllers['phone']!,
                label: label,
                hint: '请输入$label',
                prefixIcon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
                validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _controllers['phone_code']!,
                label: '短信验证码',
                hint: '请输入验证码',
                prefixIcon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
                validator: isRequired ? (v) => v?.isEmpty == true ? '请输入验证码' : null : null,
              ),
            ),
            const SizedBox(width: 12),
            _buildGetCodeButton(onPressed: () {
              AuthService.sendSmsCode(_controllers['phone']!.text, _areaCode);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isRequired, String label) {
    return Column(
      children: [
        _buildTextField(
          controller: _controllers['email']!,
          label: label,
          hint: '请输入$label',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: isRequired ? (v) => v?.isEmpty == true ? '请输入$label' : null : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _controllers['email_code']!,
                label: '邮箱验证码',
                hint: '请输入验证码',
                prefixIcon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
                validator: isRequired ? (v) => v?.isEmpty == true ? '请输入验证码' : null : null,
              ),
            ),
            const SizedBox(width: 12),
            _buildGetCodeButton(onPressed: () {
              AuthService.sendEmailCode(_controllers['email']!.text);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildGetCodeButton({required VoidCallback onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: const Text('获取验证码', style: TextStyle(color: AppTheme.primary)),
      ),
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      controller: _controllers['username']!,
      label: '账号',
      hint: '请输入4-9位字母或数字',
      prefixIcon: Icons.person_outline,
      inputFormatters: [
        LengthLimitingTextInputFormatter(9),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入账号';
        if (value.length < 4) return '账号长度至少4位';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _controllers['password']!,
      label: '登录密码',
      hint: '请输入登录密码',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textTertiary,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入密码';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _controllers['o_password']!,
      label: '确认密码',
      hint: '请再次输入密码',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textTertiary,
          size: 20,
        ),
        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请确认密码';
        if (value != _controllers['password']!.text) return '两次输入的密码不一致';
        return null;
      },
    );
  }

  Widget _buildPayPasswordField() {
    return _buildTextField(
      controller: _controllers['pay_password']!,
      label: '支付密码',
      hint: '请输入6位数字支付密码',
      prefixIcon: Icons.security_outlined,
      obscureText: _obscurePayPassword,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.digitsOnly,
      ],
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePayPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textTertiary,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePayPassword = !_obscurePayPassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入支付密码';
        if (value.length != 6) return '支付密码必须为6位数字';
        return null;
      },
    );
  }

  Widget _buildCaptchaField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _controllers['captcha_code']!,
            label: '验证码',
            hint: '请输入图形验证码',
            prefixIcon: Icons.verified_user_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入验证码';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        _buildCaptchaImage(),
      ],
    );
  }

  Widget _buildCaptchaImage() {
    return GestureDetector(
      onTap: _refreshCaptcha,
      child: Container(
        width: 120,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: _isLoadingCaptcha
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : _captchaData != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(_captchaData!.captchaImageContent.split(',').last),
                      fit: BoxFit.fill,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textTertiary, size: 20) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                '立即注册',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '已有账号?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            '返回登录',
            style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
