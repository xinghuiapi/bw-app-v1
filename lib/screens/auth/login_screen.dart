import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_exception.dart';
import '../../models/auth/auth_models.dart';
import '../../models/home/home_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/country_dial_options.dart';
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

  static const _loginFailKey = 'm1_login_fail_count';
  static const _captchaFailThreshold = 3;

  bool _showPassword = false;
  String _activeTab = 'username'; // 'username' or 'phone'
  String _selectedCountryCode = '+86';
  String? _formError;
  int _loginFailCount = 0;
  int _smsCountdown = 0;
  int _emailCountdown = 0;
  Timer? _smsTimer;
  Timer? _emailTimer;

  @override
  void initState() {
    super.initState();
    _loadLoginFailCount();
  }

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
              SizedBox(
                width: 250.w,
                child: Text(
                  context.tr('auth.welcomeBack'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                    letterSpacing: 1.w,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.only(right: 78.w),
                child: Row(
                  children: [
                    _buildTag(context.tr('auth.fastWithdraw')),
                    SizedBox(width: 10.w),
                    _buildTag(context.tr('auth.dataSecure')),
                    SizedBox(width: 10.w),
                    _buildTag(context.tr('auth.certified')),
                  ],
                ),
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
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 14.sp),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
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
    final showCaptcha = _shouldShowCaptcha(systemProvider);
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
                context.tr('auth.forgotPassword'),
                style:
                    TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
              ),
              GestureDetector(
                onTap: () => context.push('/reset-password'),
                child: Text(
                  context.tr('auth.reset'),
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
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          context.tr('common.login'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      context.tr('common.login'),
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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.tr('auth.noAccount'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.sp, color: const Color(0xFF999999)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        context.tr('auth.registerNow'),
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    context.tr('auth.browseFirst'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                  ),
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
          Expanded(child: _buildTabItem(tab, _tabTitle(tab))),
          if (tab != availableTabs.last) SizedBox(width: 10.w),
        ],
      ],
    );
  }

  String _tabTitle(String tab) {
    switch (tab) {
      case 'phone':
        return context.tr('auth.phoneLogin');
      case 'email':
        return context.tr('auth.emailLogin');
      default:
        return context.tr('auth.usernameLogin');
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isActive ? 16.sp : 14.sp,
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
        _buildFieldLabel(context.tr('auth.account')),
        _buildInputField(
          controller: _usernameController,
          placeholder: context.tr('auth.enterAccount'),
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel(context.tr('auth.password')),
        _buildInputField(
          controller: _passwordController,
          placeholder: context.tr('auth.enterPassword'),
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
        _buildFieldLabel(context.tr('auth.phone')),
        _buildInputField(
          controller: _phoneController,
          placeholder: context.tr('auth.enterPhone'),
          keyboardType: TextInputType.phone,
          prefixWidget: GestureDetector(
            onTap: _showCountryPicker,
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
        _buildFieldLabel(context.tr('auth.code')),
        _buildInputField(
          controller: _smsCodeController,
          placeholder: context.tr('auth.enterCode'),
          keyboardType: TextInputType.number,
          suffixIcon: GestureDetector(
            onTap: _smsCountdown > 0 ? null : _sendSmsCode,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                context.watch<AuthProvider>().isSendingSmsCode
                    ? context.tr('auth.sending')
                    : _smsCountdown > 0
                        ? '${_smsCountdown}s'
                        : context.tr('auth.getCode'),
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
        _buildFieldLabel(context.tr('auth.email')),
        _buildInputField(
          controller: _emailController,
          placeholder: context.tr('auth.enterEmail'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel(context.tr('auth.code')),
        _buildInputField(
          controller: _emailCodeController,
          placeholder: context.tr('auth.enterCode'),
          suffixIcon: GestureDetector(
            onTap: _emailCountdown > 0 ? null : _sendEmailCode,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                context.watch<AuthProvider>().isSendingEmailCode
                    ? context.tr('auth.sending')
                    : _emailCountdown > 0
                        ? '${_emailCountdown}s'
                        : context.tr('auth.getCode'),
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
        _buildFieldLabel(context.tr('auth.captcha')),
        _buildInputField(
          controller: _captchaController,
          placeholder: context.tr('auth.enterCaptcha'),
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
        _showMessage(context.tr('auth.enterAccountPassword'));
        return;
      }
      if (showCaptcha && captchaCode.isEmpty) {
        _showMessage(context.tr('auth.enterCaptcha'));
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
        _showMessage(context.tr('auth.enterPhoneCode'));
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
        _showMessage(context.tr('auth.enterEmailCode'));
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
      await _resetLoginFailCount();
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
      await _bumpLoginFailCount();
      _showErrorMessage(_errorMessage(error));
      if (_shouldShowCaptcha(context.read<SystemProvider>())) {
        _captchaController.clear();
        await context.read<AuthProvider>().loadCaptcha();
      }
    }
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage(context.tr('auth.enterPhone'));
      return;
    }
    try {
      setState(() => _formError = null);
      final result = await context.read<AuthProvider>().sendSmsCode(
            phone: phone,
            areaCode: _selectedCountryCode,
          );
      if (!mounted) return;
      _applyReturnedCaptcha(result);
      _startSmsCountdown();
      _showMessage(_localizedResultMessage(result.message));
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(context.tr('auth.enterEmail'));
      return;
    }
    try {
      setState(() => _formError = null);
      final result =
          await context.read<AuthProvider>().sendEmailCode(email: email);
      if (!mounted) return;
      _applyReturnedCaptcha(result);
      _startEmailCountdown();
      _showMessage(_localizedResultMessage(result.message));
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  void _startSmsCountdown() {
    _smsTimer?.cancel();
    setState(() => _smsCountdown = _countdownSeconds(
          context.read<SystemProvider>().config.smsConfig,
        ));
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
    setState(() => _emailCountdown = _countdownSeconds(
          context.read<SystemProvider>().config.mailConfig,
        ));
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

  String _localizedResultMessage(String message) {
    final text = message.trim();
    return text.startsWith('auth.') ? text.tr() : text;
  }

  bool _shouldShowCaptcha(SystemProvider systemProvider) {
    final config = systemProvider.config.captchaConfig;
    if (config?.codeType != null && config!.codeType != 1) return false;
    if (config?.loginStatus == 1) return true;
    return config?.loginError == 1 && _loginFailCount >= _captchaFailThreshold;
  }

  Future<void> _loadLoginFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _loginFailCount = prefs.getInt(_loginFailKey) ?? 0);
  }

  Future<void> _bumpLoginFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_loginFailKey) ?? _loginFailCount) + 1;
    await prefs.setInt(_loginFailKey, next);
    if (!mounted) return;
    setState(() => _loginFailCount = next);
  }

  Future<void> _resetLoginFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loginFailKey, 0);
    if (!mounted) return;
    setState(() => _loginFailCount = 0);
  }

  void _applyReturnedCaptcha(VerificationCodeData result) {
    final captcha = result.captcha;
    if (captcha == null) return;
    context.read<AuthProvider>().applyCaptcha(captcha);
    setState(() => _captchaController.clear());
  }

  int _countdownSeconds(VerifyConfig? config) {
    final expire = config?.expire;
    if (expire != null && expire > 0) return expire * 60;
    return 60;
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        var keyword = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final normalized = keyword.trim().toLowerCase();
            final countries = normalized.isEmpty
                ? countryDialOptions
                : countryDialOptions
                    .where((item) => item.matches(normalized, context))
                    .toList(growable: false);
            return SafeArea(
              child: SizedBox(
                height: 0.78.sh,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: Text('common.cancel'.tr()),
                          ),
                          Expanded(
                            child: Text(
                              _authText('countryCode', 'Select country/region'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 64.w),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        onChanged: (value) =>
                            setSheetState(() => keyword = value),
                        decoration: InputDecoration(
                          hintText: _authText(
                              'searchCountry', 'Search country or code'),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final item = countries[index];
                          return ListTile(
                            title: Text(item.displayName(context)),
                            trailing: Text(item.code),
                            selected: item.code == _selectedCountryCode,
                            onTap: () =>
                                Navigator.of(sheetContext).pop(item.code),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    setState(() => _selectedCountryCode = selected);
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

  String _authText(String key, String fallback) {
    final fullKey = 'auth.$key';
    final value = fullKey.tr();
    return value == fullKey ? fallback : value;
  }
}
