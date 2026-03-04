import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_models.dart';
import '../../services/auth_service.dart';
import '../../providers/home_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _emailCodeController = TextEditingController();
  
  late TabController _tabController;
  int _loginType = 1; // 1: Username, 2: Email, 3: Phone
  final String _areaCode = '86';
  
  bool _obscurePassword = true;
  CaptchaData? _captchaData;
  bool _isLoadingCaptcha = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _loginType = _tabController.index == 0 ? 1 : (_tabController.index == 1 ? 3 : 2);
      });
    });
    _refreshCaptcha();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _smsCodeController.dispose();
    _emailCodeController.dispose();
    _tabController.dispose();
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    LoginRequest request;
    if (_loginType == 1) {
      request = LoginRequest(
        type: 1,
        username: _accountController.text.trim(),
        password: _passwordController.text.trim(),
        captchaCode: _captchaController.text.trim(),
        captchaKey: _captchaData?.captchaKey,
      );
    } else if (_loginType == 3) {
      final phone = _phoneController.text.trim();
      request = LoginRequest(
        type: 3,
        username: phone, // 示例说明 username 也可以是手机号
        phone: phone,
        areaCode: _areaCode,
        phoneCode: _smsCodeController.text.trim(),
        captchaCode: _captchaController.text.trim(),
        captchaKey: _captchaData?.captchaKey,
      );
    } else {
      final email = _emailController.text.trim();
      request = LoginRequest(
        type: 2,
        username: email, // 示例说明 username 也可以是邮箱
        email: email,
        emailCode: _emailCodeController.text.trim(),
        captchaCode: _captchaController.text.trim(),
        captchaKey: _captchaData?.captchaKey,
      );
    }

    final response = await ref.read(authProvider.notifier).login(request);

    if (mounted) {
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!);
        } else {
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg ?? '登录失败')),
        );
        _refreshCaptcha();
        _captchaController.clear();
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
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '账号登录'),
            Tab(text: '手机登录'),
            Tab(text: '邮箱登录'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
        ),
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
                const SizedBox(height: 30),
                SizedBox(
                  height: 100, // Fixed height for fields to avoid layout shift
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildUsernameField(),
                      _buildPhoneField(),
                      _buildEmailField(),
                    ],
                  ),
                ),
                if (_loginType == 1) ...[
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                ] else if (_loginType == 3) ...[
                  const SizedBox(height: 20),
                  _buildSmsCodeField(),
                ] else ...[
                  const SizedBox(height: 20),
                  _buildEmailCodeField(),
                ],
                if (homeData.picConfig?.status == 1) ...[
                  const SizedBox(height: 20),
                  _buildCaptchaField(),
                ],
                const SizedBox(height: 12),
                _buildForgotPassword(),
                const SizedBox(height: 40),
                _buildLoginButton(authState.isLoading),
                const SizedBox(height: 24),
                _buildRegisterPrompt(),
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

  Widget _buildPhoneField() {
    return Row(
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
            controller: _phoneController,
            label: '手机号',
            hint: '请输入手机号',
            prefixIcon: Icons.phone_iphone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (_loginType == 3 && (value == null || value.isEmpty)) return '请输入手机号';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: '邮箱',
      hint: '请输入邮箱地址',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (_loginType == 2 && (value == null || value.isEmpty)) return '请输入邮箱';
        return null;
      },
    );
  }

  Widget _buildSmsCodeField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _smsCodeController,
            label: '验证码',
            hint: '短信验证码',
            prefixIcon: Icons.verified_user_outlined,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        _buildGetCodeButton(onPressed: () {
          AuthService.sendSmsCode(_phoneController.text, _areaCode, type: 1);
        }),
      ],
    );
  }

  Widget _buildEmailCodeField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _emailCodeController,
            label: '验证码',
            hint: '邮箱验证码',
            prefixIcon: Icons.verified_user_outlined,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        _buildGetCodeButton(onPressed: () {
          AuthService.sendEmailCode(_emailController.text, type: 1);
        }),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: Colors.deepPurpleAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '欢迎回来',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '请登录您的账号以继续',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      controller: _accountController,
      label: '账号',
      hint: '请输入账号',
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (_loginType == 1 && (value == null || value.isEmpty)) return '请输入账号';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: '密码',
      hint: '请输入密码',
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

  Widget _buildCaptchaField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            controller: _captchaController,
            label: '验证码',
            hint: '请输入验证码',
            prefixIcon: Icons.verified_user_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入验证码';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _refreshCaptcha,
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(top: 26),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _isLoadingCaptcha
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : _captchaData != null
                        ? Image.memory(
                            base64Decode(_captchaData!.captchaImageContent.split(',').last),
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.refresh, color: AppTheme.textTertiary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
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
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.push('/password-reset'),
        child: const Text(
          '忘记密码?',
          style: TextStyle(color: AppTheme.primary, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                '立即登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '还没有账号?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text(
            '立即注册',
            style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
