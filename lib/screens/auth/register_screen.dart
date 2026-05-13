import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String? _selectedCurrencyCode;

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
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/login'),
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
                'auth.welcomeRegister'.tr(),
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
                  _buildTag('auth.fastWithdraw'.tr()),
                  SizedBox(width: 16.w),
                  _buildTag('auth.dataSecure'.tr()),
                  SizedBox(width: 16.w),
                  _buildTag('auth.certified'.tr()),
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
    final showCaptcha = config.captchaConfig?.regStatus == 1 &&
        config.captchaConfig?.codeType == 1;
    if (showCaptcha && context.read<AuthProvider>().captcha == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AuthProvider>().loadCaptcha();
      });
    }

    return _buildRegisterCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(context.tr('auth.account')),
          _buildInputField(
            controller: _accountController,
            placeholder: context.tr('auth.enterAccount'),
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel(context.tr('auth.password')),
          _buildInputField(
            controller: _passwordController,
            placeholder: context.tr('auth.enterPassword'),
            obscureText: !_showPassword,
            suffixIcon: _buildPasswordToggle(
              visible: _showPassword,
              onTap: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel(context.tr('auth.confirmPassword')),
          _buildInputField(
            controller: _confirmPasswordController,
            placeholder: context.tr('auth.enterConfirmPassword'),
            obscureText: !_showConfirmPassword,
            suffixIcon: _buildPasswordToggle(
              visible: _showConfirmPassword,
              onTap: () => setState(
                () => _showConfirmPassword = !_showConfirmPassword,
              ),
            ),
          ),
          if (config.currencies.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _buildCurrencyField(config),
          ],
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
                      context.tr('common.register'),
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
                        context.tr('auth.hasAccount'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/login'),
                      child: Text(
                        context.tr('auth.loginNow'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                        ),
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),
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
          widgets.add(_buildSimpleField(
              field, _nameController, context.tr('auth.enterRealName')));
          break;
        case 'qq':
          widgets.add(_buildSimpleField(
              field, _qqController, context.tr('auth.enterQq')));
          break;
        case 'telegram':
          widgets.add(_buildSimpleField(
              field, _telegramController, context.tr('auth.enterTelegram')));
          break;
        case 'invicode':
          widgets.add(_buildSimpleField(
              field, _inviteController, context.tr('auth.enterInviteCode')));
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
          placeholder: context.tr('auth.enterPhone'),
          keyboardType: TextInputType.phone,
          prefixWidget: _buildAreaCodePrefix(),
        ),
        if (needsCode) ...[
          SizedBox(height: 20.h),
          _buildFieldLabel(context.tr('auth.smsCode')),
          _buildInputField(
            controller: _phoneCodeController,
            placeholder: context.tr('auth.enterCode'),
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
          placeholder: context.tr('auth.enterEmail'),
          keyboardType: TextInputType.emailAddress,
        ),
        if (needsCode) ...[
          SizedBox(height: 20.h),
          _buildFieldLabel(context.tr('auth.emailCode')),
          _buildInputField(
            controller: _emailCodeController,
            placeholder: context.tr('auth.enterCode'),
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
          placeholder: context.tr('auth.enterSecurityCode'),
          obscureText: !_showPayPassword,
          suffixIcon: _buildPasswordToggle(
            visible: _showPayPassword,
            onTap: () => setState(() => _showPayPassword = !_showPayPassword),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField(HomeConfig config) {
    final currencies = _availableCurrencies(config);
    if (currencies.isEmpty) return const SizedBox.shrink();
    final selectedCode = _resolvedCurrencyCode(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context.tr('auth.selectCurrency')),
        GestureDetector(
          onTap: () => _showCurrencyPicker(config),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currencyTitle(currencies, selectedCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_right,
                    size: 18.sp, color: const Color(0xFF999999)),
              ],
            ),
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
              ? context.tr('auth.sending')
              : countdown > 0
                  ? '${countdown}s'
                  : context.tr('auth.getCode'),
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

  Future<void> _submitRegister(
    HomeConfig config, {
    required bool showCaptcha,
  }) async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final captchaCode = _captchaController.text.trim();

    if (account.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage(context.tr('auth.enterAccountPassword'));
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9]{1,12}$').hasMatch(account)) {
      _showMessage(context.tr('auth.accountRule'));
      return;
    }
    if (password.length > 18 || confirmPassword.length > 18) {
      _showMessage(context.tr('auth.passwordTooLong'));
      return;
    }
    if (password != confirmPassword) {
      _showMessage(context.tr('auth.passwordMismatch'));
      return;
    }
    if (!_validateConfiguredFields(config)) return;
    if (showCaptcha && captchaCode.isEmpty) {
      _showMessage(context.tr('auth.enterCaptcha'));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final request = RegisterRequest(
      username: account,
      password: password,
      confirmPassword: confirmPassword,
      currency: _registrationCurrencyCode(config),
      phone: _visibleText(config, 'phone', _phoneController),
      areaCode: _isVisible(config, 'phone') ? _selectedCountryCode : '',
      phoneCode: _visibleText(config, 'phone', _phoneCodeController),
      email: _visibleText(config, 'email', _emailController),
      emailCode: _visibleText(config, 'email', _emailCodeController),
      name: _visibleText(config, 'name', _nameController),
      qq: _qqValue(config),
      telegram: _visibleText(config, 'telegram', _telegramController),
      inviteCode: _visibleText(config, 'invicode', _inviteController),
      payPassword: _visibleText(
        config,
        'pay_password',
        _payPasswordController,
      ),
      captchaCode: showCaptcha ? captchaCode : '',
      captchaKey: showCaptcha ? authProvider.captcha?.captchaKey : '',
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
      _showMessage(context.tr(
        'auth.enterDynamicRequired',
        namedArgs: {'field': field.title ?? context.tr('auth.requiredInfo')},
      ));
      return false;
    }
    if (_isVisible(config, 'pay_password')) {
      final value = _payPasswordController.text.trim();
      if (value.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(value)) {
        _showMessage(context.tr('auth.securityCodeRule'));
        return false;
      }
    }
    if (_isVisible(config, 'qq')) {
      final value = _qqController.text.trim();
      if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
        _showMessage(context.tr('auth.qqDigitsOnly'));
        return false;
      }
    }
    if (_isVisible(config, 'invicode') &&
        _inviteController.text.trim().length > 10) {
      _showMessage(context.tr('auth.inviteCodeTooLong'));
      return false;
    }
    if (_isVisible(config, 'phone') &&
        config.smsConfig?.regStatus == 1 &&
        _phoneCodeController.text.trim().isEmpty) {
      _showMessage(context.tr('auth.enterSmsCode'));
      return false;
    }
    if (_isVisible(config, 'email') &&
        config.mailConfig?.regStatus == 1 &&
        _emailCodeController.text.trim().isEmpty) {
      _showMessage(context.tr('auth.enterEmailVerifyCode'));
      return false;
    }
    return true;
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
            type: 2,
          );
      if (!mounted) return;
      _applyReturnedCaptcha(result);
      _startSmsCountdown(
          _countdownSeconds(context.read<SystemProvider>().config.smsConfig));
      _showMessage(result.message);
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  Future<void> _sendEmailCode() async {
    final username = _accountController.text.trim();
    final email = _emailController.text.trim();
    if (username.isEmpty) {
      _showMessage(context.tr('auth.enterAccount'));
      return;
    }
    if (email.isEmpty) {
      _showMessage(context.tr('auth.enterEmail'));
      return;
    }
    try {
      setState(() => _formError = null);
      final result = await context.read<AuthProvider>().sendEmailCode(
            email: email,
            type: 2,
            username: username,
          );
      if (!mounted) return;
      _applyReturnedCaptcha(result);
      _startEmailCountdown(
        _countdownSeconds(context.read<SystemProvider>().config.mailConfig),
      );
      _showMessage(result.message);
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage(_errorMessage(error));
    }
  }

  void _startSmsCountdown(int seconds) {
    _smsTimer?.cancel();
    setState(() => _smsCountdown = seconds);
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

  void _startEmailCountdown(int seconds) {
    _emailTimer?.cancel();
    setState(() => _emailCountdown = seconds);
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

  String _visibleText(
    HomeConfig config,
    String code,
    TextEditingController controller,
  ) {
    if (!_isVisible(config, code)) return '';
    return controller.text.trim();
  }

  Object _qqValue(HomeConfig config) {
    if (!_isVisible(config, 'qq')) return 0;
    final text = _qqController.text.trim();
    if (text.isEmpty || !RegExp(r'^\d+$').hasMatch(text)) return 0;
    return int.tryParse(text) ?? 0;
  }

  String _registrationCurrencyCode(HomeConfig config) {
    return _resolvedCurrencyCode(config);
  }

  List<CurrencyConfig> _availableCurrencies(HomeConfig config) {
    return config.currencies.where((item) {
      final code = item.code?.trim();
      return code != null && code.isNotEmpty;
    }).toList();
  }

  String _resolvedCurrencyCode(HomeConfig config) {
    final currencies = _availableCurrencies(config);
    if (currencies.isEmpty) return '';
    final selected = _selectedCurrencyCode?.trim();
    if (selected != null &&
        selected.isNotEmpty &&
        currencies.any((item) => item.code?.trim() == selected)) {
      return selected;
    }
    for (final currency in currencies) {
      if (currency.requiredStatus == 1) {
        return currency.code?.trim() ?? '';
      }
    }
    return currencies.first.code?.trim() ?? '';
  }

  String _currencyTitle(List<CurrencyConfig> currencies, String code) {
    final currency = currencies.where((item) => item.code?.trim() == code);
    if (currency.isEmpty) return code;
    final item = currency.first;
    final title = item.title?.trim();
    final symbol = item.symbol?.trim();
    if (title == null || title.isEmpty) return code;
    if (symbol == null || symbol.isEmpty) return title;
    if (title.contains('（') || title.contains('(')) return title;
    return '$symbol（$title）';
  }

  Future<void> _showCurrencyPicker(HomeConfig config) async {
    final currencies = _availableCurrencies(config);
    if (currencies.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final item = currencies[index];
            final code = item.code?.trim() ?? '';
            return ListTile(
              title: Text(_currencyTitle(currencies, code)),
              trailing: code == _resolvedCurrencyCode(config)
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(code),
            );
          },
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedCurrencyCode = selected);
  }

  void _applyReturnedCaptcha(VerificationCodeData result) {
    final captcha = result.captcha;
    if (captcha == null) return;
    context.read<AuthProvider>().applyCaptcha(captcha);
    _captchaController.clear();
  }

  int _countdownSeconds(VerifyConfig? config) {
    final expire = config?.expire;
    if (expire != null && expire > 0) return expire * 60;
    return 60;
  }

  bool _isVisible(HomeConfig config, String code) {
    return config.registerConfig.any(
      (field) => field.code == code && field.isVisible,
    );
  }

  String _fieldTitle(RegisterFieldConfig field) {
    final title = field.title?.trim();
    return field.isRequired
        ? '${title == null || title.isEmpty ? context.tr('auth.info') : title} *'
        : title == null || title.isEmpty
            ? context.tr('auth.info')
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
