import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../api/api_exception.dart';
import '../../models/auth/auth_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/captcha_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.redirectPath});

  final String? redirectPath;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _showPassword = false;
  String _activeTab = 'username'; // 'username' or 'phone'
  final String _selectedCountryCode = '+86';
  String? _formError;
  int _smsCountdown = 0;
  int _emailCountdown = 0;
  Timer? _smsTimer;
  Timer? _emailTimer;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _emailController.dispose();
    _emailCodeController.dispose();
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
                _buildLoginCard(),
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
                  const SizedBox(), // Spacer for layout
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Icon(
                      Icons.close,
                      size: 22.sp,
                      color: const Color.fromRGBO(51, 51, 51, 0.85),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                '欢迎回来',
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
                    Icons.favorite,
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
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    final systemProvider = context.watch<SystemProvider>();
    if (!systemProvider.hasLoadedConfig) {
      return _buildLoginCardShell(
        child: SizedBox(
          height: 350.h,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final config = systemProvider.config;
    final availableTabs = _availableTabs(systemProvider);
    final showCaptcha = config.captchaConfig?.loginStatus == 1;
    if (showCaptcha && context.read<AuthProvider>().captcha == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AuthProvider>().loadCaptcha();
      });
    }

    if (!availableTabs.contains(_activeTab)) {
      _activeTab = 'username';
    }

    return _buildLoginCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableTabs.length > 1) _buildTabs(availableTabs),
          SizedBox(height: 30.h),
          if (_activeTab == 'username')
            _buildUsernameForm()
          else if (_activeTab == 'email')
            _buildEmailForm()
          else
            _buildPhoneForm(),
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
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '忘记密码？ ',
                style:
                    TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
              ),
              GestureDetector(
                onTap: () => context.push('/reset-password'),
                child: Text(
                  '重置',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
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
              ).copyWith(
                elevation: WidgetStateProperty.all(4),
              ),
              onPressed: context.watch<AuthProvider>().isSubmitting
                  ? null
                  : () => _submitLogin(showCaptcha: showCaptcha),
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
                      '登录',
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
                    '还没有账号？ ',
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0xFF999999)),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      '立即注册',
                      style:
                          TextStyle(fontSize: 14.sp, color: AppColors.primary),
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

  Widget _buildLoginCardShell({required Widget child}) {
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

  List<String> _availableTabs(SystemProvider systemProvider) {
    final config = systemProvider.config;
    return <String>[
      'username',
      if (config.smsConfig?.loginStatus == 1) 'phone',
      if (config.mailConfig?.loginStatus == 1) 'email',
    ];
  }

  Widget _buildTabs(List<String> availableTabs) {
    return Row(
      children: [
        for (final tab in availableTabs) ...[
          _buildTabItem(tab, _tabTitle(tab)),
          if (tab != availableTabs.last) SizedBox(width: 32.w),
        ],
      ],
    );
  }

  String _tabTitle(String tab) {
    switch (tab) {
      case 'phone':
        return '手机号登录';
      case 'email':
        return '邮箱登录';
      default:
        return '账号登录';
    }
  }

  Widget _buildTabItem(String tabValue, String title) {
    final isActive = _activeTab == tabValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tabValue;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isActive ? 18.sp : 16.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isActive ? const Color(0xFF333333) : const Color(0xFF999999),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('账号'),
        _buildInputField(
          controller: _usernameController,
          placeholder: '请输入账号',
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel('密码'),
        _buildInputField(
          controller: _passwordController,
          placeholder: '请输入密码',
          obscureText: !_showPassword,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF999999),
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('手机号'),
        _buildInputField(
          controller: _phoneController,
          placeholder: '请输入手机号',
          keyboardType: TextInputType.phone,
          prefixWidget: GestureDetector(
            onTap: () {
              // TODO: Show country picker bottom sheet
            },
            child: Container(
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
            ),
          ),
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel('验证码'),
        _buildInputField(
          controller: _smsCodeController,
          placeholder: '请输入验证码',
          keyboardType: TextInputType.number,
          suffixIcon: GestureDetector(
            onTap: _smsCountdown > 0 ? null : _sendSmsCode,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                context.watch<AuthProvider>().isSendingSmsCode
                    ? '发送中'
                    : _smsCountdown > 0
                        ? '${_smsCountdown}s'
                        : '获取验证码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _smsCountdown > 0
                      ? const Color(0xFF999999)
                      : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('邮箱'),
        _buildInputField(
          controller: _emailController,
          placeholder: '请输入邮箱地址',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel('验证码'),
        _buildInputField(
          controller: _emailCodeController,
          placeholder: '请输入验证码',
          suffixIcon: GestureDetector(
            onTap: _emailCountdown > 0 ? null : _sendEmailCode,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                context.watch<AuthProvider>().isSendingEmailCode
                    ? '发送中'
                    : _emailCountdown > 0
                        ? '${_emailCountdown}s'
                        : '获取验证码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _emailCountdown > 0
                      ? const Color(0xFF999999)
                      : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
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

  Future<void> _submitLogin({required bool showCaptcha}) async {
    final authProvider = context.read<AuthProvider>();
    final captchaCode = _captchaController.text.trim();
    final captchaKey = authProvider.captcha?.captchaKey;
    LoginRequest request;

    if (_activeTab == 'username') {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      if (username.isEmpty || password.isEmpty) {
        _showMessage('请输入账号和密码');
        return;
      }
      if (showCaptcha && captchaCode.isEmpty) {
        _showMessage('请输入图形验证码');
        return;
      }
      request = LoginRequest(
        type: 1,
        username: username,
        password: password,
        captchaCode: showCaptcha ? captchaCode : null,
        captchaKey: captchaKey,
      );
    } else if (_activeTab == 'phone') {
      final phone = _phoneController.text.trim();
      final code = _smsCodeController.text.trim();
      if (phone.isEmpty || code.isEmpty) {
        _showMessage('请输入手机号和验证码');
        return;
      }
      request = LoginRequest(
        type: 3,
        username: phone,
        phone: phone,
        areaCode: _selectedCountryCode,
        phoneCode: code,
        captchaCode: showCaptcha ? captchaCode : null,
        captchaKey: captchaKey,
      );
    } else {
      final email = _emailController.text.trim();
      final code = _emailCodeController.text.trim();
      if (email.isEmpty || code.isEmpty) {
        _showMessage('请输入邮箱和验证码');
        return;
      }
      request = LoginRequest(
        type: 2,
        username: email,
        email: email,
        emailCode: code,
        captchaCode: showCaptcha ? captchaCode : null,
        captchaKey: captchaKey,
      );
    }

    try {
      setState(() => _formError = null);
      await authProvider.login(request);
      if (!mounted) return;
      await context.read<UserProvider>().loadProfile();
      if (!mounted) return;
      final redirectPath = widget.redirectPath;
      context.go(
        redirectPath == null || redirectPath.isEmpty
            ? '/'
            : Uri.decodeComponent(redirectPath),
      );
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
      if (showCaptcha) {
        _captchaController.clear();
        await context.read<AuthProvider>().loadCaptcha();
      }
    }
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
      final message =
          await context.read<AuthProvider>().sendEmailCode(email: email);
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
