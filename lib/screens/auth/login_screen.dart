import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/models/auth_models.dart';
import 'package:my_flutter_app/services/auth_service.dart';
import 'package:my_flutter_app/providers/home_provider.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _areaCodeController = TextEditingController(text: '+86');

  late TabController _tabController;
  int _loginType = 1; // 1: Username, 2: Email, 3: Phone
  final String _areaCode = '86';

  // 动态保存当前可用的登录类型
  List<int> _availableLoginTypes = [1];

  bool _obscurePassword = true;
  CaptchaData? _captchaData;
  bool _isLoadingCaptcha = false;

  // SMS & Email code
  bool _isSendingSmsCode = false;
  int _smsCountdown = 0;
  Timer? _smsTimer;

  bool _isSendingEmailCode = false;
  int _emailCountdown = 0;
  Timer? _emailTimer;

  @override
  void initState() {
    super.initState();

    // 强制刷新配置数据，确保获取到最新的登录配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(homeDataProvider);
    });

    // 获取当前已有的配置数据来初始化 Tab
    final homeDataState = ref.read(homeDataProvider);
    final initialHomeData = homeDataState.asData?.value;
    if (initialHomeData != null) {
      final types = [1];
      if (initialHomeData.sendConfig?.loginStatus == 1) types.add(3);
      if (initialHomeData.mailConfig?.loginStatus == 1) types.add(2);
      _availableLoginTypes = types;
      _loginType = _availableLoginTypes[0];
    }

    _tabController = TabController(
      length: _availableLoginTypes.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
    _refreshCaptcha();
  }

  void _handleTabChange() {
    setState(() {
      _loginType = _availableLoginTypes[_tabController.index];
    });
  }

  void _updateTabs(HomeData homeData) {
    print('Updating tabs with homeData: ${homeData.sendConfig?.loginStatus}');
    final newTypes = [1]; // 账号登录始终开启

    // 根据配置决定手机和邮箱登录是否开启
    if (homeData.sendConfig?.loginStatus == 1) {
      newTypes.add(3); // 手机登录
    }
    if (homeData.mailConfig?.loginStatus == 1) {
      newTypes.add(2); // 邮箱登录
    }
    print('New available login types: $newTypes');

    if (newTypes.length != _availableLoginTypes.length ||
        !newTypes.every((t) => _availableLoginTypes.contains(t))) {
      // 在下一帧更新，避免在 build 过程中更新状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _availableLoginTypes = newTypes;
            final oldIndex = _tabController.index;
            _tabController.removeListener(_handleTabChange);
            _tabController.dispose();

            // 使用 initialIndex 来避免同步问题
            int initialIndex = 0;
            if (oldIndex < _availableLoginTypes.length) {
              initialIndex = oldIndex;
            }

            _tabController = TabController(
              length: _availableLoginTypes.length,
              vsync: this,
              initialIndex: initialIndex,
            );
            _tabController.addListener(_handleTabChange);
            _loginType = _availableLoginTypes[_tabController.index];
            print(
              'State updated: _availableLoginTypes=$_availableLoginTypes, _loginType=$_loginType',
            );
          });
        }
      });
    }
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
    _areaCodeController.dispose();
    _tabController.dispose();
    _smsTimer?.cancel();
    _emailTimer?.cancel();
    super.dispose();
  }

  Future<void> _getSmsCode() async {
    if (_isSendingSmsCode || _smsCountdown > 0) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ToastUtils.showWarning('请输入手机号');
      return;
    }

    setState(() => _isSendingSmsCode = true);

    // Call SMS API
    final response = await AuthService.sendSmsCode(phone, _areaCode, type: 1);

    if (mounted) {
      setState(() => _isSendingSmsCode = false);
      if (response.isSuccess) {
        ToastUtils.showSuccess('验证码已发送');
        _startSmsCountdown();
      } else {
        ToastUtils.showError(response.msg ?? '发送失败');
      }
    }
  }

  void _startSmsCountdown() {
    setState(() => _smsCountdown = 60);
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_smsCountdown <= 0) {
        timer.cancel();
        setState(() => _smsCountdown = 0);
      } else {
        setState(() => _smsCountdown--);
      }
    });
  }

  Future<void> _getEmailCode() async {
    if (_isSendingEmailCode || _emailCountdown > 0) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ToastUtils.showWarning('请输入邮箱地址');
      return;
    }

    // Simple email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ToastUtils.showWarning('请输入有效的邮箱地址');
      return;
    }

    setState(() => _isSendingEmailCode = true);

    // Call Email API
    final response = await AuthService.sendEmailCode(email, type: 1);

    if (mounted) {
      setState(() => _isSendingEmailCode = false);
      if (response.isSuccess) {
        ToastUtils.showSuccess('验证码已发送');
        _startEmailCountdown();
      } else {
        ToastUtils.showError(response.msg ?? '发送失败');
      }
    }
  }

  void _startEmailCountdown() {
    setState(() => _emailCountdown = 60);
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_emailCountdown <= 0) {
        timer.cancel();
        setState(() => _emailCountdown = 0);
      } else {
        setState(() => _emailCountdown--);
      }
    });
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
        ToastUtils.showSuccess('登录成功');
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!);
        } else {
          context.go('/home');
        }
      } else {
        ToastUtils.showError(response.msg ?? '登录失败');
        _refreshCaptcha();
        _captchaController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    // 使用 ref.listen 监听数据变化，安全地更新 Tab 状态
    ref.listen(homeDataProvider, (previous, next) {
      next.whenData((homeData) {
        _updateTabs(homeData);
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        bottom: (_availableLoginTypes.length > 1)
            ? TabBar(
                key: ValueKey(
                  'login_tab_bar_${_tabController.length}_${_tabController.hashCode}',
                ),
                controller: _tabController,
                tabs: _availableLoginTypes.map((type) {
                  switch (type) {
                    case 1:
                      return const Tab(text: '账号登录');
                    case 3:
                      return const Tab(text: '手机登录');
                    case 2:
                      return const Tab(text: '邮箱登录');
                    default:
                      return const Tab(text: '');
                  }
                }).toList(),
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.getSecondaryTextColor(context),
                indicatorColor: AppTheme.primary,
              )
            : null,
      ),
      body: SafeArea(
        child: homeDataAsync.when(
          data: (homeData) => _buildLoginForm(homeData, authState.isLoading),
          loading: () => homeDataAsync.hasValue
              ? _buildLoginForm(homeDataAsync.value!, authState.isLoading)
              : const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('加载配置失败: $err')),
        ),
      ),
    );
  }

  Widget _buildLoginForm(HomeData homeData, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            _buildHeader(),
            const SizedBox(height: 32),
            if (_availableLoginTypes.length <= 1)
              _buildUsernameField()
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_loginType),
                  child: _buildCurrentLoginField(),
                ),
              ),
            if (_loginType == 1) ...[
              const SizedBox(height: 24),
              _buildPasswordField(),
            ] else if (_loginType == 3) ...[
              const SizedBox(height: 24),
              _buildSmsCodeField(),
            ] else ...[
              const SizedBox(height: 24),
              _buildEmailCodeField(),
            ],
            if (homeData.picConfig?.loginStatus == 1) ...[
              const SizedBox(height: 24),
              _buildCaptchaField(),
            ],
            const SizedBox(height: 16),
            _buildForgotPassword(),
            const SizedBox(height: 24),
            _buildLoginButton(isLoading),
            const SizedBox(height: 24),
            _buildRegisterPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLoginField() {
    switch (_loginType) {
      case 1:
        return _buildUsernameField();
      case 3:
        return _buildPhoneField();
      case 2:
        return _buildEmailField();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.only(right: 16),
          child: _buildTextField(
            controller: _areaCodeController,
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
            keyboardType: TextInputType.text,
            validator: (value) {
              if (_loginType == 3 && (value == null || value.isEmpty))
                return '请输入手机号';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '验证码',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _smsCodeController,
                decoration: InputDecoration(
                  hintText: '短信验证码',
                  hintStyle: TextStyle(
                    color: AppTheme.getTertiaryTextColor(context),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.getTertiaryTextColor(context),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.getInputFillColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getInputBorderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.error,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入验证码';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            _buildGetCodeButton(
              onPressed: _getSmsCode,
              isLoading: _isSendingSmsCode,
              countdown: _smsCountdown,
              label: '获取验证码',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '验证码',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailCodeController,
                decoration: InputDecoration(
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(
                    color: AppTheme.getTertiaryTextColor(context),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.getTertiaryTextColor(context),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.getInputFillColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getInputBorderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.error,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入验证码';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            _buildGetCodeButton(
              onPressed: _getEmailCode,
              isLoading: _isSendingEmailCode,
              countdown: _emailCountdown,
              label: '获取验证码',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGetCodeButton({
    required VoidCallback onPressed,
    bool isLoading = false,
    int countdown = 0,
    required String label,
  }) {
    return GestureDetector(
      onTap: (isLoading || countdown > 0) ? null : onPressed,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: (isLoading || countdown > 0)
              ? AppTheme.primary.withAlpha(13)
              : AppTheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                countdown > 0 ? '${countdown}s' : label,
                style: TextStyle(
                  color: (isLoading || countdown > 0)
                      ? AppTheme.textTertiary
                      : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '欢迎回来',
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '请登录您的账号以继续',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
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
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '验证码',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _captchaController,
                decoration: InputDecoration(
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(
                    color: AppTheme.getTertiaryTextColor(context),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.getTertiaryTextColor(context),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.getInputFillColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getInputBorderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.error,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入验证码';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _refreshCaptcha,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.getInputFillColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getInputBorderColor(context),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isLoadingCaptcha
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _buildCaptchaImage(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptchaImage() {
    if (_captchaData == null)
      return const Icon(Icons.refresh, color: AppTheme.textTertiary);

    final content =
        _captchaData!.captchaCode ??
        _captchaData!.captchaImg ??
        _captchaData!.captchaImageContent;
    if (content.isEmpty)
      return const Icon(Icons.refresh, color: AppTheme.textTertiary);

    try {
      // Handle data:image/png;base64, prefix if present
      final base64String = content.contains(',')
          ? content.split(',').last
          : content;
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error_outline, color: AppTheme.error),
      );
    } catch (e) {
      debugPrint('Captcha decode error: $e');
      return const Icon(Icons.error_outline, color: AppTheme.error);
    }
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
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.getTertiaryTextColor(context),
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppTheme.getTertiaryTextColor(context),
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.getInputFillColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.getInputBorderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
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
        Text(
          '还没有账号?',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text(
            '立即注册',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
