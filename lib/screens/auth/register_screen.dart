import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../models/auth/auth_models.dart';
import '../../models/home/home_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/captcha_image.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _qqController = TextEditingController();
  final _telegramController = TextEditingController();
  final _inviteController = TextEditingController();
  final _payPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _showPayPassword = false;
  final String _selectedCountryCode = '+86';
  String? _formError;
  int _smsCountdown = 0;
  int _emailCountdown = 0;
  Timer? _smsTimer;
  Timer? _emailTimer;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _phoneCodeController.dispose();
    _emailController.dispose();
    _emailCodeController.dispose();
    _nameController.dispose();
    _qqController.dispose();
    _telegramController.dispose();
    _inviteController.dispose();
    _payPasswordController.dispose();
    _captchaController.dispose();
    _smsTimer?.cancel();
    _emailTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF99CEFF),
              Color(0xFFB3D9FA),
              Color(0xFFD1E7FF),
              Color(0xFFE8F3FF),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildRegisterCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          EdgeInsets.only(left: 24.w, right: 24.w, top: 20.h, bottom: 32.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: const Color.fromRGBO(51, 51, 51, 0.85),
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                '欢迎注册',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                  letterSpacing: 1.w,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildTag('极速提款'),
                  SizedBox(width: 16.w),
                  _buildTag('数据安全'),
                  SizedBox(width: 16.w),
                  _buildTag('权威认证'),
                ],
              ),
            ],
          ),
          Positioned(
            right: 11.w,
            top: 15.h,
            child: Transform.rotate(
              angle: 15 * 3.1415926535897932 / 180,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFA6CFFF), Color(0xFFD4E8FF)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 40.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: AppColors.primary, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    final systemProvider = context.watch<SystemProvider>();
    if (!systemProvider.hasLoadedConfig) {
      return _buildRegisterCardShell(
        child: SizedBox(
          height: 360.h,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final config = systemProvider.config;
    final showCaptcha = config.captchaConfig?.regStatus == 1;
    if (showCaptcha && context.read<AuthProvider>().captcha == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AuthProvider>().loadCaptcha();
      });
    }

    return _buildRegisterCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('账号'),
          _buildInputField(
            controller: _accountController,
            placeholder: '请输入账号',
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel('密码'),
          _buildInputField(
            controller: _passwordController,
            placeholder: '请输入密码',
            obscureText: !_showPassword,
            suffixIcon: _buildPasswordToggle(
              visible: _showPassword,
              onTap: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel('确认密码'),
          _buildInputField(
            controller: _confirmPasswordController,
            placeholder: '请确认密码',
            obscureText: !_showConfirmPassword,
            suffixIcon: _buildPasswordToggle(
              visible: _showConfirmPassword,
              onTap: () => setState(
                () => _showConfirmPassword = !_showConfirmPassword,
              ),
            ),
          ),
          ..._buildConfiguredFields(config),
          if (showCaptcha) ...[
            SizedBox(height: 20.h),
            _buildCaptchaForm(),
          ],
          if (_formError != null) ...[
            SizedBox(height: 12.h),
            Text(
              _formError!,
              style: TextStyle(
                color: const Color(0xFFE74C3C),
                fontSize: 13.sp,
              ),
            ),
          ],
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ).copyWith(elevation: WidgetStateProperty.all(4)),
              onPressed: context.watch<AuthProvider>().isSubmitting
                  ? null
                  : () => _submitRegister(config, showCaptcha: showCaptcha),
              child: context.watch<AuthProvider>().isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '注 册',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '已有账号？ ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      '立即登录',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/'),
                child: Text(
                  '先去逛逛',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCardShell({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }

  List<Widget> _buildConfiguredFields(HomeConfig config) {
    final widgets = <Widget>[];
    for (final field in config.registerConfig.where((item) => item.isVisible)) {
      widgets.add(SizedBox(height: 20.h));
      switch (field.code) {
        case 'phone':
          widgets.add(_buildPhoneField(config, field));
          break;
        case 'email':
          widgets.add(_buildEmailField(config, field));
          break;
        case 'name':
          widgets.add(_buildSimpleField(field, _nameController, '请输入真实姓名'));
          break;
        case 'qq':
          widgets.add(_buildSimpleField(field, _qqController, '请输入QQ'));
          break;
        case 'telegram':
          widgets.add(
              _buildSimpleField(field, _telegramController, '请输入Telegram'));
          break;
        case 'invicode':
          widgets.add(_buildSimpleField(field, _inviteController, '请输入邀请码'));
          break;
        case 'pay_password':
          widgets.add(_buildPayPasswordField(field));
          break;
      }
    }
    return widgets;
  }

  Widget _buildSimpleField(
    RegisterFieldConfig field,
    TextEditingController controller,
    String placeholder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_fieldTitle(field)),
        _buildInputField(controller: controller, placeholder: placeholder),
      ],
    );
  }

  Widget _buildPhoneField(HomeConfig config, RegisterFieldConfig field) {
    final needsCode = config.smsConfig?.regStatus == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_fieldTitle(field)),
        _buildInputField(
          controller: _phoneController,
          placeholder: '请输入手机号',
          keyboardType: TextInputType.phone,
          prefixWidget: _buildAreaCodePrefix(),
        ),
        if (needsCode) ...[
          SizedBox(height: 20.h),
          _buildFieldLabel('短信验证码'),
          _buildInputField(
            controller: _phoneCodeController,
            placeholder: '请输入验证码',
            keyboardType: TextInputType.number,
            suffixIcon: _buildCodeButton(
              sending: context.watch<AuthProvider>().isSendingSmsCode,
              countdown: _smsCountdown,
              onTap: _smsCountdown > 0 ? null : _sendSmsCode,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField(HomeConfig config, RegisterFieldConfig field) {
    final needsCode = config.mailConfig?.regStatus == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_fieldTitle(field)),
        _buildInputField(
          controller: _emailController,
          placeholder: '请输入邮箱地址',
          keyboardType: TextInputType.emailAddress,
        ),
        if (needsCode) ...[
          SizedBox(height: 20.h),
          _buildFieldLabel('邮箱验证码'),
          _buildInputField(
            controller: _emailCodeController,
            placeholder: '请输入验证码',
            keyboardType: TextInputType.number,
            suffixIcon: _buildCodeButton(
              sending: context.watch<AuthProvider>().isSendingEmailCode,
              countdown: _emailCountdown,
              onTap: _emailCountdown > 0 ? null : _sendEmailCode,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPayPasswordField(RegisterFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_fieldTitle(field)),
        _buildInputField(
          controller: _payPasswordController,
          placeholder: '请输入安全码',
          obscureText: !_showPayPassword,
          suffixIcon: _buildPasswordToggle(
            visible: _showPayPassword,
            onTap: () => setState(() => _showPayPassword = !_showPayPassword),
          ),
        ),
      ],
    );
  }

  Widget _buildAreaCodePrefix() {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.only(right: 16.w),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFDCDFE6))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedCountryCode,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down,
              size: 16.sp, color: const Color(0xFF333333)),
        ],
      ),
    );
  }

  Widget _buildCodeButton({
    required bool sending,
    required int countdown,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: sending ? null : onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Text(
          sending
              ? '发送中'
              : countdown > 0
                  ? '${countdown}s'
                  : '获取验证码',
          style: TextStyle(
            fontSize: 14.sp,
            color: countdown > 0 ? const Color(0xFF999999) : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordToggle({
    required bool visible,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Icon(
          visible ? Icons.visibility : Icons.visibility_off,
          color: const Color(0xFF999999),
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildCaptchaForm() {
    final authProvider = context.watch<AuthProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('图形验证码'),
        _buildInputField(
          controller: _captchaController,
          placeholder: '请输入图形验证码',
          suffixIcon: GestureDetector(
            onTap: () => context.read<AuthProvider>().loadCaptcha(),
            child: Container(
              width: 92.w,
              height: 34.h,
              margin: EdgeInsets.only(left: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: authProvider.isCaptchaLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CaptchaImage(captcha: authProvider.captcha),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRegister(
    HomeConfig config, {
    required bool showCaptcha,
  }) async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final captchaCode = _captchaController.text.trim();

    if (account.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('请输入账号和密码');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('两次输入的密码不一致');
      return;
    }
    if (!_validateConfiguredFields(config)) return;
    if (showCaptcha && captchaCode.isEmpty) {
      _showMessage('请输入图形验证码');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final request = RegisterRequest(
      username: account,
      password: password,
      confirmPassword: confirmPassword,
      phone: _textIfVisible(config, 'phone', _phoneController),
      areaCode: _isVisible(config, 'phone') ? _selectedCountryCode : null,
      phoneCode: _phoneCodeController.text,
      email: _textIfVisible(config, 'email', _emailController),
      emailCode: _emailCodeController.text,
      name: _textIfVisible(config, 'name', _nameController),
      qq: _textIfVisible(config, 'qq', _qqController),
      telegram: _textIfVisible(config, 'telegram', _telegramController),
      inviteCode: _textIfVisible(config, 'invicode', _inviteController),
      payPassword: _textIfVisible(
        config,
        'pay_password',
        _payPasswordController,
      ),
      captchaCode: showCaptcha ? captchaCode : null,
      captchaKey: authProvider.captcha?.captchaKey,
    );

    try {
      setState(() => _formError = null);
      await authProvider.register(request);
      if (!mounted) return;
      await context.read<UserProvider>().loadProfile();
      if (!mounted) return;
      context.go('/');
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
      if (showCaptcha) {
        _captchaController.clear();
        await context.read<AuthProvider>().loadCaptcha();
      }
    }
  }

  bool _validateConfiguredFields(HomeConfig config) {
    for (final field in config.registerConfig.where((item) => item.isVisible)) {
      if (!field.isRequired) continue;
      final controller = _controllerFor(field.code);
      if (controller == null || controller.text.trim().isNotEmpty) continue;
      _showMessage('请输入${field.title ?? '必填信息'}');
      return false;
    }
    if (_isVisible(config, 'phone') &&
        config.smsConfig?.regStatus == 1 &&
        _phoneCodeController.text.trim().isEmpty) {
      _showMessage('请输入短信验证码');
      return false;
    }
    if (_isVisible(config, 'email') &&
        config.mailConfig?.regStatus == 1 &&
        _emailCodeController.text.trim().isEmpty) {
      _showMessage('请输入邮箱验证码');
      return false;
    }
    return true;
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('请输入手机号');
      return;
    }
    try {
      setState(() => _formError = null);
      final message = await context.read<AuthProvider>().sendSmsCode(
            phone: phone,
            areaCode: _selectedCountryCode,
            type: 2,
          );
      if (!mounted) return;
      _startSmsCountdown();
      _showMessage(message);
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('请输入邮箱地址');
      return;
    }
    try {
      setState(() => _formError = null);
      final message = await context.read<AuthProvider>().sendEmailCode(
            email: email,
            type: 2,
          );
      if (!mounted) return;
      _startEmailCountdown();
      _showMessage(message);
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  void _startSmsCountdown() {
    _smsTimer?.cancel();
    setState(() => _smsCountdown = 60);
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_smsCountdown <= 1) {
        timer.cancel();
        setState(() => _smsCountdown = 0);
      } else {
        setState(() => _smsCountdown--);
      }
    });
  }

  void _startEmailCountdown() {
    _emailTimer?.cancel();
    setState(() => _emailCountdown = 60);
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_emailCountdown <= 1) {
        timer.cancel();
        setState(() => _emailCountdown = 0);
      } else {
        setState(() => _emailCountdown--);
      }
    });
  }

  TextEditingController? _controllerFor(String? code) {
    switch (code) {
      case 'phone':
        return _phoneController;
      case 'email':
        return _emailController;
      case 'name':
        return _nameController;
      case 'qq':
        return _qqController;
      case 'telegram':
        return _telegramController;
      case 'invicode':
        return _inviteController;
      case 'pay_password':
        return _payPasswordController;
      default:
        return null;
    }
  }

  String? _textIfVisible(
    HomeConfig config,
    String code,
    TextEditingController controller,
  ) {
    if (!_isVisible(config, code)) return null;
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  bool _isVisible(HomeConfig config, String code) {
    return config.registerConfig.any(
      (field) => field.code == code && field.isVisible,
    );
  }

  String _fieldTitle(RegisterFieldConfig field) {
    final title = field.title?.trim();
    return field.isRequired
        ? '${title == null || title.isEmpty ? '信息' : title} *'
        : title == null || title.isEmpty
            ? '信息'
            : title;
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    return error.toString();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    setState(() => _formError = message);
    _showMessage(message);
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixWidget,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (prefixWidget != null) prefixWidget,
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFC0C4CC),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
